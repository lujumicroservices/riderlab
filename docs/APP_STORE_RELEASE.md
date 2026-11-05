# RiderLab iOS 1.0 → App Store production runbook

One ordered checklist from "code ready" to "live on the App Store". Reference
values (bundle id, product ids, URLs) are in [APP_STORE.md](APP_STORE.md); CI
signing details are in [IOS_TESTFLIGHT.md](IOS_TESTFLIGHT.md).

Release branch: `ios/appstore-release` · version **1.37.25 (101)**.

## Status (2026-11-05)

Done:
- Build 1.37.25 (101) uploaded and processed; available in TestFlight (Nov 4).
- App ID has Push Notifications + Sign in with Apple (present in the provisioning profile).
- Supabase: **Apple provider enabled** (client id `com.rawthrottle.riderlab`);
  `delete-account` with Apple token revocation deployed.
- RevenueCat account and app created (no products yet).
- Xcode Cloud post-clone script in the repo (needs its two secret variables).

Open (in order): Paid Apps Agreement + bank + tax → Apple `.p8` key (APNs +
Sign in with Apple) → Firebase APNs upload + Supabase `APPLE_*` secrets →
subscriptions + RevenueCat products → listing, privacy, age rating, pricing →
TestFlight test on iPhone → demo account + review notes + location video → submit.

## 0. Scope of iOS 1.0

- In: street recording, Ride Lab, rodadas, friends, Family Watch, off-road
  circuits/sessions viewer, GoPro control, Pro subscription, Google + Apple sign-in, push.
- Out: **Métrica logger** (BLE pairing / SD import). Hidden on iOS by
  `AppDistribution.allowsMetricaLogger`. Ships in 1.1 with a pairing video on a
  real iPhone. When it comes back, also restore the Métrica wording in the
  Bluetooth usage strings (`Info.plist` and `es.lproj/InfoPlist.strings`).
- iOS has no app-run 30-day trial and no partner codes (guideline 3.1.1). The
  trial is the subscription's **introductory offer** in App Store Connect.

## 1. Accounts and agreements (blocks everything with money)

- [ ] App Store Connect → Business → **Paid Apps Agreement** signed, **bank
      account** and **tax forms** (W-8BEN / Mexico) active. Subscriptions cannot
      be sold or even tested in production until this is green.

## 2. Apple Developer portal

- [ ] Identifiers → `com.rawthrottle.riderlab` → **Push Notifications** and
      **Sign in with Apple** (Enable as primary App ID) → Save.
- [ ] Keys → **+** → one key with **Apple Push Notifications service (APNs)**
      and **Sign in with Apple** (configure → primary App ID
      `com.rawthrottle.riderlab`). Download the `.p8` once; note **Key ID**.
      Team ID: `886UT95Y7R`.

## 3. Firebase / Supabase

- [ ] Firebase → Project settings → Cloud Messaging → iOS app → upload the
      APNs `.p8` (Key ID + Team ID).
- [x] Supabase → Authentication → Providers → **Apple** → Enable, Client IDs:
      `com.rawthrottle.riderlab` (native flow; no Services ID needed).
- [ ] Supabase → Edge Functions → Secrets (Apple token revocation on account
      deletion, guideline 5.1.1(v)):

      APPLE_TEAM_ID=886UT95Y7R
      APPLE_KEY_ID=<key id from step 2>
      APPLE_PRIVATE_KEY=<full .p8 contents, BEGIN/END lines included>

- [x] Deploy: `supabase functions deploy delete-account --remote=eabhnmlfsfibgwkspqwa` (CLI v3).

## 4. Subscriptions (App Store Connect → RiderLab → Subscriptions)

- [ ] Group **RiderLab Pro**. Group display name (es-MX): `RiderLab Pro`.
- [ ] `riderlab_pro_monthly`, 1 month, MX$59. Display name `Pro mensual`;
      description `Todas las funciones Pro de RiderLab.`
- [ ] `riderlab_pro_yearly`, 1 year, MX$499. Display name `Pro anual`;
      description `Todas las funciones Pro de RiderLab, pago anual.`
- [ ] Each product: **Review screenshot** (the paywall on an iPhone) and review
      note: `Unlocks Pro features (Ride Lab detail, hardware integrations). Open Settings → RiderLab Pro.`
- [ ] **Introductory offer → Free trial** on both (e.g. 1 month, new subscribers).
- [ ] App Store Connect → App Information → **App-Specific Shared Secret** /
      In-App Purchase key for RevenueCat.

