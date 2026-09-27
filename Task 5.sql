SELECT 
    product_category,
    COUNT(DISTINCT vendor_id) AS active_vendors_count,
    COUNT(*) AS total_orders_count,
    
    -- Total Spend per Product Category
    ROUND(SUM(Total_Order_Value), 2) AS category_total_spend,
    
    -- Average Order Value per Category
    ROUND(AVG(Total_Order_Value), 2) AS avg_order_value,
    
    -- Percentage Share of Total Company Spend (Window Function)
    ROUND(
        (SUM(Total_Order_Value) / SUM(SUM(Total_Order_Value)) OVER ()) * 100, 
        2
    ) AS spend_share_percentage

FROM purchase_orders_clean
GROUP BY product_category
ORDER BY category_total_spend DESC;