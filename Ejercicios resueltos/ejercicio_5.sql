-- EJERCICIO: Para los 50 customers con más compras de la base, calcular qué porcentaje de estas compras se realizó
-- en los top 50 sellers. El top de sellers debe calcularse por monto, y el top de customers no debe calcularse por país.

-- Calcula el top 50 de sellers según el monto total vendido (en moneda local)
WITH top_sellers AS (
  SELECT seller_id,
         SUM(order_amount_local_currency) AS total_amount
  FROM orders_sampleorders_sample
  WHERE order_status = 'CONFIRMED'
  GROUP BY seller_id
  ORDER BY total_amount DESC
  LIMIT 50
),

-- Calcula el top 50 de customers según la cantidad de órdenes confirmadas.
top_customers AS (
  SELECT customer_id,
         COUNT(*) AS cantidad_compras
  FROM orders_sampleorders_sample
  WHERE order_status = 'CONFIRMED'
  GROUP BY customer_id
  ORDER BY cantidad_compras DESC
  LIMIT 50
),

-- Trae el detalle de todas las órdenes confirmadas que pertenecen a los 50 clientes principales.
orders_top_customers AS (
  SELECT o.*
  FROM orders_sampleorders_sample o
  INNER JOIN top_customers tc ON o.customer_id = tc.customer_id
  WHERE o.order_status = 'CONFIRMED'
)

-- Se calula: la cantidad total de órdenes confirmadas realizadas por ese customer y
-- el porcentaje de esas órdenes que fueron hechas a sellers que están en el top 50 de ventas.
SELECT 
  otc.customer_id,
  COUNT(*) AS qty_confirmed_orders,
  ROUND(COUNT(ts.seller_id) * 100.0 / COUNT(*), 2) AS ratio_conf_orders_top_100_sellers
FROM orders_top_customers otc
LEFT JOIN top_sellers ts 
	ON otc.seller_id = ts.seller_id
GROUP BY otc.customer_id
ORDER BY ratio_conf_orders_top_100_sellers DESC;
