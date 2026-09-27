SELECT 
    vendor_id,
    COUNT(*) AS total_orders,
    
    -- Total Spend per Vendor
    ROUND(SUM(Total_Order_Value), 2) AS total_procurement_spend,
    
    -- Average Spend per Order
    ROUND(AVG(Total_Order_Value), 2) AS avg_order_value,
    
    -- Percentage Share of Total Company Procurement Spend
    ROUND(
        (SUM(Total_Order_Value) / (SELECT SUM(Total_Order_Value) FROM purchase_orders_clean)) * 100, 
        2
    ) AS pct_share_of_total_spend

FROM purchase_orders_clean
GROUP BY vendor_id
ORDER BY total_procurement_spend DESC
LIMIT 10;