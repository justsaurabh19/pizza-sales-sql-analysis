-- =========================================
-- PIZZA SALES ANALYSIS USING SQL
-- =========================================

-- 1. Retrieve total number of orders placed
SELECT COUNT(order_id) AS total_orders
FROM orders;


-- 2. Calculate total revenue generated
SELECT ROUND(SUM(order_details.quantity * pizzas.price), 2) AS total_revenue
FROM order_details
JOIN pizzas ON pizzas.pizza_id = order_details.pizza_id;


-- 3. Identify the most common pizza size ordered
SELECT pizzas.size,
       COUNT(order_details.order_details_id) AS order_count
FROM pizzas
JOIN order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC;


-- 4. List top 5 most ordered pizza types with quantity
SELECT pizza_types.name,
       SUM(order_details.quantity) AS quantity
FROM pizza_types
JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY quantity DESC
LIMIT 5;


-- 5. Category-wise distribution of pizzas
SELECT category,
       COUNT(name)
FROM pizza_types
GROUP BY category;


-- 6. Total quantity of each pizza category ordered
SELECT pizza_types.category,
       SUM(order_details.quantity) AS quantity
FROM pizza_types
JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY quantity DESC;


-- 7. Distribution of orders by hour of the day
SELECT HOUR(order_time) AS hour,
       COUNT(order_id) AS order_count
FROM orders
GROUP BY HOUR(order_time);


-- 8. Average number of pizzas ordered per day
SELECT ROUND(AVG(quantity), 0) AS avg_pizza_ordered_per_day
FROM (
    SELECT orders.order_date,
           SUM(order_details.quantity) AS quantity
    FROM orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date
) AS daily_orders;


-- 9. Percentage contribution of each category to total revenue
SELECT pizza_types.category,
       ROUND(
           SUM(order_details.quantity * pizzas.price) /
           (SELECT SUM(order_details.quantity * pizzas.price)
            FROM order_details
            JOIN pizzas ON pizzas.pizza_id = order_details.pizza_id) * 100,
       2) AS revenue_percentage
FROM pizza_types
JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue_percentage DESC;


-- 10. Top 3 pizza types based on revenue
SELECT name, revenue
FROM (
    SELECT pizza_types.name,
           SUM(order_details.quantity * pizzas.price) AS revenue,
           RANK() OVER (ORDER BY SUM(order_details.quantity * pizzas.price) DESC) AS rnk
    FROM pizza_types
    JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
    JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
    GROUP BY pizza_types.name
) AS ranked_pizzas
WHERE rnk <= 3;


-- 11. Cumulative revenue over time
SELECT order_date,
       SUM(revenue) OVER (ORDER BY order_date) AS cumulative_revenue
FROM (
    SELECT orders.order_date,
           ROUND(SUM(order_details.quantity * pizzas.price), 2) AS revenue
    FROM order_details
    JOIN pizzas ON pizzas.pizza_id = order_details.pizza_id
    JOIN orders ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date
) AS daily_sales;


-- 12. Top 3 pizza types by revenue for each category
SELECT category, name, revenue
FROM (
    SELECT pizza_types.category,
           pizza_types.name,
           SUM(order_details.quantity * pizzas.price) AS revenue,
           RANK() OVER (PARTITION BY pizza_types.category
                        ORDER BY SUM(order_details.quantity * pizzas.price) DESC) AS rnk
    FROM pizza_types
    JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
    JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
    GROUP BY pizza_types.category, pizza_types.name
) AS ranked_category
WHERE rnk <= 3;
