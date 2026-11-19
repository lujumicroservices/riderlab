# Archivos que no van en git

Para trabajar en otra computadora necesitas archivos que no están en git: claves, el keystore de firma y builds firmados.
Están en Nextcloud, en `Proyectos/RiderLab/secretos/motoline-secretos.zip`. El zip contiene la carpeta `motoline-secretos/`, con las mismas rutas que en el repo.

Nunca subas estos archivos a git. Ya están en `.gitignore`.

| Archivo | Para qué sirve |
|---|---|
| `apps/mobile/.env` | Supabase, RevenueCat (`REVENUECAT_API_KEY_IOS`, y `REVENUECAT_API_KEY_ANDROID` cuando exista) y las demás claves de la app |
| `apps/mobile/android/upload-keystore.jks` | Firma de subida de Play. Si se pierde, hay que pedirle a Google que reemplace la clave de subida |
| `apps/mobile/android/key.properties` | Contraseñas y alias del keystore |
| `apps/mobile/android/app/google-services.json` | Firebase para Android |
| `apps/mobile/ios/Runner/GoogleService-Info.plist` | Firebase para iOS |
| `dist/RiderLab-1.37.26-103.aab` | AAB firmado de la versión 103 de Play, todavía sin subir. También se puede volver a armar con `sh apps/mobile/tool/release_play.sh` |
| `SHA256SUMS` | Hashes para comprobar que la copia llegó completa |

## Restaurar en la otra máquina

```bash
git clone <repo> motoline && cd motoline
git checkout android/play-no-trial
# descarga motoline-secretos.zip de Nextcloud a ~/Downloads
unzip ~/Downloads/motoline-secretos.zip -d /tmp
(cd /tmp/motoline-secretos && shasum -a 256 -c SHA256SUMS)
rsync -a --exclude SHA256SUMS /tmp/motoline-secretos/ ./
rm -rf /tmp/motoline-secretos
```

Después lee `docs/ESTADO_SESION.md`. Ahí está dónde quedó el trabajo y qué falta.

## No hay que copiarlo (se regenera)

- `apps/mobile/android/local.properties`, `gradlew` y `GeneratedPluginRegistrant.*`: se crean al correr `flutter pub get` y el primer build.
- `supabase/.temp/`: se crea al correr `supabase link`.
- Herramientas de CAD (venv de CadQuery, Blender MCP): las instrucciones están en `docs/ESTADO_SESION.md`.

## Al actualizar

Si cambias `.env` (por ejemplo, al agregar la clave `goog_`) o armas un AAB nuevo, vuelve a generar el zip y súbelo a Nextcloud en la misma ruta. Luego actualiza la tabla de arriba.
