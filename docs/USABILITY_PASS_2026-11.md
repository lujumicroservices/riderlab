# Pase de usabilidad — noviembre 2026

Rama: `android/usability-pass` (sale de `android/play-no-trial`).
Origen: revisión del código y recorrido en emulador de la v1.37.26 (sideload) con una cuenta Free que antes tuvo trial.

Cada bloque tiene dueño de archivos para poder trabajarse en paralelo sin pisarse.

## Bloque 1 — Ajustes con submenús

Archivos: `lib/features/settings/**`, `lib/widgets/account_auth_section.dart`.

- [x] `SettingsScreen` pasa a ser un índice: tarjeta de perfil (alias, correo, Free/Pro) + filas con subtítulo de estado.
- [x] Submenús, cada uno en `lib/features/settings/sections/`:
  - Cuenta: alias, correo, cerrar sesión, borrar cuenta.
  - RiderLab Pro: estado, suscribirse o gestionar, Restaurar compras siempre visible en builds de tienda, código de socio u oferta.
  - Grabación: sonido del modo, mostrar el botón de forzar inicio.
  - Rodadas y privacidad: armar ruta al iniciar, compartir ubicación en rodada, círculo familiar, compartir línea, link para familia.
  - Datos y sincronización: sincronizar ahora y última sincronización.
  - Idioma: lista Español / English.
  - Accesorios: M5 Logger y cámara GoPro.
  - Legal y ayuda: términos, privacidad, normas de comunidad, versión.
  - Laboratorio (solo sideload o staff): Lean Lab, IMU Lab, Circuito 8h, diagnóstico push.
  - Staff (solo staff): suplantar usuario, cola de reportes, códigos de socio.
- [x] Quitar el Circuito 8h duplicado y el logo grande de Ajustes.
- [x] Textos "Pack = …" / "El pack y familia usan estos interruptores" reescritos en lenguaje de usuario.

## Bloque 2 — Grabación y permisos

Archivos: `lib/features/ride_active/**`, `lib/core/services/location_service.dart`, `lib/core/services/ride_recorder.dart` (solo textos de notificación), `lib/core/services/arm_foreground_service.dart`, `lib/core/notifications/push_notification_service.dart`.

- [x] Terminar recorrido = mantener presionado ~1 s con anillo de progreso (bandera, botón Terminar y banner "¿Sigues rodando?"); objetivos de 56 dp o más; la bandera lleva texto.
- [x] Aviso al terminar ("Recorrido guardado" o "Sesión cancelada, no hubo movimiento").
- [x] Atrás durante la grabación: aviso "Mantén presionado Terminar para salir".
- [x] HUD: velocidad como dato principal y grande; "Puntos" y "Presión" solo en sideload; etiquetas que no se corten.
- [x] Barra inferior respeta el área segura (no la tapa la barra de gestos).
- [x] Cancelar durante el calentamiento del GPS.
- [x] Permisos: una sola explicación antes de calibrar, que pide ubicación, notificaciones y batería en orden; el texto explica los dos pasos de Android ("Mientras se usa la app", luego "Permitir todo el tiempo" en Ajustes); diálogo con "Abrir ajustes" también en Android; motivo real (GPS apagado, denegado, denegado para siempre).
- [x] No volver a mostrar la explicación en cada inicio si el usuario ya decidió no dar "todo el tiempo".
- [x] El permiso de notificaciones deja de pedirse al abrir la app; se pide en el flujo de la primera rodada.
- [x] Notificación fija de grabación y de "armado" en el idioma de la app.
- [x] Hoja de calibración: texto claro y consistente con el botón.

## Bloque 3 — Pro, muro de pago e inicio de sesión

Archivos: `lib/features/pro/**`, `lib/core/pro/**`, `lib/widgets/pro_upsell.dart`, `lib/widgets/ad_banner.dart`, `lib/providers/pro_entitlement_provider.dart`, `lib/features/auth/**`, `docs/FREE_VS_PRO*.md`.

