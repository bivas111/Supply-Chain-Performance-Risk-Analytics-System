SELECT 
    warehouse_id,
    COUNT(DISTINCT product_sku) AS total_skus_stored,
    SUM(stock_on_hand) AS total_units_on_hand,
    
    -- Average units held per SKU in this warehouse
    ROUND(AVG(stock_on_hand), 2) AS avg_units_per_sku,
    
    -- Percentage Share of Company-Wide Total Inventory Units
    ROUND(
        (SUM(stock_on_hand) / SUM(SUM(stock_on_hand)) OVER ()) * 100, 
        2
    ) AS pct_share_of_total_stock,
    
    -- Stock Distribution Imbalance Status
    CASE 
        WHEN (SUM(stock_on_hand) / SUM(SUM(stock_on_hand)) OVER ()) * 100 > 35.0 THEN 'High Concentration (Over-indexed)'
        WHEN (SUM(stock_on_hand) / SUM(SUM(stock_on_hand)) OVER ()) * 100 < 10.0 THEN 'Low Concentration (Under-indexed)'
        ELSE 'Balanced Allocation'
    END AS distribution_balance_status

FROM inventory_summary_clean
GROUP BY warehouse_id
-- Added all non-aggregated columns/expressions to comply with ONLY_FULL_GROUP_BY
ORDER BY total_units_on_hand DESC;