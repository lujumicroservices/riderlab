# RiderLab iOS → TestFlight desde GitHub Actions (sin Mac local)

Flujo: `.github/workflows/ios-testflight.yml`. Corre en una Mac de GitHub (`macos-26`, Xcode estable),
**solo a mano** (Actions → ios-testflight → Run workflow). Nunca corre en push.

- `upload_to_testflight = false` (por defecto): compila, firma y deja el `.ipa` como artefacto (14 días).
- `upload_to_testflight = true`: además lo sube a App Store Connect / TestFlight.
- `build_number`: vacío = `run_number + 100` (master está en `1.37.24+99`; ASC ya tiene el build 75).
  La versión visible sale de `pubspec.yaml` (`1.37.24`); la versión 1.0 de la ficha en ASC debe cambiarse a esa.

## Cómo firma
`flutter build ios --config-only --no-codesign` y luego `xcodebuild archive` + `-exportArchive` con
`-allowProvisioningUpdates` y la llave de API de App Store Connect (firma automática en la nube).
No hace falta fastlane ni subir certificados: Xcode crea/descarga el certificado de distribución y el perfil.
Con `upload_to_testflight` el export usa `destination=upload` y sube directo con la misma llave.

## Secretos de GitHub (solo nombres; nunca en el repo)
| Secreto | Qué es |
|---|---|
| `APP_STORE_CONNECT_API_KEY_ID` | Key ID de la llave de API (ASC → Users and Access → Integrations → App Store Connect API) |
| `APP_STORE_CONNECT_ISSUER_ID` | Issuer ID de esa misma pantalla |
| `APP_STORE_CONNECT_API_KEY_P8` | `AuthKey_XXXX.p8` en base64 (`base64 -i AuthKey_XXXX.p8` / PowerShell: `[Convert]::ToBase64String([IO.File]::ReadAllBytes("AuthKey_XXXX.p8"))`) |
| `APPLE_TEAM_ID` | Team ID (developer.apple.com → Membership) |
| `GOOGLE_SERVICE_INFO_PLIST` | `GoogleService-Info.plist` de la app iOS en Firebase, en base64. El flujo falla con mensaje claro si falta o si el BUNDLE_ID no es `com.rawthrottle.riderlab` |
| `MOBILE_ENV_IOS` | Contenido completo de `apps/mobile/.env` para iOS (si no existe se usa `MOBILE_ENV`). `GOOGLE_IOS_CLIENT_ID` es obligatorio; `REVENUECAT_API_KEY` debe ser la clave `appl_` mientras el código no lea `REVENUECAT_API_KEY_IOS` |

## Qué cambió en esta rama (decisiones 1–5 del paquete App Store)
- `Info.plist`: `NSMotionUsageDescription` (evita el crash de `sensors_plus`/barómetro), `ITSAppUsesNonExemptEncryption = false`,
  textos de ubicación "Siempre" del paquete §9, sin `UISupportedInterfaceOrientations~ipad`. `remote-notification` **se mantiene** (push va en 1.0).
- `es.lproj/InfoPlist.strings`: textos de permisos es-MX, agregado al proyecto como variant group (región `es`) en Resources de Runner.
- `project.pbxproj`: `TARGETED_DEVICE_FAMILY = 1` (solo iPhone), `CODE_SIGN_ENTITLEMENTS = Runner/Runner.entitlements`,
  referencia a `Runner/GoogleService-Info.plist` en Resources de Runner (el archivo sigue en `.gitignore`; el flujo lo escribe desde el secreto).
- `Runner/Runner.entitlements`: `aps-environment = production` y `com.apple.developer.applesignin = [Default]`.
- `ios/ExportOptions.plist`: `app-store-connect`, firma automática, `teamID` placeholder que el flujo sustituye.

> Para compilar en una Mac local hay que poner un `GoogleService-Info.plist` real en `ios/Runner/`: como está referenciado en el proyecto, sin él Xcode falla ("Build input file cannot be found"). Es intencional, para que nunca salga un build sin push.

## Pasos manuales de Juan (en este orden)
### 1. Portal de Apple Developer (Certificates, Identifiers & Profiles)
1. Identifiers → `com.rawthrottle.riderlab` → activar **Push Notifications** y **Sign in with Apple** (Enable as primary App ID) → Save.
   Los perfiles se regeneran solos con la firma automática del flujo.
2. Keys → **+** → activar **Apple Push Notifications service (APNs)** → descargar el `.p8` (solo se descarga una vez). Anotar **Key ID** y **Team ID**.
   (Para Sign in with Apple en Supabase hace falta otra llave con "Sign in with Apple" o la misma con ambos servicios, más un Services ID.)

