-- Headline KPIs: overall order volume, revenue, and average order value.

SELECT
    COUNT(*)                          AS total_orders,
    COUNT(DISTINCT customer_id)       AS unique_customers,
    SUM(gross_amount)                 AS gross_revenue,
    SUM(discount_amount)              AS total_discounts,
    SUM(net_amount)                   AS net_revenue,
    ROUND(AVG(net_amount), 2)         AS avg_order_value,
    ROUND(SUM(discount_amount) * 100.0 / SUM(gross_amount), 2) AS discount_rate_pct
FROM analytics_marts.fct_orders;