- [x] `expiredAfterGrant` deja de contar `trialUsed`; sin franja "Se acabó tu Pro" para usuarios del trial viejo.
- [x] Texto de Pro vencido: "Tu Pro terminó. Suscríbete para recuperar …".
- [x] El botón Pro del banner de curva abre la hoja de Pro (con precio) en lugar de comprar directo.
- [x] Cancelar la compra ya no se reporta como error; "Pasar a Pro" nunca falla en silencio.
- [x] Hoja de Pro: precio y plan cuando la tienda los da; Restaurar compras visible en builds de tienda.
- [x] `ProTeaserGate` muestra el candado desde el inicio (sin mostrar y luego desenfocar).
- [x] Sin "Quita anuncios con Pro" en sideload.
- [x] Limpiar restos de trial: claves sin uso, `proToggleHelp`, docs FREE_VS_PRO.
- [x] Inicio de sesión: quitar "Así también entra la revisión de las tiendas"; campos con borde/fondo; "Crear cuenta" como modo propio con confirmar contraseña; error junto al campo.

## Bloque 4 — Home y detalle del recorrido

Archivos: `lib/features/home/**`, `lib/features/ride_detail/**`, `lib/widgets/mode_toggle.dart`, `lib/widgets/rider_alias_chip.dart`.

- [x] Descartar recorrido recuperado pide confirmación; "Guardar línea" maneja errores.
- [x] Íconos de Rodadas y Amigos con etiqueta o tooltip.
- [x] Fila del recorrido traducida (fecha local, "máx", "incl.").
- [x] Unidades en Rendimiento (km/h).
- [x] Interruptor ON/OFF → "Calle / Pista", 48 dp, bloqueado durante la grabación.
- [x] Abajo en Home, una sola franja Pro/anuncio a la vez.
- [x] Diálogo de borrar: "Cancelar" en lugar de "Ahora no".
- [x] Detalle: título completo, mapa antes de Compartir, Compartir traducido, leyenda con km/h y sin la lista de colores, filtros con indicio de scroll, texto de ayuda claro, sin "0/100" rojo en recorridos vacíos, atrás coherente.

## Bloque 5 — Errores y textos (después de los bloques 1–4)

- [x] Reemplazar los `'$e'` mostrados al usuario por `userFacingError` o mensajes accionables.
- [x] "Resumir detección" → "Reanudar detección"; "Empezar a Rodar" → "Empezar a rodar".
- [x] Textos fijos sin l10n (M5 Logger, pantalla de hardware, ON/OFF).

## Verificación

- `flutter gen-l10n`, `flutter analyze`, `flutter test`.
- Recorrido en emulador: inicio de sesión, Home, iniciar y terminar sesión, detalle, muro de pago, Ajustes.

## Estado (2026-11-20)

Bloques 1–5 implementados. `flutter analyze`: 0 errores, 25 avisos (igual que antes). `flutter test`: 295 pasan.
Probado en emulador (sideload): Home, Ajustes y submenú Pro, hoja de Pro, flujo de permisos desde cero, calibración, sesión armada, terminar con mantener presionado (con aviso), detalle del recorrido.

Pendiente / no verificado:
- Grabar una rodada real con movimiento (aviso "Recorrido guardado", HUD con velocidad).
- Hoja de Pro en build de Play con precios reales de RevenueCat y "Restaurar compras".
- Pantalla de inicio de sesión nueva (modo crear cuenta, logo de Google): cubierta por tests, no vista en emulador.
- `lib/widgets/visibility_selector.dart` (pantalla de rutas) y `ShareVisibility.label` siguen en inglés.
- La notificación de un recorrido recuperado antes de abrir una pantalla de grabación sigue en inglés.
- Claves ARB sin uso que se pueden borrar: `proTrialDaysLeft`, `startTrialHelp`, `removeAdsWithPro`, `adPlaceholder`, y los textos viejos de Rodadas reemplazados en Ajustes.
- La "última sincronización" en Ajustes solo vive en memoria durante la sesión.
- Códigos de razón de invitaciones push (invite_push_feedback) se muestran tal cual.
