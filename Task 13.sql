WITH quarterly_spend AS (
    SELECT 
        YEAR(order_date) AS spend_year,
        QUARTER(order_date) AS spend_quarter,
        -- Formats label as '2026-Q1', '2026-Q2', etc.
        CONCAT(YEAR(order_date), '-Q', QUARTER(order_date)) AS year_quarter,
        
        COUNT(*) AS total_po_count,
        ROUND(SUM(Total_Order_Value), 2) AS total_procurement_spend,
        ROUND(AVG(Total_Order_Value), 2) AS avg_po_value
        
    FROM purchase_orders_clean
    WHERE order_date IS NOT NULL
      AND Total_Order_Value >= 0
    GROUP BY 
        YEAR(order_date), 
        QUARTER(order_date),
        CONCAT(YEAR(order_date), '-Q', QUARTER(order_date)) -- Added to satisfy ONLY_FULL_GROUP_BY
), 
qoq_calculations AS (
    SELECT 
        spend_year,
        spend_quarter,
        year_quarter,
        total_po_count,
        total_procurement_spend,
        avg_po_value,
        
        -- Retrieve previous quarter's spend using LAG()
        LAG(total_procurement_spend, 1) OVER (
            ORDER BY spend_year ASC, spend_quarter ASC
        ) AS prev_quarter_spend
    FROM quarterly_spend
) 
SELECT 
    year_quarter,
    total_po_count,
    total_procurement_spend,
    
    -- Absolute Dollar Change vs Previous Quarter
    ROUND(total_procurement_spend - prev_quarter_spend, 2) AS qoq_spend_change_amount,
    
    -- Percentage QoQ Growth Rate (%)
    ROUND(
        ((total_procurement_spend - prev_quarter_spend) / NULLIF(prev_quarter_spend, 0)) * 100, 
        2
    ) AS qoq_growth_pct,
    
    -- QoQ Trend Classification
    CASE 
        WHEN prev_quarter_spend IS NULL THEN 'Baseline Quarter'
        WHEN total_procurement_spend > prev_quarter_spend THEN 'Spend Increased'
        WHEN total_procurement_spend < prev_quarter_spend THEN 'Spend Decreased'
        ELSE 'Flat Spend'
    END AS qoq_trend_status

FROM qoq_calculations
ORDER BY spend_year ASC, spend_quarter ASC;