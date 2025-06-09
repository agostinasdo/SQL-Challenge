-- EJERCICIO 5: Para los 50 customers con más compras de la base, calcular qué porcentaje de estas compras se realizó
-- en los top 50 sellers. El top de sellers debe calcularse por monto, y el top de customers no debe calcularse por país.

-- Se utiliza USD para poder comparar montos entre países de forma consistente.
-- Limpieza de los datos de tipo de cambio y se ajuste de la posición del punto decimal según la moneda
WITH currency_cleaned AS (
  SELECT *, REPLACE(rate_us, '.', '') AS rate_us_clean
  FROM currency_mapcurrency
),
currency_prepared AS (
  SELECT *,
    CAST(
      CASE
        WHEN currency_iso IN ('ARS','UYU') THEN
          LEFT(rate_us_clean, 2) || '.' || RIGHT(rate_us_clean, LENGTH(rate_us_clean) - 2)
        WHEN currency_iso = 'CLP' THEN
          LEFT(rate_us_clean, 3) || '.' || RIGHT(rate_us_clean, LENGTH(rate_us_clean) - 3)
        WHEN currency_iso IN ('COP','PYG') THEN
          LEFT(rate_us_clean, 4) || '.' || RIGHT(rate_us_clean, LENGTH(rate_us_clean) - 4)
      END AS DECIMAL(20,8)
    ) AS exchange_rate_usd
  FROM currency_cleaned
),
	
-- Top 50 de sellers según el monto total vendido (en USD)
top_sellers AS (
  SELECT seller_id,
         SUM(order_amount_local_currency / exchange_rate_usd) AS total_amount_usd
  FROM orders_sampleorders_sample o
  INNER JOIN city_country_mapcitiessample cc
  	ON o.city_id = cc.city_id
  INNER JOIN currency_prepared cp
  	ON cc.country_id = cp.country_id
  GROUP BY seller_id
  ORDER BY total_amount_usd DESC
  LIMIT 50
),

-- Top 50 de customers según la cantidad de órdenes confirmadas.
top_customers AS (
  SELECT customer_id,
         COUNT(*) AS cantidad_compras
  FROM orders_sampleorders_sample
  WHERE order_status = 'CONFIRMED'
  GROUP BY customer_id
  ORDER BY cantidad_compras DESC
  LIMIT 50
),

-- Detalle de todas las órdenes confirmadas que pertenecen a los 50 clientes principales.
orders_top_customers AS (
  SELECT o.*
  FROM orders_sampleorders_sample o
  INNER JOIN top_customers tc ON o.customer_id = tc.customer_id
  WHERE o.order_status = 'CONFIRMED'
)

-- Cantidad total de órdenes confirmadas realizadas por determinado customer.
-- Porcentaje de esas órdenes que fueron hechas a sellers que están en el top 50 de ventas.
SELECT 
  otc.customer_id,
  COUNT(*) AS qty_confirmed_orders,
  ROUND(COUNT(ts.seller_id) * 100.0 / COUNT(*), 2) AS ratio_conf_orders_top_100_sellers
FROM orders_top_customers otc
LEFT JOIN top_sellers ts 
	ON otc.seller_id = ts.seller_id
GROUP BY otc.customer_id
ORDER BY ratio_conf_orders_top_100_sellers DESC;
