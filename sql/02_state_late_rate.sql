-- Flag lateness for measurable delivered orders; no table is changed.
;WITH eligible_deliveries AS (
    SELECT
        c.customer_state,
        -- Compare calendar dates: same-day delivery is on time.
        CASE WHEN
            CAST(TRY_CONVERT(datetime2, NULLIF(o.order_delivered_customer_date, ''), 120) AS date)
            > CAST(TRY_CONVERT(datetime2, NULLIF(o.order_estimated_delivery_date, ''), 120) AS date)
            THEN 1 ELSE 0
        END AS is_late
    FROM [Olist Delivery Analysis].[dbo].[orders_raw] AS o
    LEFT JOIN [Olist Delivery Analysis].[dbo].[customers_raw] AS c
        ON o.customer_id = c.customer_id
    -- Keep delivered orders with both dates; blanks stay missing.
    WHERE o.order_status = 'delivered'
      AND TRY_CONVERT(datetime2, NULLIF(o.order_delivered_customer_date, ''), 120) IS NOT NULL
      AND TRY_CONVERT(datetime2, NULLIF(o.order_estimated_delivery_date, ''), 120) IS NOT NULL
)
-- Show each state's measurable orders, late orders and percentage.
SELECT
    customer_state,
    COUNT(*) AS eligible_orders,
    SUM(is_late) AS late_orders,
    CAST(100.0 * SUM(is_late) / COUNT(*) AS decimal(6,2)) AS late_rate_pct
FROM eligible_deliveries
GROUP BY customer_state
-- Highest percentages first; keep order counts visible for context.
ORDER BY late_rate_pct DESC, eligible_orders DESC;
