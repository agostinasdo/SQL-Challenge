-- EJERCICIO 4: Tiempo de entrega promedio (en min) en marzo de 2019, por país.

WITH orders_with_delivery_time AS (
  SELECT *,
   EXTRACT(EPOCH FROM (
      REPLACE(delivery_date, '2019-02-29', '2019-02-28')::timestamp - order_date::timestamp
    )) / 60 AS delivery_minutes
  FROM orders_sampleorders_sample
)

SELECT 
  cc.country_name AS country,
  AVG (delivery_minutes) AS avg_delivery_time
FROM orders_with_delivery_time od
JOIN city_country_mapcitiessample cc ON od.city_id = cc.city_id
WHERE TO_CHAR(od.order_date::timestamp, 'YYYY-MM') = '2019-03'
GROUP BY country;
