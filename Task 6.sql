SELECT 
    warehouse_id, -- Replace with 'warehouse_location' or 'facility' if named differently
    product_sku,
    product_category,
    stock_on_hand,
    reorder_level,
    
    -- Calculate how many units below reorder level the SKU currently sits
    (reorder_level - stock_on_hand) AS deficit_quantity,
    
    -- Stockout Risk Flag
    1 AS stockout_risk_flag

FROM inventory_summary_clean
WHERE stock_on_hand <= reorder_level
ORDER BY deficit_quantity DESC, warehouse_id ASC;