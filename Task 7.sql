SELECT 
    warehouse_id,
    product_sku,
    product_category,
    stock_on_hand,
    units_sold_last_month,
    
    -- Item-level annualized turnover rate
    ROUND(
        (units_sold_last_month * 12) / NULLIF(stock_on_hand, 0), 
        2
    ) AS sku_turnover_rate,
    
    -- Calculate capital tied up in slow-moving stock (if unit_cost exists)
    -- ROUND(stock_on_hand * unit_cost, 2) AS tied_up_working_capital,
    
    1 AS overstock_risk_flag

FROM inventory_summary_clean
WHERE stock_on_hand > 0
GROUP BY warehouse_id, product_sku, product_category, stock_on_hand, units_sold_last_month
HAVING sku_turnover_rate < 4.00
ORDER BY sku_turnover_rate ASC, stock_on_hand DESC;