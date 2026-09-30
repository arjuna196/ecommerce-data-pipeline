-- Revenue by category, with each category's share of total revenue.

SELECT
    p.category,
    COUNT(DISTINCT i.order_id)    AS orders,
    SUM(i.quantity)               AS units_sold,
    SUM(i.net_amount)             AS net_revenue,
    ROUND(
        100.0 * SUM(i.net_amount) / SUM(SUM(i.net_amount)) OVER (),
        2
    )                             AS revenue_share_pct
FROM analytics_marts.fct_order_items AS i
JOIN analytics_marts.dim_products AS p
    ON i.product_id = p.product_id
GROUP BY p.category
ORDER BY net_revenue DESC;
