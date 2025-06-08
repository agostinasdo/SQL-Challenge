-- EJERCICIO 1:Cantidad de órdenes y monto total de las mismas (local y en dólares), por ciudad, país y año-mes.

WITH currency_cleaned AS (
  SELECT 
    *,
    REPLACE(rate_us, '.', '') AS rate_us_clean
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
)
SELECT
	cc.country_name AS country,
	o.city_name AS city,
  	TO_CHAR(o.order_date::timestamp, 'YYYY-MM') AS date,
  	COUNT(DISTINCT o.order_id) AS qty_orders,
  	SUM(o.order_amount_local_currency) AS amount_local_currency,

-- Conversión de monto local a USD según formato correcto por moneda
  SUM(o.order_amount_local_currency / cp.exchange_rate_usd) AS amount_usd

FROM orders_sampleorders_sample o
INNER JOIN city_country_mapcitiessample cc
	ON o.city_id = cc.city_id
INNER JOIN currency_prepared cp
	ON cc.country_id = cp.country_id
    AND TO_CHAR(o.order_date::timestamp,'YYYY-MM') = TO_CHAR(cp.currency_exchange_date::timestamp,'YYYY-MM')

GROUP BY country, city, date
ORDER BY date
