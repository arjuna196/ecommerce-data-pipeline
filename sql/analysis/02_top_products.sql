-- Top 10 products by net revenue, with units sold.

SELECT
    p.product_name,
    p.category,
    SUM(i.quantity)      AS units_sold,
    SUM(i.net_amount)    AS net_revenue
FROM analytics_marts.fct_order_items AS i
JOIN analytics_marts.dim_products AS p
    ON i.product_id = p.product_id
GROUP BY p.product_id, p.product_name, p.category
ORDER BY net_revenue DESC
LIMIT 10;
