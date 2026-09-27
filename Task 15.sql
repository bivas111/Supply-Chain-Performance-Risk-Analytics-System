WITH vendor_metrics AS (
    SELECT 
        po.vendor_id,
        
        -- Volume Baselines
        COUNT(DISTINCT po.PO_ID) AS total_orders,
        COUNT(DISTINCT s.shipment_id) AS total_shipments,
        
        -- 1. DELAY METRICS
        -- Calculates actual positive delay days (treats early/on-time as 0)
        ROUND(
            AVG(GREATEST(DATEDIFF(s.Delivered_Date, s.Month_Start
), 0)), 
            1
        ) AS avg_delay_days,
        
        -- 2. RELIABILITY METRIC (On-Time Delivery Rate %; Target >= 85%)
        ROUND(
            (SUM(CASE WHEN s.Delivered_Date <= s.Month_Start
 THEN 1 ELSE 0 END) / NULLIF(COUNT(DISTINCT s.shipment_id), 0)) * 100, 
            2
        ) AS otd_rate_pct,
        
        -- 3. RETURN METRICS (Quality Risk)
        COUNT(DISTINCT r.return_id) AS total_returns,
        ROUND(
            (COUNT(DISTINCT r.return_id) / NULLIF(COUNT(DISTINCT po.PO_ID), 0)) * 100, 
            2
        ) AS return_rate_pct,
        
        ROUND(
            SUM(
                CASE 
                    WHEN r.return_value IS NOT NULL THEN r.return_value 
                    ELSE (r.return_qty * po.unit_price_INR) 
                END
            ), 
            2
        ) AS total_return_value

    FROM purchase_orders_clean po
    LEFT JOIN shipments_clean s 
           ON po.PO_ID = s.PO_ID
    LEFT JOIN returns_clean r 
           ON po.PO_ID = r.PO_ID
    
    GROUP BY po.vendor_id
    HAVING total_orders >= 5 -- Filters out low-volume vendors to prevent statistical skew
)
SELECT 
    vendor_id,
    total_orders,
    otd_rate_pct,
    avg_delay_days,
    return_rate_pct,
    IFNULL(total_return_value, 0.00) AS total_return_value_INR,
    
    -- Composite Risk Classification Flag
    CASE 
        WHEN otd_rate_pct < 85.0 AND return_rate_pct > 10.0 THEN 'CRITICAL RISK (High Return & Unreliable)'
        WHEN otd_rate_pct < 85.0 THEN 'DELIVERY RISK (OTD < 85%)'
        WHEN return_rate_pct > 10.0 THEN 'QUALITY RISK (High Returns)'
        ELSE 'LOW RISK'
    END AS vendor_risk_tier

FROM vendor_metrics
ORDER BY 
    otd_rate_pct ASC,           -- Lowest reliability first
    return_rate_pct DESC,       -- Highest return rates first
    avg_delay_days DESC,        -- Highest delivery delays first
    total_return_value_INR DESC;