## 5. RevenueCat

- [ ] Project → **+ App** → App Store, bundle `com.rawthrottle.riderlab`,
      In-App Purchase key (`.p8`) uploaded.
- [ ] Products: import both ids. Entitlement **`pro`** with both attached.
- [ ] Offering **`default`**: `$rc_monthly` → monthly, `$rc_annual` → yearly.
- [ ] Public iOS key (`appl_…`) in `apps/mobile/.env` as `REVENUECAT_API_KEY_IOS`
      (already set locally; also in the `MOBILE_ENV_IOS` GitHub secret if CI builds).

## 6. App Store listing (version 1.37.25)

Primary language **Spanish (Mexico)**; add **English (U.S.)**.

| Field | es-MX | en-US |
|---|---|---|
| Name (30) | `RiderLab` | `RiderLab` |
| Subtitle (30) | `Trazada GPS y lean para moto` | `GPS line & lean for riders` |
| Promotional text (170) | `Graba tu rodada con el teléfono guardado y revisa tu trazada, inclinación y frenadas al terminar.` | `Record your ride with the phone stowed, then review your line, lean and braking when you stop.` |
| Keywords (100) | `moto,motocicleta,gps,inclinación,rodada,circuito,pista,trazada,motociclista,ruta,telemetría` | `motorcycle,gps,lean angle,track,ride,circuit,rider,route,telemetry,motorbike` |

Description (es-MX):

```
RiderLab graba la trazada GPS y la inclinación de tu moto para que revises cada curva al terminar, no mientras manejas.

• Graba con el teléfono en la chamarra o en la moto; sigue grabando con la pantalla bloqueada
• Ride Lab: mapa, inclinación, frenadas y consejos sobre la línea que realmente tomaste
• Rodadas: invita a tus amigos, comparte la ruta y rueden juntos
• Family Watch: tu familia ve dónde vas durante una rodada que tú compartes
• Circuitos off-road con perfil de elevación por sector
• Control opcional de cámara GoPro durante la rodada

RiderLab Pro (suscripción mensual o anual) desbloquea el análisis completo y las integraciones de hardware. El pago se cobra a tu cuenta de Apple ID y se renueva automáticamente salvo que lo canceles al menos 24 horas antes del fin del periodo, desde los Ajustes de tu cuenta.

No uses el teléfono mientras manejas. El análisis es para después de detenerte.

Términos: https://riderlab.rawthrottle.com.mx/legal/terms.html
Privacidad: https://riderlab.rawthrottle.com.mx/legal/privacy.html
```

Description (en-US):

```
RiderLab records your motorcycle's GPS line and lean angle so you can review every corner after the ride, not while riding.

• Record with the phone in your jacket or on the bike; it keeps recording with the screen locked
• Ride Lab: map, lean, braking and coaching on the line you actually took
• Rodadas (group rides): invite friends, share the route, ride together
• Family Watch: your family sees where you are during a ride you share
• Off-road circuits with an elevation profile per sector
• Optional GoPro camera control during the ride

RiderLab Pro (monthly or yearly subscription) unlocks full analysis and hardware integrations. Payment is charged to your Apple ID and renews automatically unless cancelled at least 24 hours before the end of the period in your account Settings.

Do not interact with the phone while riding. Analysis is for after you stop.

Terms: https://riderlab.rawthrottle.com.mx/legal/terms.html
Privacy: https://riderlab.rawthrottle.com.mx/legal/privacy.html
```

- [ ] Screenshots 6.9" (1320×2868): `docs/store/appstore/01…05-*.png`.
- [ ] Support URL `https://riderlab.rawthrottle.com.mx/soporte/` · Marketing
      `https://riderlab.rawthrottle.com.mx/` · Privacy
      `https://riderlab.rawthrottle.com.mx/legal/privacy.html`.
- [ ] Terms of Use (EULA): App Information → License Agreement → custom, or
      keep Apple's standard EULA and link the terms in the description (done above).
- [ ] Category: **Navigation** (secondary **Sports**). Copyright: `2026 Raw Throttle`.
- [ ] Version: change the prepared version from 1.0 to **1.37.25**.

## 7. App Privacy (nutrition labels)

Mirrors Play Data safety. Tracking: **No** (no ads SDK, no data broker).

