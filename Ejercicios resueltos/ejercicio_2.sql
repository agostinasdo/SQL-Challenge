/* EJERCICIO 2:
Cantidad de sellers que tuvieron ventas en abril 2019 en Argentina, agrupándolos por categoría, y que en marzo 2019 vendieron por lo menos 100 usd. */

-- Limpieza del formato de tasa de cambio
WITH currency_cleaned AS (
  SELECT 
    *,
    REPLACE(rate_us, '.', '') AS rate_us_clean
  FROM currency_mapcurrency
),

-- Ajuste de la posición del punto decimal según la moneda 
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

-- Sellers que vendieron al menos 100 USD (calculados con tipo de cambio) durante marzo de 2019.
sellers_marzo_ok AS (
  SELECT 
    o2.seller_id,
    SUM (o2.order_amount_local_currency / cp.exchange_rate_usd)  AS order_amount_usd
  FROM orders_sampleorders_sample o2
  JOIN city_country_mapcitiessample cc2 ON o2.city_id = cc2.city_id
  JOIN currency_prepared cp ON cc2.country_id = cp.country_id
       AND TO_CHAR(o2.order_date::timestamp,'YYYY-MM') = TO_CHAR(cp.currency_exchange_date::timestamp,'YYYY-MM')
  WHERE TO_CHAR(o2.order_date::timestamp, 'YYYY-MM') = '2019-03'
  GROUP BY seller_id
  HAVING SUM (o2.order_amount_local_currency / cp.exchange_rate_usd) >= 100
)

-- Se toma el universo de sellers que vendieron al menos 100 USD en marzo (CTE anterior),
-- y se contabiliza cuántos de ellos hicieron ventas en abril 2019 en Argentina,
-- agrupando los resultados por categoría.  
SELECT 
  COALESCE(sc.categoria, 'Sin categoría asignada') AS category,
  COUNT(DISTINCT o.seller_id) AS qty_seller
FROM orders_sampleorders_sample o
LEFT JOIN seller_categorypartnerssample sc ON o.seller_id = sc.seller_id
JOIN city_country_mapcitiessample cc ON o.city_id = cc.city_id
JOIN sellers_marzo_ok s_ok ON o.seller_id = s_ok.seller_id
WHERE cc.country_name = 'Argentina'
  AND TO_CHAR(o.order_date::timestamp, 'YYYY-MM') = '2019-04'
GROUP BY category
ORDER BY qty_seller DESC;
