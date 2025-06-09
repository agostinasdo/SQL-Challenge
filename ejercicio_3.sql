-- EJERCICIO 3: Usando todas las órdenes en la base, calcular el promedio de días entre una orden y la siguiente 
-- a nivel customer, solo para customers con al menos 5 órdenes totales. De ese resultado, quedarse solo con
-- usuarios con un promedio mayor a 5 días.

WITH diff_dates AS(
	SELECT 	customer_id,
  			order_date::timestamp,
  			EXTRACT(DAY FROM LEAD(order_date) OVER (PARTITION BY customer_id ORDER BY order_date)::timestamp - order_date::timestamp) AS days_between_orders
    FROM orders_sampleorders_sample )
  
SELECT 	customer_id,
		COUNT(*) AS qty_orders,
        ROUND(AVG(days_between_orders),2) AS avg_days_between_orders
FROM diff_dates
WHERE customer_id IN (
  SELECT customer_id
  FROM orders_sampleorders_sample
  GROUP BY customer_id
  HAVING COUNT(*) >= 4 )
GROUP BY customer_id 
HAVING AVG(days_between_orders) > 5
