SELECT
    delivery_city,
    ROUND(SUM(order_value_ngn) / 1367.0, 2) AS revenue_usd
FROM nigerian_ecom_data
GROUP BY delivery_city
ORDER BY revenue_usd DESC;

SELECT
    platform,
    ROUND(SUM(order_value_ngn) / 1367.0, 2) AS revenue_usd
FROM nigerian_ecom_data
GROUP BY platform
ORDER BY revenue_usd DESC;

SELECT
    delivery_status,
    COUNT(*) AS total_orders,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM nigerian_ecom_data
GROUP BY delivery_status;

SELECT
    platform,
    ROUND(
        100.0 * SUM(order_value_ngn)
        / SUM(SUM(order_value_ngn)) OVER (),
        1
    ) AS revenue_share_pct
FROM nigerian_ecom_data
GROUP BY platform;

SELECT
    platform,
    COUNT(order_id) AS orders,
    SUM(CAST(order_value_ngn AS REAL)) / 1367.0 AS revenue_usd,
    ROUND(
        (SUM(CAST(order_value_ngn AS REAL)) / 1367.0)
        / COUNT(order_id),
        2
    ) AS avg_order_value_usd
FROM nigerian_ecom_data
GROUP BY platform
ORDER BY avg_order_value_usd DESC;

WITH monthly_sales AS (
    SELECT
        strftime('%Y-%m', order_date) AS month,
        SUM(CAST(order_value_ngn AS REAL)) / 1367.0 AS revenue_usd
    FROM nigerian_ecom_data
    GROUP BY month
)
SELECT
    month,
    ROUND(revenue_usd, 2) AS revenue_usd,
    ROUND(
        AVG(revenue_usd) OVER (
            ORDER BY month
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ),
        2
    ) AS rolling_3mo_avg_usd
FROM monthly_sales;

WITH monthly_sales AS (
    SELECT
        strftime('%Y-%m', order_date) AS month,
        SUM(CAST(order_value_ngn AS REAL)) / 1367.0 AS revenue_usd
    FROM nigerian_ecom_data
    GROUP BY month
)
SELECT
    month,
    ROUND(revenue_usd, 2) AS revenue_usd,
    ROUND(
        100.0 * (
            revenue_usd - LAG(revenue_usd) OVER (ORDER BY month)
        ) /
        LAG(revenue_usd) OVER (ORDER BY month),
        2
    ) AS mom_growth_pct
FROM monthly_sales;

WITH monthly_sales AS (
    SELECT
        strftime('%Y-%m', order_date) AS month,
        SUM(CAST(order_value_ngn AS REAL) / 1367.0) AS revenue_usd
    FROM nigerian_ecom_data
    GROUP BY month
)
SELECT
    month,
    ROUND(revenue_usd, 2) AS revenue_usd,
    ROUND(
        revenue_usd -
        AVG(revenue_usd) OVER (),
        2
    ) AS deviation_from_avg_usd
FROM monthly_sales;
