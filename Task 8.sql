SELECT 
    shipment_mode, -- Replace with 'shipping_method', 'carrier_mode', or 'transport_mode' if named differently
    COUNT(*) AS total_shipment_volume,
    
    -- Total Freight Cost per Shipping Method
    ROUND(SUM(Freight_Cost_INR), 2) AS total_freight_cost,
    
    -- Average Freight Cost per Shipment
    ROUND(AVG(Freight_Cost_INR), 2) AS avg_freight_cost_per_shipment,
    
    -- Min and Max freight cost to check for outliers/expedited spikes
    ROUND(MIN(Freight_Cost_INR), 2) AS min_freight_cost,
    ROUND(MAX(Freight_Cost_INR), 2) AS max_freight_cost,
    
    -- Share of Total Freight Spend
    ROUND(
        (SUM(Freight_Cost_INR) / SUM(SUM(Freight_Cost_INR)) OVER ()) * 100, 
        2
    ) AS pct_share_of_total_freight_spend

FROM shipments_clean -- Replace with 'shipments_clean' or 'freight_logistics'
WHERE Freight_Cost_INR IS NOT NULL 
  AND Freight_Cost_INR >= 0 -- Excludes corrupted/negative freight entries
GROUP BY shipment_mode
ORDER BY total_freight_cost DESC;