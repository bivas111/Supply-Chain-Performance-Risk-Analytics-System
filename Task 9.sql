SELECT 
    curr.shipment_month,
    curr.total_volume,
    ROUND(((curr.total_volume - prev.total_volume) / NULLIF(prev.total_volume, 0)) * 100, 2) AS volume_mom_growth_pct,
    curr.total_cost,
    ROUND(((curr.total_cost - prev.total_cost) / NULLIF(prev.total_cost, 0)) * 100, 2) AS cost_mom_growth_pct
FROM (
    SELECT 
        DATE_FORMAT(dispatch_date, '%Y-%m-01') AS shipment_month,
        COUNT(*) AS total_volume,
        SUM(Freight_Cost_INR) AS total_cost
    FROM shipments_clean
    WHERE Freight_Cost_INR >= 0
    GROUP BY DATE_FORMAT(dispatch_date, '%Y-%m-01')
) curr
LEFT JOIN (
    SELECT 
        DATE_FORMAT(dispatch_date, '%Y-%m-01') AS shipment_month,
        COUNT(*) AS total_volume,
        SUM(Freight_Cost_INR) AS total_cost
    FROM shipments_clean
    WHERE Freight_Cost_INR >= 0
    GROUP BY DATE_FORMAT(dispatch_date, '%Y-%m-01')
) prev 
ON curr.shipment_month = DATE_ADD(prev.shipment_month, INTERVAL 1 MONTH)
ORDER BY curr.shipment_month ASC;