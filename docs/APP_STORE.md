# RiderLab → App Store (iOS)

Step-by-step release checklist with copy-paste listing text:
[APP_STORE_RELEASE.md](APP_STORE_RELEASE.md).

Bundle ID: `com.rawthrottle.riderlab` · Team: `886UT95Y7R` · App Store Connect app id: `6804365101`

## Build

```bash
cd apps/mobile
flutter build ipa --release --dart-define=DISTRIBUTION=appstore
```

Any iOS build is treated as a store build (`AppDistribution.isAppStore`), so the
sideload updater, the local Pro toggle and partner codes are off on iOS even if
`DISTRIBUTION` is forgotten. `ITSAppUsesNonExemptEncryption=false` is in Info.plist.

## Pro subscription (App Store Connect + RevenueCat)

| Item | Value |
|---|---|
| Subscription group | `RiderLab Pro` |
| Monthly product id | `riderlab_pro_monthly` — MX$59 |
| Yearly product id | `riderlab_pro_yearly` — MX$499 (default in paywall) |
| RevenueCat entitlement | `pro` |
| RevenueCat offering | `default` with `$rc_monthly` + `$rc_annual` packages |
| `.env` key | `REVENUECAT_API_KEY_IOS=appl_…` (Android: `REVENUECAT_API_KEY_ANDROID=goog_…`) |

Paywall (`lib/widgets/pro_upsell.dart`) shows both plans with store prices, the
auto-renew disclosure, Restore, Terms and Privacy links (guideline 3.1.2).

### Free trial and codes on iOS

- No app-run trial on iOS: `startTrialIfEligible()` is a no-op there and the
  paywall never mentions it. The iOS trial is the subscription's
  **introductory offer** (free trial) in App Store Connect. An account that
  started the server-side trial on Android still sees Pro on iOS while it lasts.
- Partner codes (`PRO-…`) are **hidden on iOS** (guideline 3.1.1). Use App Store
  **offer codes** instead: App Store Connect → Subscriptions → RiderLab Pro →
  Offer Codes. Users redeem them from Settings / paywall → "Canjear código de oferta".
- Server grants from Android partner codes still unlock Pro on iOS for the same account.

## Free vs Pro

See [FREE_VS_PRO.es.md](FREE_VS_PRO.es.md). Hardware (Métrica logger, adventure
camera / GoPro) is Pro. Rodadas, friends and Family Watch stay free.

## Store builds and the Free strip

`FreeAdBanner` never shows an "Ad" placeholder or "remove ads" copy in store
builds (no ads SDK). It promotes Pro features instead.

## Listing URLs

- Support / marketing: https://riderlab.rawthrottle.com.mx/
- Privacy: https://riderlab.rawthrottle.com.mx/legal/privacy.html
- Terms (EULA): https://riderlab.rawthrottle.com.mx/legal/terms.html
- Delete account: https://riderlab.rawthrottle.com.mx/legal/delete-account.html

## Métrica logger

Hidden on iOS 1.0 (`AppDistribution.allowsMetricaLogger`); returns in 1.1.

## Account deletion and Sign in with Apple

`delete-account` revokes the user's Apple tokens (guideline 5.1.1(v)). On iOS
the app asks Apple for a fresh authorization code before deleting an account
that has an Apple identity, and the function exchanges and revokes it. Needs
Edge Function secrets `APPLE_TEAM_ID`, `APPLE_KEY_ID`, `APPLE_PRIVATE_KEY`
(a key with Sign in with Apple enabled). Deletion still proceeds if Apple
fails; the failure is logged as `apple revoke failed`.

## EU (DSA)

Trader declaration is pending. Until it is done, exclude EU countries in
Pricing and Availability.
