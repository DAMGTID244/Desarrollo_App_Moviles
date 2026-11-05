# Directorio de Negocios de Dolores Hidalgo · API local

API REST local escrita en Node.js con el módulo `http`, sin dependencias externas. Entrega el catálogo de negocios que consumirá la aplicación Flutter. Corresponde a la **Ronda 1** del manual TDD *Consumo de API local*.

## Requisitos

- Node.js 18 o superior (`node --version`)
- Windows PowerShell, Mac o Linux
- Navegador web (opcional, para ver la lista en JSON)

## Ejecutar el servidor

```bash
cd api
node server.js
```

Debe aparecer `API lista en http://localhost:3000/negocios`. Deja esa terminal abierta; para detener el servidor usa `Ctrl + C`.

## Endpoints

| Método | Ruta | Descripción | Éxito | Errores |
|---|---|---|---|---|
| GET | `/salud` | Verifica que el servidor esté activo | 200 | |
| GET | `/negocios` | Lista los negocios. Acepta `?q=` para filtrar por nombre | 200 | |
| GET | `/negocios/:id` | Obtiene un negocio por id | 200 | 404 |
| POST | `/negocios` | Crea un negocio. Requiere `nombre` y `categoria` | 201 | 400 |
| PUT | `/negocios/:id` | Actualiza un negocio existente | 200 | 404, 400 |
| DELETE | `/negocios/:id` | Elimina un negocio | 204 | 404 |

Los datos se guardan en memoria: al reiniciar el servidor vuelven los 5 negocios iniciales.

## Pruebas y evidencias

### Captura 1 · Servidor en ejecución y registro de peticiones

La terminal muestra las peticiones recibidas: `GET /negocios`, `POST /negocios` y `DELETE /negocios/6`.

![Captura 1](docs/capturas/captura-01.png)

### Captura 2 · Creación de negocio (POST)

`Invoke-RestMethod` envía un negocio válido y la API responde con el registro y su `id` asignado.

![Captura 2](docs/capturas/captura-02.png)

### Captura 3 · Verificación de salud

`curl.exe localhost:3000/salud` responde `{"ok":true}`, lo que confirma que la API está activa.

![Captura 3](docs/capturas/captura-03.png)

### Captura 4 · Lista de negocios en el navegador

Consulta a `http://localhost:3000/negocios`. Se muestran los 5 negocios iniciales en JSON.

![Captura 4](docs/capturas/captura-04.png)

### Captura 5 · Negocio inexistente (404)

`curl.exe -i localhost:3000/negocios/99` responde `404 Not Found` con `{"error":"No existe"}`.

![Captura 5](docs/capturas/captura-05.png)

### Captura 6 · Servidor encendido

Arranque del servidor y peticiones GET registradas en la terminal.

![Captura 6](docs/capturas/captura-06.png)

### Captura 7 · Salud con el servidor activo

Nueva comprobación de `/salud` mientras el servidor sigue corriendo.

![Captura 7](docs/capturas/captura-07.png)

### Captura 8 · Negocio sin categoría (400)

`Invoke-RestMethod` envía un negocio sin `categoria`. La API responde `(400) Solicitud incorrecta` con el mensaje `nombre y categoria son obligatorios`.

![Captura 8](docs/capturas/captura-08.png)

### Captura 9 · Detalle de creación

Respuesta completa del negocio creado: `telefono` vacío y `favorito` en `False` por defecto.

![Captura 9](docs/capturas/captura-09.png)

### Captura 10 · Eliminación (DELETE)

`curl.exe -i -X DELETE localhost:3000/negocios/6` responde `204 No Content`, sin cuerpo.

![Captura 10](docs/capturas/captura-10.png)

## Estructura del proyecto

```
directorio_dolores/
├── api/
│   └── server.js
└── docs/
    └── capturas/
```
