SELECT 
    s.carrier_name,
    COUNT(DISTINCT s.shipment_id) AS total_shipments,
    COUNT(DISTINCT CASE WHEN r.Return_Reason LIKE '%Damage%' THEN s.shipment_id ELSE NULL END) AS damaged_shipments,
    ROUND(
        (COUNT(DISTINCT CASE WHEN r.Return_Reason LIKE '%Damage%' THEN s.shipment_id ELSE NULL END) / COUNT(DISTINCT s.shipment_id)) * 100, 
        2
    ) AS damage_rate_pct

FROM shipments_clean s
LEFT JOIN returns_clean r 
       ON s.PO_ID = r.PO_ID -- Change 'po_number' if named 'purchase_order_id'
GROUP BY s.carrier_name
ORDER BY damage_rate_pct DESC;