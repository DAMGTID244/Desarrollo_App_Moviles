# Universidad TI

App de Flutter con **dos pantallas**: una rejilla de carreras (Principal) y
el detalle de la carrera elegida (Contenido). Todo el código vive en un
solo archivo, `lib/main.dart`, para que sea fácil de leer de principio a fin.

## Cómo ejecutarla

1. Crea el proyecto (si aún no existe):
   ```
   flutter create universidad_ti
   ```
2. Reemplaza el contenido de `lib/main.dart` con el de este repositorio.
3. Ejecuta:
   ```
   flutter run -d web-server
   ```

## Qué hace la app

- **Pantalla Principal:** muestra una rejilla de **2 columnas** con las
  cinco carreras. Cada tarjeta tiene un ícono representativo y el nombre
  de la carrera.
- **Pantalla Contenido:** al tocar una tarjeta, se abre esta pantalla con
  el nombre completo, el mismo ícono en grande y una descripción. Un botón
  **Regresar** (o la flecha del `AppBar`) vuelve a la rejilla.

## Cómo está organizado `main.dart`

Aunque es un solo archivo, el código sigue un orden fijo, de arriba hacia
abajo:

| Sección | Contenido |
|---|---|
| `main()` y `MyApp` | Arrancan la app y definen el tema (color, título). |
| `Carrera` | Clase simple: nombre, ícono, color y descripción de una carrera. |
| `carreras` | El **arreglo** con las cinco carreras. Única fuente de datos de toda la app. |
| `PantallaPrincipal` | Arma la rejilla con `GridView.builder`, recorriendo `carreras`. |
| `_TarjetaCarrera` | La tarjeta reutilizable; al tocarla, navega a `PantallaContenido`. |
| `PantallaContenido` | Recibe una `Carrera` por su constructor y muestra su información. |

## La idea clave: un solo arreglo

La rejilla y la pantalla de contenido **nunca** repiten los textos de las
carreras: ambas los leen del mismo arreglo `carreras`. Por eso, agregar
una sexta carrera se reduce a copiar un bloque `Carrera(...)` dentro de
esa lista; ninguna otra parte del código cambia.

## Navegación

- **Ir al detalle:** `Navigator.push(...)` desde el `onTap` de la tarjeta,
  enviando la `Carrera` elegida por el constructor de `PantallaContenido`.
- **Regresar:** `Navigator.pop(context)` desde el botón, o la flecha que
  el `AppBar` agrega automáticamente cuando la pantalla se abrió con
  `Navigator.push`.

## Extender la app

- **Agregar una carrera:** añade un elemento más a la lista `carreras`.
- **Usar una imagen real en vez de un ícono:** cambia el `Icon` dentro de
  `CircleAvatar` por un `Image.asset(...)` o `Image.network(...)`.
- **Cambiar a 3 columnas:** ajusta `crossAxisCount` en
  `SliverGridDelegateWithFixedCrossAxisCount`.
