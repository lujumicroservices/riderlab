---
name: riderlab-deploy-web
description: Publish RiderLab's static web pages (landing, /go, /soporte, legal, password reset, Family Watch, merch shop) to Azure Storage static websites. Use when the user asks to deploy/publicar/subir the website, legal pages, terms, privacy, delete-account, reset-password page, watch page or tienda, or after editing anything under docs/www, docs/legal, docs/auth, docs/watch or docs/shop.
---

# RiderLab web deploy (Azure)

Hosting is Azure Storage `$web` — this stays (no migration planned). Cloudflare is only DNS for `rawthrottle.com.mx`.
- Main account `riderlabdeck`, resource group `rg-nkmoto` → https://riderlab.rawthrottle.com.mx
- Shop origin `rawthrottlesite` → https://rawthrottlesite.z21.web.core.windows.net/
- Supabase project ref `eabhnmlfsfibgwkspqwa`

| Page | Source | Script (run from repo root) | Extra requirements |
|---|---|---|---|
| Landing, /go, /simm, /soporte, /partners | `docs/www/` | `scripts/deploy-www.ps1` | Python 3 + `qrcode[pil]`; reads `docs/www/store.json` and anon key from `apps/mobile/.env` |
| Legal (privacy, terms, delete-account, age) | `docs/legal/` | `scripts/deploy-legal.ps1` (`.sh` twin on macOS) | — |
| Password reset | `docs/auth/` | `scripts/deploy-auth-reset.ps1` | `supabase` CLI logged in |
| Family Watch | `docs/watch/` | `scripts/deploy-watch.ps1` | `supabase` CLI logged in |
| Merch shop | `docs/shop/` | `scripts/deploy-shop.ps1` | — |
| DNS → shop | — | `scripts/cf-point-shop.ps1` | `.env.cloudflare`; **changes live DNS, confirm first** |

## Procedure
1. Show the user `git diff --stat` for the source folder so they know what goes live.
2. Check `az account show` succeeds (otherwise ask the user to run `az login`). For auth/watch also `supabase projects list`.
3. Deploying is outward-facing: confirm with the user before running the script unless they already said "deploy".
4. Run with `powershell -ExecutionPolicy Bypass -File scripts/<script>.ps1`.
5. Verify: fetch the public URL(s) and check status 200 + the changed text is present (Azure static sites can cache briefly).
6. If legal pages changed, remind about Play Console (Data safety → delete account URL) and App Store Connect privacy URL. If `/soporte` changed, it is the App Store support URL.

Never echo storage keys, anon keys or the Cloudflare token; the scripts already avoid printing them. `infra/azure/lean-replay` is a separate app — not covered here.
