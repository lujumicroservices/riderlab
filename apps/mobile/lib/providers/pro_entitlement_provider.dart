import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'dart:io' show Platform;

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/distribution.dart';
import '../core/pro/pro_entitlement.dart';
import '../core/pro/pro_entitlement_repository.dart';
import '../core/supabase/supabase_bootstrap.dart';
import 'supabase_providers.dart';

const _proKey = 'riderlab_pro_unlocked';
const _proStatusKey = 'riderlab_pro_status_json';

/// Entitlement id configured in RevenueCat dashboard.
/// Product contract: docs/FREE_VS_PRO.md
const revenueCatProEntitlement = 'pro';

/// How many brake events Free can see in full (rest are obfuscated).
const freeBrakePreviewCount = 3;

/// RevenueCat public SDK key for this platform.
///
/// RevenueCat issues one key per store: `appl_…` (App Store) and `goog_…`
/// (Play). `.env` keys, in order:
///   iOS:     REVENUECAT_API_KEY_IOS, then REVENUECAT_API_KEY
///   Android: REVENUECAT_API_KEY_ANDROID, then REVENUECAT_API_KEY
String get revenueCatApiKey {
  try {
    String read(String k) => dotenv.env[k]?.trim() ?? '';
    final platformKey = kIsWeb
        ? ''
        : Platform.isIOS
            ? read('REVENUECAT_API_KEY_IOS')
            : read('REVENUECAT_API_KEY_ANDROID');
    return platformKey.isNotEmpty ? platformKey : read('REVENUECAT_API_KEY');
  } catch (_) {
    return '';
  }
}

/// True when a RevenueCat API key is present in `.env`.
bool get revenueCatConfigured => revenueCatApiKey.isNotEmpty;

/// App Store Connect / Play product ids (RevenueCat offering `default`).
/// Contract: docs/APP_STORE.md
const proMonthlyProductId = 'riderlab_pro_monthly';
const proYearlyProductId = 'riderlab_pro_yearly';
/// The no-card 30-day trial (RPC `start_pro_trial`) is offered on Android and
/// sideload only. On iOS the trial must come from the App Store subscription
/// (introductory offer), so the app never starts or advertises its own trial.
bool get offersOwnProTrial => kIsWeb || !Platform.isIOS;

/// Sideload, not signed in: keep the local Settings toggle for pilots.
/// Never on iOS: App Store guideline 3.1.1 (Pro only via In-App Purchase).
bool get allowLocalProToggle {
  if (AppDistribution.isStoreBuild) return false;
  if (SupabaseBootstrap.isReady && SupabaseBootstrap.permanentUser != null) {
    return false;
  }
  return true;
}

final proEntitlementProvider =
    StateNotifierProvider<ProEntitlementController, ProEntitlementStatus>(
        (ref) {
  return ProEntitlementController(ref);
});

final isProProvider = Provider<bool>((ref) {
  return ref.watch(proEntitlementProvider).isPro;
});

class ProEntitlementController extends StateNotifier<ProEntitlementStatus> {
  ProEntitlementController(this._ref) : super(ProEntitlementStatus.empty) {
    _bootstrap();
    _ref.listen(supabaseSessionProvider, (prev, next) {
      unawaited(refresh());
    });
  }

  final Ref _ref;
  final ProEntitlementRepository _repo = ProEntitlementRepository();

  bool _rcReady = false;
  bool _rcPro = false;

  Future<void> _bootstrap() async {
    await _loadCache();
    if (revenueCatConfigured) {
      await _initRevenueCat();
    }
    await refresh();
  }

