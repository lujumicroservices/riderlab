import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/features.dart';
import '../../../core/models/ride.dart';
import '../../../core/models/share_visibility.dart';
import '../../../l10n/l10n_ext.dart';
import '../../../providers/ride_providers.dart';
import '../../../providers/social_providers.dart';
import '../../../theme/app_theme.dart';

/// Assign route + visibility (Only me / Friends / Everyone).
/// Updates local DB immediately; cloud sync is fire-and-forget so toggles feel instant.
class RideSharePanel extends ConsumerWidget {
  const RideSharePanel({super.key, required this.ride});

  final Ride ride;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.asphaltElevated,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.shareRideTitle,
            style: GoogleFonts.exo2(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.shareVisibilityHelp,
            style: GoogleFonts.rajdhani(
              color: AppTheme.steel,
              fontSize: 13,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          _LocalizedVisibilitySelector(
            value: ride.visibility,
            onChanged: (v) => _setVisibility(ref, v),
          ),
          if (AppFeatures.routesEnabled) ...[
            const SizedBox(height: 12),
            Text(
              l10n.assignRoute,
              style: GoogleFonts.exo2(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 6),
            ref
                .watch(routesListProvider)
                .when(
                  loading: () => const LinearProgressIndicator(),
                  error: (_, _) => Text(
                    l10n.cloudUnavailable,
                    style: const TextStyle(color: AppTheme.steel, fontSize: 12),
                  ),
                  data: (routes) {
                    return DropdownButtonFormField<String?>(
                      key: ValueKey('route-${ride.id}-${ride.routeId}'),
                      initialValue: ride.routeId,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppTheme.asphalt,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      hint: Text(l10n.noRouteAssigned),
                      items: [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Text(l10n.noRouteAssigned),
                        ),
                        for (final r in routes)
                          DropdownMenuItem<String?>(
                            value: r.id,
                            child: Text(r.name),
                          ),
                      ],
                      onChanged: (routeId) {
                        unawaited(_setRoute(ref, routeId));
                      },
                    );
                  },
                ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => _quickCreate(context, ref),
                icon: const Icon(Icons.add, size: 18),
                label: Text(l10n.createRoute),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _setVisibility(WidgetRef ref, ShareVisibility v) async {
    final updated = ride.copyWith(visibility: v);
    await ref.read(rideDatabaseProvider).upsertRide(updated);
    ref.invalidate(rideProvider(ride.id));
    ref.invalidate(overlappingPeersProvider(ride.id));
    unawaited(ref.read(rideSyncServiceProvider).syncRide(ride.id));
  }

  Future<void> _setRoute(WidgetRef ref, String? routeId) async {
    final updated = routeId == null
        ? ride.copyWith(clearRouteId: true)
        : ride.copyWith(routeId: routeId);
    await ref.read(rideDatabaseProvider).upsertRide(updated);
    ref.invalidate(rideProvider(ride.id));
    ref.invalidate(overlappingPeersProvider(ride.id));
    unawaited(ref.read(rideSyncServiceProvider).syncRide(ride.id));
  }

  Future<void> _quickCreate(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final ctrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.asphaltElevated,
        title: Text(l10n.createRoute),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(hintText: l10n.routeNameHint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.close),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.saveName),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final route = await ref
        .read(routeServiceProvider)
        .createRoute(name: ctrl.text, visibility: ShareVisibility.friends);
    final updated = ride.copyWith(
      routeId: route.id,
      visibility: ShareVisibility.friends,
    );
    await ref.read(rideDatabaseProvider).upsertRide(updated);
    unawaited(ref.read(rideSyncServiceProvider).syncRide(ride.id));
    ref.invalidate(routesListProvider);
    ref.invalidate(rideProvider(ride.id));
    ref.invalidate(overlappingPeersProvider(ride.id));
  }
}

/// Localized 3-way visibility control (Solo yo / Amigos / Todos).
class _LocalizedVisibilitySelector extends StatelessWidget {
  const _LocalizedVisibilitySelector({
    required this.value,
    required this.onChanged,
  });

  final ShareVisibility value;
  final ValueChanged<ShareVisibility> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    String label(ShareVisibility v) => switch (v) {
      ShareVisibility.private => l10n.rideDetailVisibilityPrivate,
      ShareVisibility.friends => l10n.rideDetailVisibilityFriends,
      ShareVisibility.public => l10n.rideDetailVisibilityPublic,
    };
    String help(ShareVisibility v) => switch (v) {
      ShareVisibility.private => l10n.rideDetailVisibilityPrivateHelp,
      ShareVisibility.friends => l10n.rideDetailVisibilityFriendsHelp,
      ShareVisibility.public => l10n.rideDetailVisibilityPublicHelp,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedButton<ShareVisibility>(
          segments: [
            for (final v in ShareVisibility.values)
              ButtonSegment(
                value: v,
                label: Text(label(v), style: GoogleFonts.exo2(fontSize: 12)),
                tooltip: help(v),
              ),
          ],
          selected: {value},
          onSelectionChanged: (set) {
            if (set.isEmpty) return;
            onChanged(set.first);
          },
          style: const ButtonStyle(
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          help(value),
          style: GoogleFonts.rajdhani(color: AppTheme.steel, fontSize: 12),
        ),
      ],
    );
  }
}
