# Estado para retomar (20 nov 2026)

**Actualización 20 nov 2026 (PC Windows luju3):** el pase de usabilidad (PR #12) ya está en `master`. La release que sigue es **`1.37.27+104`** (rama `release/1.37.27-104`, PR #13), no la 103: la 103 nunca se subió. AAB firmado en esta PC: `dist/RiderLab-1.37.27-104.aab`. Se armó con el `.env` y el `google-services.json` del zip de Nextcloud, que trae la clave `goog_` de RevenueCat y los clientes OAuth. Los pasos de "Publicar la 103" de abajo aplican igual a la 104. CI: Flutter fijo en 3.41.4. Demo en video: `docs/DEMO_VIDEOS.md`.

## Estado anterior (19 nov 2026)

Hecho en la Mac de Juan. Al abrir el repo en otra máquina, partir de la rama `android/play-no-trial`.

Los archivos que no van en git (`.env`, keystore, Firebase, AAB) están en Nextcloud. Cómo restaurarlos: `TRASLADO.md` en la raíz.

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

## iOS (App Store)

- Build `1.37.25+102` subido y en TestFlight (rama `ios/appstore-release`). Guía paso a paso: `docs/APP_STORE_RELEASE.md`.
- Pendiente del lado de Juan: probar la 102 en TestFlight; en App Store Connect terminar privacidad, capturas (`docs/store/appstore/iphone-6.9-sim/`) y cuenta demo; enviar la 102 con lanzamiento manual.
- La 103 de Android quita la prueba sin tarjeta. iOS nunca la tuvo, así que no hay que reconstruir iOS por eso.
- Regla con Claude Desktop (computer use): no escribe contraseñas, no pulsa Submit/Agree/Publicar y no ve datos bancarios ni fiscales. Esos pasos los hace Juan.

## Prototipo 2 de Métrica (hardware)

- Doc: `hardware/PROTOTIPO_2.md`. BOM con ligas: `hardware/BOM_PROTOTIPO_2.md` (≈250 USD por unidad con breakouts sueltos).
- Base: ESP32 DevKitC-VE + batería LiPo propia. Caja de 150 × 70 × 30 mm.
- Carcasa elegida: **Faceta** (`hardware/prototipo2/cad/metrica_p2_v2_faceta.py`): cuña con 8.1° de inclinación al frente (22→32 mm), insertos M4 para bola RAM, conectores en la pared inferior.
- Decisión en curso: cambiar GNSS + IMU + BMP280 por el **M5Stack M135** (NEO-M9N + BMI270 + BMP280 + BMM150, 54×54×13.2 mm, ≈45 USD contra ≈100 USD).
  Hay 3 variantes en `hardware/prototipo2/m135/` (ver su README y `comparativa.png`):
  - A · Ancha 172 mm: cabe, 0 colisiones.
  - B · Profunda 150 mm, 32–42 mm: cabe, 0 colisiones (LiPo bajo el M135).
  - C · Feather V2: no cabe (10 colisiones).
  **Falta que Juan elija A o B.** Después: actualizar el BOM (quitar GPS-15712/SEN-22397/BMP280, agregar M135) y medir las placas reales para repetir el chequeo de colisiones.
- Opcionales: ajustar el orificio de la ventila en el CAD de Faceta; volver a renderizar los hero shots de Faceta con la geometría de 22 mm.
- Rama de Cursor `origin/metrica/hardware-alternativo-sin-pcb-estandar`: solo documentos (cadena de 69 LEDs). Se trajo a `ios/appstore-release` como `metrica/hardware-alternativo/`.

### Herramientas CAD (se reinstalan en cada máquina)

- CadQuery 2.8 en un venv de Python 3.12: `python3.12 -m venv ~/.venvs/motoline-cad && ~/.venvs/motoline-cad/bin/pip install cadquery trimesh Pillow numpy`.
- Blender 5.0.1 con el add-on de MCP. El servidor MCP está en `.mcp.json` (`uvx mcp-for-blender@2.2.7`, telemetría apagada). En Windows, cambiar la ruta de `uvx`.
- El skill `parametric-3d-printing` está en `.claude/skills/` y se carga solo en Claude Code.
- Para regenerar los renders: cada script indica en su encabezado cómo correrlo. El render se hace con `blender -b … --python render/eevee_setup.py` (EEVEE es rápido; Cycles solo para los hero shots).
- Los `.blend` sí están en git (≈87 MB en `m135/`). Si el repo pesa demasiado, moverlos a Git LFS.