  Future<void> _loadCache() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_proStatusKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final map = jsonDecode(raw);
        if (map is Map<String, dynamic>) {
          state = ProEntitlementStatus.fromJson(map);
          return;
        }
      } catch (_) {}
    }
    final local = prefs.getBool(_proKey) ?? false;
    if (local && allowLocalProToggle) {
      state = const ProEntitlementStatus(
        isPro: true,
        source: 'local',
        localOverride: true,
      );
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_proKey, state.isPro);
    await prefs.setString(_proStatusKey, jsonEncode(state.toCacheJson()));
  }

  Future<void> _initRevenueCat() async {
    try {
      final key = revenueCatApiKey;
      await Purchases.setLogLevel(
        kDebugMode ? LogLevel.debug : LogLevel.info,
      );
      await Purchases.configure(PurchasesConfiguration(key));
      _rcReady = true;
      final uid = SupabaseBootstrap.permanentUserId;
      if (uid != null) {
        try {
          await Purchases.logIn(uid);
        } catch (e) {
          debugPrint('RevenueCat logIn failed: $e');
        }
      }
      Purchases.addCustomerInfoUpdateListener((info) {
        _applyRevenueCat(info);
        state = _merge(state);
        unawaited(_persist());
      });
      final info = await Purchases.getCustomerInfo();
      _applyRevenueCat(info);
    } catch (e, st) {
      debugPrint('RevenueCat init failed: $e\n$st');
      _rcReady = false;
    }
  }

  void _applyRevenueCat(CustomerInfo info) {
    _rcPro = info.entitlements.active.containsKey(revenueCatProEntitlement);
  }

  ProEntitlementStatus _merge(ProEntitlementStatus server) {
    if (_rcPro) {
      return server.copyWith(
        isPro: true,
        source: 'revenuecat',
      );
    }
    if (allowLocalProToggle && server.localOverride) {
      return server.copyWith(isPro: true, source: 'local');
    }
    return server;
  }

  /// Pull server periods (and RevenueCat if configured). Optionally start trial.
  Future<void> refresh({bool fromStoreOnly = false}) async {
    if (_rcReady && !fromStoreOnly) {
      try {
        final uid = SupabaseBootstrap.permanentUserId;
        if (uid != null) {
          await Purchases.logIn(uid);
        }
        final info = await Purchases.getCustomerInfo();
        _applyRevenueCat(info);
      } catch (e) {
        debugPrint('RevenueCat refresh failed: $e');
      }
    }

    if (!fromStoreOnly) {
      final remote = await _repo.status();
      if (remote.ok || remote.status.isPro || remote.status.trialUsed) {
        state = _merge(remote.status);
        await _persist();
      } else if (_rcPro) {
        state = _merge(state);
        await _persist();
      }
    } else {
      state = _merge(state);
      await _persist();
    }

    if (!fromStoreOnly) {
      await startTrialIfEligible();
    }
  }

  Future<void> onSignedOut() async {
    _rcPro = false;
    state = allowLocalProToggle
        ? const ProEntitlementStatus()
        : ProEntitlementStatus.empty;
    await _persist();
  }

  /// Returns true when an active Pro entitlement was restored.
  Future<bool> restorePurchases() async {
    if (!_rcReady) return false;
    try {
      final info = await Purchases.restorePurchases();
      _applyRevenueCat(info);
      await refresh(fromStoreOnly: true);
      return _rcPro;
    } catch (e) {
      debugPrint('RevenueCat restore failed: $e');
      return false;
    }
  }

  /// Current RevenueCat offering (monthly + annual packages), or null.
  Future<Offering?> currentOffering() async {
    if (!_rcReady) return null;
    try {
      final offerings = await Purchases.getOfferings();
      return offerings.current;
    } catch (e) {
      debugPrint('RevenueCat offerings failed: $e');
      return null;
    }
  }

  /// Buy one store package picked in the paywall. Returns true when Pro.
  Future<bool> purchasePackage(Package package) async {
    if (!_rcReady) return state.isPro;
    try {
      final purchase = await Purchases.purchase(
        PurchaseParams.package(package),
      );
      _applyRevenueCat(purchase.customerInfo);
      await refresh(fromStoreOnly: true);
      return state.isPro;
    } catch (e) {
      debugPrint('RevenueCat purchase failed: $e');
      return state.isPro;
    }
  }

  /// iOS: Apple's own offer-code sheet (replaces partner codes on iOS).
  /// The purchase arrives through the customer-info listener.
  Future<void> presentOfferCodeRedemption() async {
    if (!_rcReady || !AppDistribution.allowsOfferCodes) return;
    try {
      await Purchases.presentCodeRedemptionSheet();
    } catch (e) {
      debugPrint('RevenueCat offer code sheet failed: $e');
    }
  }

  /// Present store packages (yearly first). If billing is off, start the
  /// no-card 30-day trial instead of a dead checkout (not on iOS; see
  /// [offersOwnProTrial]).
  Future<bool> purchasePro() async {
    await startTrialIfEligible();
    if (state.isPro) return true;
    if (_rcReady) {
      try {
        final offerings = await Purchases.getOfferings();
        final current = offerings.current;
        final package = current?.annual ??
            current?.monthly ??
            current?.availablePackages.firstOrNull;
        if (package == null) {
          debugPrint('RevenueCat: no packages in current offering');
          return state.isPro;
        }
        final purchase = await Purchases.purchase(
          PurchaseParams.package(package),
        );
        _applyRevenueCat(purchase.customerInfo);
        await refresh(fromStoreOnly: true);
        return state.isPro;
      } catch (e) {
        debugPrint('RevenueCat purchase failed: $e');
        return state.isPro;
      }
    }
    return state.isPro;
  }

  /// Local toggle — sideload without a signed-in cloud session only.
  Future<void> setPro(bool unlocked) async {
    if (!allowLocalProToggle) {
      await refresh();
      return;
    }
    state = ProEntitlementStatus(
      isPro: unlocked,
      source: unlocked ? 'local' : null,
      localOverride: unlocked,
      trialUsed: state.trialUsed,
      partnerUsed: state.partnerUsed,
    );
    await _persist();
  }

  Future<void> toggle() => setPro(!state.isPro);

  /// First sign-in starts a 30-day trial (server enforces one per account).
  Future<void> startTrialIfEligible() async {
    if (!offersOwnProTrial) return;
    if (state.trialUsed && state.isPro) return;
    if (SupabaseBootstrap.permanentUser == null) return;
    final result = await _repo.startTrial();
    if (result.ok || result.status.trialUsed || result.status.isPro) {
      state = _merge(result.status);
      await _persist();
    }
  }

  Future<void> onRideCompleted() => startTrialIfEligible();

  Future<ProRpcResult> redeemPartnerCode(String code) async {
    if (!AppDistribution.allowsPartnerCodes) {
      return const ProRpcResult(ok: false, error: 'invalid_code');
    }
    if (_rcPro) {
      return const ProRpcResult(ok: false, error: 'already_paying');
    }
    final result = await _repo.redeem(code);
    if (result.ok) {
      state = _merge(result.status);
      await _persist();
    }
    return result;
  }

  Future<ProRpcResult> staffCreatePartnerCode({String? label}) {
    return _repo.staffCreateCode(label: label);
  }
}