| Data type | Linked to user | Purpose |
|---|---|---|
| Precise Location | Yes | App Functionality |
| Name, Email Address | Yes | App Functionality (account) |
| User ID | Yes | App Functionality |
| Photos or Videos | Yes (only if added to a rodada) | App Functionality |
| Other User Content (rodada radio messages) | Yes | App Functionality |
| Purchase History | Yes (RevenueCat / StoreKit) | App Functionality |
| Crash Data / Diagnostics | Only if enabled; otherwise "not collected" | App Functionality |

Account deletion: in-app Settings → Delete account (also
`https://riderlab.rawthrottle.com.mx/legal/delete-account.html`).

## 8. Age rating

Answer the questionnaire honestly; expected result **18+** (motor vehicle use,
user-generated content: rodada radio + photos). UGC requirements (guideline 1.2)
already exist in-app: rules, report, staff hide/ban, support contact.

## 9. Pricing and availability

- [ ] Price: **Free** (Pro via subscription).
- [ ] Availability: all countries **except the EU** until the DSA trader
      declaration is filed (App Store Connect → Business → Compliance).

## 10. Build and TestFlight

Either path gives the same signed IPA:

- **Local Mac** (Xcode 26.2 on Juans-Laptop): `ios/Runner/GoogleService-Info.plist`
  present, Apple ID with Admin/App Manager signed into Xcode → Settings → Accounts.

      cd apps/mobile
      flutter build ipa --release --dart-define=DISTRIBUTION=appstore
      open build/ios/archive/Runner.xcarchive   # Organizer → Distribute → App Store Connect

- **Xcode Cloud** (already connected to the repo, builds `master`):
  `apps/mobile/ios/ci_scripts/ci_post_clone.sh` installs Flutter 3.47.1 and
  generates the Flutter/CocoaPods files. In the workflow → Environment add
  secret variables `MOBILE_ENV_IOS_B64` and `GOOGLE_SERVICE_INFO_PLIST_B64`
  (`base64 -i <file> | pbcopy`). Build numbers are `CI_BUILD_NUMBER + 200`.

- **GitHub Actions**: add the 6 secrets in IOS_TESTFLIGHT.md (none are loaded
  yet), then Actions → ios-testflight → Run workflow with `--ref ios/appstore-release`.

On a **real iPhone** via TestFlight, verify:

- [ ] Permission prompts in Spanish (location, motion, camera, photos, Bluetooth, notifications).
- [ ] Record → lock screen → ride 5 min → line complete ("Always" two-step flow).
- [ ] No crash on Ride Lab / barometer.
- [ ] Push: a rodada invite arrives; a `device_tokens` row with platform `ios` exists.
- [ ] Sign in with Apple, then Google, then sign out.
- [ ] Paywall shows both plans with prices; sandbox purchase unlocks Pro; Restore works.
- [ ] Settings → M5 Logger and the off-road "Métrica" action are **not** shown.
- [ ] Delete an Apple-sign-in test account: Apple confirmation sheet appears; the
      function log shows no `apple revoke failed`; the account is gone.

## 11. App Review information

- [ ] Sign-in required: provide a demo account (email + password) with sample
      rides and a rodada. Create it in Supabase before submitting.
- [ ] Notes (paste):

```
RiderLab is a motorcycle ride recorder. Riders start a ride, put the phone away, and review the GPS line, lean angle and braking after stopping.

Background location ("Always"): only used while a ride is recording or while the rider has turned on Auto-arm, so recording continues with the screen locked and the phone stowed. The app first asks for "While Using" when the rider taps Record, and only offers "Always" later with its own explanation screen. Location is never used for ads or tracking.

Demo account: <email> / <password>. It has sample rides (Rides tab → any ride → Ride Lab) and a group ride.

Pro: Settings → RiderLab Pro shows the subscriptions (monthly / yearly, introductory free trial). Restore Purchases is on the same screen.

Bluetooth is only used to start/stop an optional GoPro camera; it is not required to review the app.

Do not interact with the phone while riding; analysis is post-ride.
```

- [ ] Attach a short screen recording of the location flow (Record → While
      Using → later "Always" explainer → system prompt → locked-screen recording).
- [ ] Contact: name, phone, `jvaldes.garcia@gmail.com`.

## 12. Submit and release

- [ ] Version page → Build → select 1.37.25 (101).
- [ ] **In-App Purchases and Subscriptions** section → add both subscriptions
      (first subscriptions must be submitted with an app version).
- [ ] Version Release → **Manually release this version**.
- [ ] Add for Review → Submit.
- [ ] After approval: Release → watch crash reports and RevenueCat for the first
      purchases. Then merge `ios/appstore-release` into `master` and tag `ios-1.37.25`.
