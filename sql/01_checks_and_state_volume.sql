SELECT COUNT(*) AS total_rows
FROM [Olist Delivery Analysis].[dbo].[orders_raw]
SELECT COUNT(*) AS total_rows
FROM [Olist Delivery Analysis].[dbo].[customers_raw];
SELECT
    COUNT(*) AS total_rows,
    COUNT(customer_id) AS non_null_customer_ids,
    COUNT(DISTINCT customer_id) AS distinct_customer_ids
FROM [Olist Delivery Analysis].[dbo].[customers_raw];
SELECT COUNT(*) AS blank_or_space_customer_ids
FROM [Olist Delivery Analysis].[dbo].[customers_raw]
WHERE LTRIM(RTRIM(customer_id)) = '';



SELECT
    COUNT(*) AS joined_rows,
    COUNT(c.customer_id) AS matched_order_rows
FROM [Olist Delivery Analysis].[dbo].[orders_raw] AS o
LEFT JOIN [Olist Delivery Analysis].[dbo].[customers_raw] AS c
    ON o.customer_id = c.customer_id;




SELECT COUNT(*) AS rows_with_invalid_delivery_dates
FROM [Olist Delivery Analysis].[dbo].[orders_raw]
WHERE
    (order_delivered_customer_date <> ''
     AND TRY_CONVERT(datetime2, order_delivered_customer_date, 120) IS NULL)
    OR
    (order_estimated_delivery_date <> ''
     AND TRY_CONVERT(datetime2, order_estimated_delivery_date, 120) IS NULL);




     -- Count measurable delivered orders in each customer state.
SELECT
    c.customer_state,
    COUNT(*) AS eligible_orders
-- Match each order to its customer record.
FROM [Olist Delivery Analysis].[dbo].[orders_raw] AS o
LEFT JOIN [Olist Delivery Analysis].[dbo].[customers_raw] AS c
    ON o.customer_id = c.customer_id
-- Include only delivered orders with both readable dates.
-- NULLIF treats blank text as missing before conversion.
WHERE o.order_status = 'delivered'
  AND TRY_CONVERT(datetime2, NULLIF(o.order_delivered_customer_date, ''), 120) IS NOT NULL
  AND TRY_CONVERT(datetime2, NULLIF(o.order_estimated_delivery_date, ''), 120) IS NOT NULL
-- Make one group per state and show larger counts first.
GROUP BY c.customer_state
ORDER BY eligible_orders DESC






-- Flag lateness for measurable delivered orders; no table is changed.
;WITH eligible_deliveries AS (
    SELECT
        c.customer_state,
        -- A later calendar date means late. Same-day delivery is on time.
        CASE WHEN
            CAST(TRY_CONVERT(datetime2, NULLIF(o.order_delivered_customer_date, ''), 120) AS date)
            > CAST(TRY_CONVERT(datetime2, NULLIF(o.order_estimated_delivery_date, ''), 120) AS date)
            THEN 1 ELSE 0
        END AS is_late
    FROM [Olist Delivery Analysis].[dbo].[orders_raw] AS o
    LEFT JOIN [Olist Delivery Analysis].[dbo].[customers_raw] AS c
        ON o.customer_id = c.customer_id
    -- Keep our existing eligibility rule; blanks stay missing.
    WHERE o.order_status = 'delivered'
      AND TRY_CONVERT(datetime2, NULLIF(o.order_delivered_customer_date, ''), 120) IS NOT NULL
      AND TRY_CONVERT(datetime2, NULLIF(o.order_estimated_delivery_date, ''), 120) IS NOT NULL
)
-- Count measurable orders, late orders and the percentage for each state.
SELECT
    customer_state,
    COUNT(*) AS eligible_orders,
    SUM(is_late) AS late_orders,
    CAST(100.0 * SUM(is_late) / COUNT(*) AS decimal(6,2)) AS late_rate_pct
FROM eligible_deliveries
GROUP BY customer_state
-- Highest percentages first, with order counts visible for context.
ORDER BY late_rate_pct DESC, eligible_orders DESC;
