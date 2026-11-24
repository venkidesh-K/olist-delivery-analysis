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
-- Rebuild your state table as a named step.
, state_totals AS (
    SELECT customer_state,
           COUNT(*) AS eligible_orders,
           SUM(is_late) AS late_orders
    FROM eligible_deliveries
    GROUP BY customer_state
)
-- Add up all the state rows.
SELECT
    COUNT(*) AS state_rows,
    SUM(eligible_orders) AS total_eligible,
    SUM(late_orders) AS total_late,
    CAST(100.0 * SUM(late_orders) / SUM(eligible_orders) AS decimal(6,2)) AS overall_late_pct
FROM state_totals;
