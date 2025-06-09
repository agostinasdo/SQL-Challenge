-- EJERCICIO 4: Tiempo de entrega promedio (en min) en marzo de 2019, por país.

-- CTE que calcula la duración de entrega en minutos para cada orden.
-- Se utiliza EXTRACT(EPOCH) para obtener la diferencia entre fechas en segundos, luego se divide por 60 para convertirlo a minutos.

-- NOTA: Se reemplaza manualmente '2019-02-29' por '2019-02-28' para evitar errores de conversión,
-- ya que 2019 no fue un año bisiesto y algunas fechas están mal formateadas en la fuente de datos.

WITH orders_with_delivery_time AS (
  SELECT *,
   EXTRACT(EPOCH FROM (
      REPLACE(delivery_date, '2019-02-29', '2019-02-28')::timestamp - order_date::timestamp
    )) / 60 AS delivery_minutes
  FROM orders_sampleorders_sample
)

-- Se agrupan los resultados por país y se calcula el promedio del tiempo de entrega en minutos.
-- Solo se incluyen órdenes con fecha de compra en marzo 2019.
SELECT 
  cc.country_name AS country,
  ROUND(AVG (delivery_minutes),2) AS avg_delivery_time
FROM orders_with_delivery_time od
INNER JOIN city_country_mapcitiessample cc ON od.city_id = cc.city_id
WHERE TO_CHAR(od.order_date::timestamp, 'YYYY-MM') = '2019-03'
GROUP BY country;
