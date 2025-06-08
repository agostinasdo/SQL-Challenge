-- Cantidad de órdenes y monto total de las mismas (local y en dólares), por ciudad, país y año-mes.

WITH currency_cleaned AS (
  SELECT 
    *,
    REPLACE(rate_us, '.', '') AS rate_us_clean
  FROM currency_mapcurrency
)

SELECT 	
  cc.country_name AS country,
	o.city_name AS city,
  TO_CHAR(o.order_date::timestamp, 'YYYY-MM') AS date,
  COUNT(DISTINCT o.order_id) AS qty_orders,
  SUM(o.order_amount_local_currency) AS amount_local_currency,
  
  SUM(
    o.order_amount_local_currency / CAST(
      CASE
        WHEN cm.currency_iso IN ('ARS','UYU') THEN
         	LEFT(cm.rate_us_clean, 2) || '.' || RIGHT(cm.rate_us_clean, LENGTH(cm.rate_us_clean) - 2)
        WHEN cm.currency_iso = 'CLP' THEN
     	    LEFT(cm.rate_us_clean, 3) || '.' || RIGHT(cm.rate_us_clean, LENGTH(cm.rate_us_clean) - 3)
        WHEN cm.currency_iso IN ('COP','PYG') THEN
         	LEFT(cm.rate_us_clean, 4) || '.' || RIGHT(cm.rate_us_clean, LENGTH(cm.rate_us_clean) - 4) 
      END
    AS DECIMAL(20,8)) 
  ) AS amount_usd

FROM orders_sampleorders_sample o
INNER JOIN city_country_mapcitiessample cc
	ON o.city_id = cc.city_id
INNER JOIN currency_cleaned cm
	ON cc.country_id = cm.country_id
    AND TO_CHAR(o.order_date::timestamp,'YYYY-MM') = TO_CHAR(cm.currency_exchange_date::timestamp,'YYYY-MM')

GROUP BY country, city, date
ORDER BY date
