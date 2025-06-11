# SQL Challenge

## Objetivo
Evaluar las capacidades en el manejo de consultas con lenguaje SQL.

## Consideraciones técnicas
### 🗂️ Entorno de trabajo
Este challenge fue resuelto en https://sqliteonline.com/ con el motor de bases de datos **PostgreSQL.** 

### 💱 Conversión de montos locales a dólares
En varios ejercicios fue necesario convertir montos locales a USD utilizando una tabla de tipos de cambio. Durante este proceso se detectaron inconsistencias en el formato del campo **rate_us**:
- Algunas tasas ya incluían un punto decimal (.) indicando la posición de la coma.
- Otras estaban expresadas sin punto decimal pero dando un entero extremadamente grande.

Para resolverlo:
- Se eliminaron los puntos del campo rate_us.
- Luego se reintrodujo la coma decimal en una posición específica, según la moneda (currency_iso) del país asociado.

⚠️ Esta transformación está basada en reglas fijas por moneda y **no es generalizable** ya que la cantidad de dígitos antes de la coma puede cambiar con el tiempo. En un caso real, esta lógica debería adaptarse por día/mes o ser definida con criterios de cada equipo.

🔁 En este challenge se optó por **repetir la lógica de conversión en cada ejercicio** para que cada consulta sea autocontenida y fácilmente entendible de forma independiente. 

En un entorno productivo real esta transformación podría encapsularse -por ejemplo, en una vista- para evitar duplicación de lógica, facilitar el mantenimiento y mejorar la legibilidad.

### 👥 Clientes con menos de 5 órdenes
En el ejercicio 3 se requería calcular el tiempo promedio entre compras para clientes con al menos 5 órdenes. Sin embargo, tras analizar la base se detectó que ningún cliente alcanza esa cantidad.
Por esta razón, se decidió ajustar el filtro a clientes con 4 órdenes o más, para poder mostrar un resultado representativo. Esta decisión se justifica únicamente en el contexto del challenge, y debería revisarse si se aplicara sobre datos reales o más completos.

### 📅 Fechas inválidas
Se encontró un registro con la fecha 2019-02-29 en el campo **delivery_date**, la cual no es válida ya que 2019 no fue un año bisiesto.
Para evitar errores de conversión a timestamp, se reemplazó dicha fecha por 2019-02-28 en el ejercicio 4.
