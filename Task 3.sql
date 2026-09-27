WITH vendor_performance AS (
    SELECT 
        vendor_id,
        COUNT(*) AS total_orders,
        SUM(CASE WHEN Delivery_Delay_Days > 0 THEN 1 ELSE 0 END) AS late_orders,
        ROUND((SUM(CASE WHEN Delivery_Delay_Days <= 0 THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) AS otd_pct,
        AVG(CASE WHEN Delivery_Delay_Days > 0 THEN Delivery_Delay_Days ELSE 0 END) AS avg_delay
    FROM purchase_orders_clean
    WHERE actual_delivery_date IS NOT NULL
    GROUP BY vendor_id
)
SELECT 
    CASE 
        WHEN otd_pct >= 85.0 THEN 'Tier 1 (>=85% OTD)'
        WHEN otd_pct >= 70.0 THEN 'Tier 2 (70-84% OTD)'
        ELSE 'Tier 3 (<70% OTD)'
    END AS calculated_vendor_tier,
    
    COUNT(vendor_id) AS total_vendors_in_tier,
    SUM(total_orders) AS total_purchase_orders,
    ROUND(AVG(otd_pct), 2) AS avg_tier_otd_pct,
    SUM(late_orders) AS total_late_orders,
    ROUND(AVG(avg_delay), 2) AS avg_delay_days
FROM vendor_performance
GROUP BY 
    CASE 
        WHEN otd_pct >= 85.0 THEN 'Tier 1 (>=85% OTD)'
        WHEN otd_pct >= 70.0 THEN 'Tier 2 (70-84% OTD)'
        ELSE 'Tier 3 (<70% OTD)'
    END
ORDER BY calculated_vendor_tier ASC;