# RiderLab — Free vs Pro

Product contract. Recording and social stay free. Ride Lab depth is Pro. Pro is a **monthly or yearly store subscription**. There is **no app trial** (the old 30-day no-card trial was removed on 2026-11-13). Partners get 90 days via a single-use invitation code.

Resumen en español (Gratis, Pro, suscripción, socio): **[FREE_VS_PRO.es.md](FREE_VS_PRO.es.md)**.

Store checkout goes through RevenueCat (Play Billing / App Store). Sideload builds have no store billing: there, Pro comes only from a partner code (or the local test toggle when signed out). The paywall says so instead of failing silently.

Related: [STORE_READINESS.md](STORE_READINESS.md) (RevenueCat), [PLAY_PRODUCTION.md](PLAY_PRODUCTION.md) (no IAP on the current Play path), partner decks in [partner-deck/](partner-deck/).

## Principles

1. **Never lock recording or the garage.** The hook is “I rode, I have a line.” Ride-count caps train people to stop opening the app.
2. **Never lock social.** Friends, rodadas, live pack map, radio, photos, reels, and basic Family Watch are how the app spreads. Live safety share is not a paid extra in v1.
3. **Sell coaching depth, not the map.** Willingness to pay is “show me this corner / this brake / this stretch vs last weekend.”
4. **No app trial.** Pro starts with a subscription (Android requires a Play subscription from day one). Any free period is a store introductory offer shown in the store sheet, not an app-side trial. Riders whose old trial ended are plain Free: no "your Pro ended" message.
5. **Do not sell “no ads” until ads exist.** The Free banner is a placeholder, not AdMob. It is not a Pro benefit.
6. **Keep all recorded data after expiry.** Pro expires; rides and cloud copies stay. Analysis returns to Free depth.

## Always Free

Forever, including after a partner grant or subscription ends:

- Sign-in, profile, bike picker
- Start / arm / auto-pause / crash recovery / unlimited local rides
- Cloud sync of rides you recorded
- Ride overview: distance, time, max speed, max lean L/R, skill score
- Pilot-line map, speed colors, scrub, charts, gauge
- GPS quality chip and GPS precision stats (trust in the line)
- Straights / corners **list** (tap a curva → short teaser, then lock)
- Skill Lab overview + replay of the **highlighted** corner
- First **3** brake events
- Friends, peer bbox compare (your ride vs a friend’s shared ride)
- Rodadas: create/join by **ride** invite code (e.g. `TAP42A`), live map, radio, photos, reels
- Family Watch: circle + live share link
- ES/EN

Rodada invite codes are **group-ride join**. They are not Pro grants.

## Pro

Active when any entitlement period is live (partner or paid). Same Ride Lab gates:

| Feature | Status | Why |
|---|---|---|
| Segment zoom / pick stretch | **Pro** | Highest-intent power feature |
| Full brake list + zoom-to-brake | **Pro** (Free sees first 3) | Clear teaser → upgrade |
| Full corner detail (entry/apex/exit) | **Pro** + teaser | Natural next tap after a good ride |
| GPS quality chip / precision stats | **Free** | Trust in the line, not a paid extra |
| Riding / coach notes (when present) | **Pro** | Coaching, not telemetry hygiene |
| “No ads” | **Not a Pro benefit** until AdMob is real | Placeholder banner must not be sold as value |
| Named routes + loop auto-lap | **Pro when unpaused** | Track-day value; do not give it away Free |
| Deep compare (vs own best / same named route overlay) | **Pro when routes return** | Bbox friend compare stays Free |
| GoPro shutter | **Lab** until reliable, then Pro | Hardware users pay; flaky labs are not a paid SKU |
| Family Watch history / extra contacts | **Later Pro**, not v1 | Do not paywall live safety now |
| Cloud history cap | **Not in v1** | Optional later (e.g. Free cloud = last 90 days; local unlimited). No ride-count cap. |

## No trial

There is no app trial. Removed 2026-11-13 (server migration `20261113010000_remove_pro_trial`); a cached or legacy `trial` period never unlocks Pro in the app.

- New riders are Free until they subscribe or redeem a partner code.
- Riders who used the old trial are plain Free. They do **not** see an expired-Pro message.
- The expired message ("Your Pro ended. Subscribe to get … back.") is only for riders whose partner code or paid subscription actually lapsed.
- After expiry: same screens, same teasers. Rides are never deleted.

## Partner — 3 months via single-use invitation code

Staff-issued. Distinct from rodada join codes.

**Rules**

- Unique codes (e.g. `PRO-7K4M2Q`). One code → one account → **90 days full Pro**.
- Redeem in Settings (field + paste from share link). Invalid / already used / this account already redeemed a partner code → clear error.
- **One partner grant per account.** No stacking 3+3+3.
- Pro end becomes `max(current_pro_end, now + 90 days)` so a longer existing period is never shortened.
- If they are **already paying**, do **not** consume the code; tell them it is unused so they can give it to someone else.
- Copy: “Partner Pro code” vs “Rodada invite.”

**Who gets codes:** dealerships / brand partners / press — issued by you, not self-serve.

## Paid subscription

Single entitlement id: `pro` (RevenueCat).

Packages:

- Monthly
- Yearly (default in the upgrade sheet; about two months free vs monthly)

The Pro sheet shows each package's price and period from the store, a "Restore purchases" button on store builds, and the auto-renew / cancel-anytime disclosure. A user cancel in the store sheet is not an error.

No lifetime SKU at launch (refunds and account sharing). No family plan until Family Watch is a paid surface.

Price (MXN + USD) lives in the stores; see APP_STORE.md.

## Entitlement model

Source of truth leaves the phone. Today `isPro` is local prefs or RevenueCat CustomerInfo only — partner grants cannot be trusted on-device.

Logical periods (any active ⇒ Pro):

| source | duration | starts |
|---|---|---|
| `partner` | 90 days | redeem |
| `revenuecat` | store period | purchase / restore |

Client keeps a boolean `isPro`. Server (Supabase) stores periods so staff impersonation, new devices, and sideload builds agree.

Partner codes (conceptual): `code` (unique), `duration_days=90`, `redeemed_by`, `redeemed_at`, `partner_label`, `created_by`. Single-use = `redeemed_by IS NULL`.

RevenueCat **promotional entitlements** can mirror partner grants so Play and sideload stay in one CustomerInfo when billing is on. Until the API key is live, Supabase periods are enough for pilots.

## Engineering

Implemented in-app + Supabase (apply migration `20260824010000_pro_entitlements.sql`):

1. Tables `promo_codes` + `entitlement_periods`; RPCs `my_pro_status`, `start_pro_trial`, `redeem_partner_code`, `staff_create_partner_code`
2. Trial removed (`20261113010000_remove_pro_trial`); `start_pro_trial` is no longer called
3. Settings redeem UI + remaining-days copy; staff can mint single-use codes
4. RevenueCat packages (yearly first) when `REVENUECAT_API_KEY` is set; without it the paywall explains that subscriptions are only in the store version
