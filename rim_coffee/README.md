# ☕ Rim Coffee — tablet de mostrador para cafeterías

Proyecto en parejas de **Desarrollo de Aplicaciones Móviles** (UTNG) — Flutter / Material 3.
Cliente: **Rimbaud's Coffee**.

> Datos y sesión se guardan en el dispositivo (almacenamiento local, `shared_preferences`).
> No hay servidor: la app corre en **una tablet** del mostrador.

---

## 1. Descripción

Una sola tablet en la cafetería con **una cuenta del negocio** (correo + contraseña) y **tres modos**:

| Modo | Para qué sirve | Cómo se entra |
|---|---|---|
| **Personal** (modo normal) | Mesas, pedidos, cambiar estados, cobrar, productos | Al iniciar sesión |
| **Dueño** | Reportes, personal, negocio, PIN, respaldo | Botón *Panel del dueño* + **PIN dueño** |
| **Cliente** | El cliente pide desde la tablet y la devuelve | Al elegir una mesa libre → *Entregar la tablet al cliente* |

Flujo: el mesero elige mesa libre → dice quién atiende → entrega la tablet → el cliente escribe su
nombre, arma su pedido y lo envía → "Devuelve la tablet al mesero" → el mesero cambia estados
(Recibido → En preparación → Listo → Entregado), puede agregar más pedidos a la misma mesa y
**cobra** (solo si todo está Entregado). El dueño ve reportes de ventas.

Seguridad: dos PIN de 4 a 6 dígitos (personal y dueño). El PIN dueño también vale donde se pide el
personal. 3 intentos fallidos = bloqueo de 30 s. Para salir del modo Cliente: mantener pulsado el
logo + PIN personal.

## 2. Cómo ejecutarlo

**Una sola vez en el celular/tablet:** Ajustes → Acerca del teléfono → toca 7 veces *Número de
compilación* → Opciones de desarrollador → **Depuración USB**. Conéctalo por cable.

1. Descomprime y abre en VS Code la carpeta donde está `pubspec.yaml`.
2. En la terminal: `.\setup.bat` (genera Android/web y descarga paquetes; una sola vez).
3. `flutter devices` para ver el dispositivo y luego `flutter run`.

Sin `setup.bat` (Mac/Linux): `flutter create --platforms=android,web .` → restaura
`tool/main_template.dart` como `lib/main.dart` y `tool/pubspec_template.yaml` como `pubspec.yaml` →
`flutter pub get` → `flutter run`.

## 3. Cuenta de demostración y PIN

| Dato | Valor |
|---|---|
| Correo | `cafeteria.rim.coffe@gmail.com` |
| Contraseña | `rimcoffe_67` |
| PIN personal | `1357` |
| PIN dueño | `2468` |

La cuenta se **crea en la pantalla de Registro** la primera vez (la app arranca sin cuenta).
Después de registrar, *Dueño → Seguridad → Restablecer datos de demostración* carga 30 días de
ventas para que los reportes tengan información.

## 4. Capturas de pantalla

Guardadas en `screenshots/`:

| # | Archivo | Qué muestra |
|---|---|---|
| 1 | `01-splash.png` | Splashscreen |
| 2 | `02-login.png` | Login |
| 3 | `03-registro.png` | Registro (con validaciones) |
| 4 | `04-dashboard-admin.png` | Dashboard 1 — Panel del dueño (Admin) |
| 4.1 | `04.1-dashboard-admin.png` | Dashboard 1 — Panel del dueño (Admin) |
| 5 | `05-dashboard-cliente.png` | Dashboard 2 — Modo Cliente (menú) |
| 6 | `06-dashboard-operador.png` | Dashboard 3 — Modo Personal / Operador (Mesas) |
| 7 | `07-lista-principal.png` | Lista principal (Pedidos) |
| 8 | `08-lista-detalle.png` | Detalle de un pedido |
| 9 | `09-lista-vacia.png` | Estado vacío |
| 10 | `10-formulario.png` | Formulario (nuevo producto) |
| 11 | `11-foto-equipo.png` | Foto del equipo |
| 12 | `12-navegacion_cliente.png` | Navegación entre pantallas |
| 12.1 | `12-navegacion_dueño.png` | Navegación entre pantallas |
| 12.2 | `12-navegacion_personal.png` | Navegación entre pantallas |

![01](screenshots/01-splash.png)
![02](screenshots/02-login.png)
![03](screenshots/03-registro.png)
![04](screenshots/04-dashboard-admin.png)
![05](screenshots/05-dashboard-cliente.png)
![06](screenshots/06-dashboard-operador.png)
![07](screenshots/07-lista-principal.png)
![08](screenshots/08-lista-detalle.png)
![09](screenshots/09-lista-vacia.png)
![10](screenshots/10-formulario.png)
![11](screenshots/11-foto-equipo.png)
![12](screenshots/12-navegacion.png)

## 5. Estructura

```
lib/
├── app/        tema, rutas (con protección), app
├── core/       models · state (ChangeNotifier) · storage · services (reportes, respaldo, demo) · utils · widgets
└── features/
    ├── auth/      splash, login, registro, recuperar contraseña
    ├── personal/  mesas, pedidos, detalle, cuenta de mesa/cobro, cuenta
    ├── dueno/     inicio, reportes, personal, negocio, seguridad
    ├── cliente/   bienvenida, menú, carrito, enviar, devolver tablet
    └── shared/    productos y su formulario, acceso al panel del dueño
```

Capas: presentación (`features/`) → lógica (`core/state`, `core/services`) → datos (`core/storage`).
El patrón Observer es `ChangeNotifier` + `ListenableBuilder`.

## 6. Limitaciones

- Sin servidor: los datos viven en la tablet. Hay respaldo manual (Dueño → Seguridad → exportar/importar texto).
- La recuperación de contraseña es simulada (no envía correos).
- Contraseña y PIN se guardan localmente sin cifrar (en producción los manejaría un servidor).
- Las categorías se pueden renombrar, no agregar ni quitar. El logo se cambia reemplazando el archivo (ver `IMAGENES.md`).
- El Registro no tiene selección de rol: en v2 los roles son *modos* de una misma cuenta.
