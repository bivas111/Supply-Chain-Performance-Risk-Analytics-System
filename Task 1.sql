SELECT 
    COUNT(*) AS total_orders,
    SUM(CASE WHEN late_delivery = 0 THEN 1 ELSE 0 END) AS on_time_orders,
    SUM(CASE WHEN late_delivery = 1 THEN 1 ELSE 0 END) AS late_orders,
    
    -- On-Time Delivery %
    ROUND(AVG(CASE WHEN late_delivery = 0 THEN 1.0 ELSE 0.0 END) * 100, 2) AS on_time_delivery_pct,
    
    -- Benchmark Evaluation
    CASE 
        WHEN AVG(CASE WHEN late_delivery = 0 THEN 1.0 ELSE 0.0 END) * 100 >= 85.00 
            THEN 'MEETS BENCHMARK (>= 85%)'
        ELSE 'BELOW BENCHMARK (< 85%)'
    END AS benchmark_status
FROM purchase_orders_clean;