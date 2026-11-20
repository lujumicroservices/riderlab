# RiderLab — Gratis vs Pro (resumen)

Contrato corto en español. Detalle de producto: [FREE_VS_PRO.md](FREE_VS_PRO.md).

Grabar y lo social se quedan **gratis**. Lo que se cobra es **profundidad del Ride Lab** (zoom de tramo, frenadas completas, detalle de curva).

Pro es una **suscripción mensual o anual** en la tienda. **No hay prueba** (la prueba de 30 días sin tarjeta se quitó el 2026-11-13). Un código de socio da 90 días de Pro. En sideload no hay compras en tienda: ahí Pro solo llega con código de socio.

---

## Gratis (siempre)

Incluye después de que termine un código de socio o la suscripción:

- Cuenta, perfil, moto
- Grabar sin límite, pausa automática, recuperar si se cierra la app
- Garage local + sync a la nube de **tus** rides
- Resumen: distancia, tiempo, velocidad máx., inclinación L/R, score
- Mapa de línea, colores de velocidad, scrub, gráficas, gauge
- Chip de calidad GPS
- Lista de rectas / curvas (al tocar una curva: teaser corto, luego candado)
- Skill Lab: overview + replay de la curva destacada
- Primeras **3** frenadas
- Amigos y comparar bbox con un ride compartido
- Rodadas: crear/unir con código de **ride** (ej. `TAP42A`), mapa en vivo, radio, fotos
- Family Watch: círculo + link en vivo
- Español / inglés

Los códigos de rodada **no** dan Pro.

---

## Pro

Mientras haya un periodo activo (socio o pago):

| Función | Gratis | Pro |
|---|---|---|
| Zoom de tramo / elegir un stretch | No | Sí |
| Lista de frenadas | Primeras 3 | Todas + zoom a cada una |
| Detalle de curva (entrada / ápice / salida) | Teaser | Completo |
| Notas de manejo / coach | No | Sí (si hay notas) |
| Rutas con nombre + auto-vueltas | Pausado en v1 | Pro **cuando se reactive** |
| Comparar vs tu mejor / misma ruta | Pausado en v1 | Pro cuando vuelvan las rutas |
| “Sin anuncios” | No se vende | El banner es placeholder, no AdMob |
| Logger Métrica / cámara de aventura (GoPro) | No | Sí |

Después de que expire Pro: **no se borran rides**. El análisis vuelve a profundidad Gratis.

---

## Sin prueba

No hay prueba en la app. Pro empieza con la suscripción (en Android, desde el primer día con Play). Si la tienda ofrece un periodo gratis, es una oferta de la tienda, no de la app.

- Quien usó la prueba vieja es Gratis normal y **no** ve el aviso de Pro vencido.
- El aviso "Tu Pro terminó. Suscríbete para recuperar …" solo sale si venció un código de socio o una suscripción pagada.

---

## Socio — 90 días con código de un solo uso

Distinto del código de rodada.

- Código único (ej. `PRO-7K4M2Q`) → **una cuenta** → 90 días de Pro.
- Se canjea en Ajustes. Error claro si es inválido, ya usado, o esta cuenta ya canjeó uno.
- **Un código de socio por cuenta.** No se apilan 90+90.
- El fin de Pro queda en `max(pro_actual, ahora + 90 días)` para nunca acortar un periodo más largo.
- Si **ya paga**, el código **no se consume**; que se lo dé a otra persona.

---

## Pago (App Store: ver APP_STORE.md)

Un entitlement: `pro`.

- Mensual — `riderlab_pro_monthly` — MX$59
- Anual — `riderlab_pro_yearly` — MX$499 (opción por defecto)

La hoja de Pro muestra precio y periodo de cada plan, "Restaurar compras" en builds de tienda, y que la suscripción se renueva sola y se cancela cuando quieras.

En iOS los códigos de socio se reemplazan por **códigos de oferta de Apple** (guía 3.1.1).

Sin SKU de por vida al arranque. Sin plan familiar hasta que Family Watch sea superficie de pago.
