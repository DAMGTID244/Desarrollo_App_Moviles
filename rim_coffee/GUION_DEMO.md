# Guion de demostración en vivo (≈ 8 minutos)

Antes: dispositivo conectado, `flutter run` ya instalado, app **cerrada** y datos borrados (app recién instalada).

**Datos:** correo `cafeteria.rim.coffe@gmail.com` · contraseña `rimcoffe_67` · PIN personal `1357` · PIN dueño `2468`

1. **Compila y arranca**: abre la app; muestra que no hay errores.
2. **Splash → Login**: logo con desvanecido hacia el login.
3. **Validaciones**: Login vacío / correo `ana@` → errores. *Crear cuenta del negocio*: campos vacíos, contraseña `abcdef`, PIN `12`, PIN iguales → errores. Registra la cuenta con los datos de arriba.
4. **Tres dashboards**: Personal (Mesas) → pestaña Cuenta → *Panel del dueño (PIN 2468)* → Inicio del dueño → *Salir del panel* → Mesa libre → *Entregar la tablet al cliente* (modo Cliente).
5. **Listas**: Pedidos (filtros y botón de estado) y Productos. **Estado vacío**: "Sin pedidos pendientes".
6. **Formulario**: Productos → Nuevo producto → Guardar; aparece en el menú del cliente.
7. **Flujo completo**: cliente pide → "Devuelve la tablet" → mantener pulsado el logo + PIN 1357 → Pedidos → avanzar a Entregado → Mesas → Ver cuenta → **Cobrar**.
8. **Reportes** (PIN dueño): hoy / semana / mes, exportar texto.
9. **Datos persistentes**: cierra y abre la app; todo sigue ahí.