### 2. App Store Connect
1. Users and Access → Integrations → App Store Connect API → generar llave (Team Key). Rol: **Admin** recomendado
   (la firma automática en la nube crea certificados de distribución; con **App Manager** puede fallar por permisos). Descargar `.p8`, anotar Key ID e Issuer ID.
2. Cambiar la versión 1.0 de la ficha a `1.37.24` (o la del build).

### 3. Firebase (proyecto donde ya está la app Android)
1. Agregar app → iOS → bundle `com.rawthrottle.riderlab`.
2. Project settings → Cloud Messaging → app iOS → **APNs Authentication Key**: subir el `.p8` de APNs con su Key ID y Team ID.
3. Descargar `GoogleService-Info.plist` (no lo agregues al repo).

### 4. GitHub (lujumicroservices/motoline → Settings → Secrets and variables → Actions)
Cargar los secretos de la tabla de arriba (plist y `.p8` en base64).

### 5. Correr y probar
1. Hacer push de la rama `ios/testflight-ci` (y mergear a master cuando se apruebe). `workflow_dispatch` solo aparece en Actions cuando el flujo está en la rama por defecto; mientras tanto se puede lanzar con `gh workflow run ios-testflight.yml --ref ios/testflight-ci`.
2. Correr con `upload_to_testflight = false`; si compila, correr con `true`.
3. En TestFlight, instalar en un **iPhone real** y probar: permisos en español, grabar con pantalla bloqueada ("Siempre"),
   barómetro sin crash, y **push** (invitación a rodada) — el simulador no recibe push.
   Revisar en Supabase que aparezca un registro en `device_tokens` con plataforma iOS.

## Alcance de la 1.0 iOS
- **Métrica (vinculación BLE) queda fuera de la 1.0 iOS; entra en 1.1 junto con un video de emparejamiento en iPhone real para App Review.**
  Esta rama sale de `origin/master` y no incluye `exp/gps-track-points` ni `cursor/metrica-ble-pairing-9627`; el permiso de Bluetooth solo menciona la cámara GoPro.

## Pendiente en código (no incluido en esta rama)
- **Sign in with Apple (código hecho en esta rama)**: paquete `sign_in_with_apple`, botón de Apple solo en iOS (primero, junto a Google, estilo de Apple),
  `signInWithIdToken(provider: apple)` con nonce (SHA-256 a Apple, nonce crudo a Supabase). Android sigue solo con Google.
  Falta configurar (Juan): Supabase → Authentication → Providers → **Apple** → Enable y en **Client IDs** poner `com.rawthrottle.riderlab`
  (para el flujo nativo no hace falta Services ID ni secreto; solo si algún día se usa Apple por web/OAuth). En el portal: capability Sign in with Apple en el App ID.
  Pendiente en código: revocar el token de Apple al borrar la cuenta (Edge Function `delete-account` con `/auth/revoke`; requiere authorization code + client secret firmado con una llave .p8 de Sign in with Apple).
- **Push iOS**: `AppDelegate.swift` no necesita cambios para lo básico — `firebase_messaging` registra APNs por swizzling y
  `Firebase.initializeApp()` sin opciones lee `GoogleService-Info.plist` del bundle. `push_notification_service.dart` ya pide permiso en iOS
  (`requestPermission`). Recomendado: llamar `FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true)`
  y, antes de `getToken()` en iOS, esperar `getAPNSToken()` (si no, el primer `getToken()` puede fallar con `apns-token-not-set`). El backend que envía FCM debe incluir bloque `apns` (sonido/alerta) para iOS.
- **Pro en iOS**: leer `REVENUECAT_API_KEY_IOS`, ocultar switch local de Pro y códigos de socio, no mostrar `start_pro_trial` en iOS (paquete §8.3).
- **Ubicación (hecho en esta rama)**: "Siempre" en dos pasos en iOS. Paso 1 "Al usar la app" al tocar Grabar / Armar auto / rodada (aviso propio + diálogo del sistema).
  Paso 2 "Siempre" solo al activar Armar auto o al terminar un recorrido, con pantalla propia (paquete §9.3) y luego el aviso único de iOS;
  "Ahora no" se recuerda (`ios_location_always_not_now`) y no se vuelve a pedir. Si está denegado, diálogo con "Abrir Ajustes". Android sin cambios.
  Pendiente: grabar el video para App Review (paquete §9.5) y pegar la nota §9.4.
