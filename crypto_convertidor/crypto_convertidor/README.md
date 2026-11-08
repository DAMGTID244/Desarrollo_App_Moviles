# Convertidor de criptomonedas en tiempo real (Reto 4)

App Flutter que consulta la API pública de CoinGecko y muestra el precio en USD de Bitcoin, Ethereum y Solana. El usuario escribe un monto en dólares y la app calcula cuántas fracciones de cada moneda alcanza.

## Pasos

1. Crea el proyecto base y reemplaza los dos archivos:

```powershell
flutter create crypto_convertidor
cd crypto_convertidor
```

Luego copia `pubspec.yaml` y `lib\main.dart` de este zip sobre los que se crearon.

2. Descarga las dependencias:

```powershell
flutter pub get
```

3. En Android, agrega el permiso de internet en `android\app\src\main\AndroidManifest.xml`, dentro de `<manifest>`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

4. Ejecuta la app:

```powershell
flutter run -d chrome
```

o en tu celular:

```powershell
flutter run -d ID_DEL_CELULAR
```

## Conceptos que practica

- Petición HTTP con `http.get` y timeout.
- Decodificar JSON y convertir `num` a `double`.
- `FutureBuilder` con estados de carga, error y datos.
- Leer un `TextField` y convertirlo a número con `double.tryParse`.
- Recargar datos con un botón.
