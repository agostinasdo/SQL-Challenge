WITH top_sellers AS (
  SELECT seller_id,
         SUM(order_amount_local_currency) AS total_amount
  FROM orders_sampleorders_sample
  WHERE order_status = 'CONFIRMED'
  GROUP BY seller_id
  ORDER BY total_amount DESC
  LIMIT 50
),

top_customers AS (
  SELECT customer_id,
         COUNT(*) AS cantidad_compras
  FROM orders_sampleorders_sample
  WHERE order_status = 'CONFIRMED'
  GROUP BY customer_id
  ORDER BY cantidad_compras DESC
  LIMIT 50
),

orders_top_customers AS (
  SELECT o.*
  FROM orders_sampleorders_sample o
  INNER JOIN top_customers tc ON o.customer_id = tc.customer_id
  WHERE o.order_status = 'CONFIRMED'
)

SELECT 
  otc.customer_id,
  COUNT(*) AS qty_confirmed_orders,
  ROUND(COUNT(ts.seller_id) * 100.0 / COUNT(*), 2) AS ratio_conf_orders_top_100_sellers
FROM orders_top_customers otc
LEFT JOIN top_sellers ts 
	ON otc.seller_id = ts.seller_id
GROUP BY otc.customer_id
ORDER BY ratio_conf_orders_top_100_sellers DESC;
