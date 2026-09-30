-- Top 10 customers by total net spend.

SELECT
    RANK() OVER (ORDER BY SUM(o.net_amount) DESC) AS spend_rank,
    c.full_name,
    c.city,
    c.country,
    COUNT(o.order_id)          AS orders,
    SUM(o.total_quantity)      AS units_bought,
    SUM(o.net_amount)          AS total_spend
FROM analytics_marts.fct_orders AS o
JOIN analytics_marts.dim_customers AS c
    ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.full_name, c.city, c.country
ORDER BY spend_rank
LIMIT 10;
