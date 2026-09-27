SELECT 
    vendor_id,
    COUNT(*) AS total_orders,
    
    -- Count of late orders
    SUM(CASE WHEN actual_delivery_date > Delivery_Delay_Days THEN 1 ELSE 0 END) AS total_late_orders,
    
    -- On-Time Delivery Percentage
    ROUND(
        (SUM(CASE WHEN actual_delivery_date <= Delivery_Delay_Days THEN 1 ELSE 0 END) / COUNT(*)) * 100, 
        2
    ) AS on_time_delivery_pct,
    
    -- Total cumulative days delayed across all orders
    SUM(
        CASE 
            WHEN actual_delivery_date > Delivery_Delay_Days 
            THEN DATEDIFF(actual_delivery_date, Delivery_Delay_Days) 
            ELSE 0 
        END
    ) AS total_delay_days,
    
    -- Average delay in days across ONLY late orders
    ROUND(
        AVG(
            CASE 
                WHEN actual_delivery_date > Delivery_Delay_Days 
                THEN DATEDIFF(actual_delivery_date, Delivery_Delay_Days) 
                ELSE NULL 
            END
        ), 
        2
    ) AS avg_days_late_per_delayed_order

FROM purchase_orders_clean
WHERE actual_delivery_date IS NOT NULL -- Exclude in-transit/active orders
GROUP BY vendor_id
HAVING total_late_orders > 0
ORDER BY total_late_orders DESC, total_delay_days DESC;