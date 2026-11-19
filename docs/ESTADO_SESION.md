# Estado para retomar (19 nov 2026)

Hecho en la Mac de Juan. Al abrir el repo en otra máquina, partir de la rama `android/play-no-trial`.

## Dónde quedó el código

- Rama: `android/play-no-trial`.
- Commit de producto: quita la prueba Pro de 30 días sin tarjeta. Android exige suscripción de Play desde el día 1. Versión `1.37.26+103` (`apps/mobile/pubspec.yaml`).
- La migración `supabase/migrations/20261113010000_remove_pro_trial.sql` ya se aplicó en producción. No volver a correrla.
- `offersOwnProTrial` es `false`. Un periodo `trial` legado no desbloquea Pro. Los identificadores no cambiaron: `riderlab_pro_monthly`, `riderlab_pro_yearly`, entitlement `pro`, offering `default` con `$rc_monthly` y `$rc_annual`.
- En iPhone la única prueba posible sigue siendo la oferta introductoria de App Store. Los códigos de socio siguen en Android.
- El script de build es `apps/mobile/tool/release_play.sh`. Analyze y el test de Pro pasaron el 12 nov 2026.

## Qué no viaja en git

- El AAB firmado está solo en esa Mac: `dist/RiderLab-1.37.26-103.aab` (73 MB). `dist/` está en `.gitignore`. En la otra máquina, con `apps/mobile/.env` y el keystore, correr `sh apps/mobile/tool/release_play.sh`.
- `apps/mobile/.env` no se sube. Ahí está `REVENUECAT_API_KEY_IOS` (`appl_`) y `REVENUECAT_API_KEY_ANDROID` (`goog_`). Sin la clave de Android el build de Play no arranca RevenueCat.
- No subir `key.properties` ni el keystore.

## Publicar la 103 (aún no hecho)

Play Console, paquete `com.rawthrottle.riderlab`. No se subió el AAB.

1. Perfil de pagos activo.
2. Suscripciones activas: mensual MX$59 y anual MX$499, con esos identificadores.
3. RevenueCat: app Play del mismo paquete, ambos productos en el entitlement `pro`, offering current `default`.
4. Subir el AAB primero a prueba interna, no a producción. Notas en `apps/mobile/play/whatsnew/`.
5. Compra de prueba con un Gmail de licencias. Si cobra y restaurar deja Pro, promover el mismo AAB.
6. Ficha: compras dentro de la app sí; historial de compras en Seguridad de los datos; la app sigue sin anuncios y en precio Gratis.

## Cuenta de revisión

Usuario de Supabase, auto-confirmado: `riderlab.review@gmail.com`. La contraseña no está en git. Pegarla en Play Console → Sign in details y en App Store Connect → Demo account. Nombre: RiderLab review account.

## Sitio Azure

Páginas estáticas en la cuenta `riderlabdeck`, grupo `rg-nkmoto`, contenedor `$web`. Dominio `https://riderlab.rawthrottle.com.mx`.

| Qué | Fuente | Script |
|---|---|---|
| Landing, /go, /simm, /soporte | `docs/www/` | `scripts/deploy-www.ps1` |
| Legal | `docs/legal/` | `scripts/deploy-legal.sh` |
| Reset de contraseña | `docs/auth/` | `scripts/deploy-auth-reset.ps1` |
| Family Watch | `docs/watch/` | `scripts/deploy-watch.ps1` |
| Tienda | `docs/shop/` | `scripts/deploy-shop.ps1` |

El 12 nov 2026 se publicaron los Términos (ya sin la prueba de 30 días en Android), más privacy y delete-account, con `scripts/deploy-legal.sh`.

## Otras ramas

- `ios/appstore-release` está en origin en `c4c2e8b`: Prototipo 2, carril `metrica/hardware-alternativo`, y el lab de GPS / Circuito 8h oculto en builds de tienda.
- El mapeador de circuito con perímetro interior y exterior está en `consolidate/2026-11`, no en esta rama.
- Métrica (pareo BLE) sigue fuera de iOS 1.0.
