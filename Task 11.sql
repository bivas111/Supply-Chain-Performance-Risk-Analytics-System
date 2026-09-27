SELECT 
    po.vendor_id,
    
    -- Volume Metrics
    COUNT(DISTINCT r.return_id) AS total_return_incidents,
    SUM(r.Return_Qty) AS total_returned_units,
    
    -- Total Monetary Value of Returns
    ROUND(
        SUM(
            CASE 
                -- If Return_Value is pre-calculated in returns table
                WHEN r.return_value IS NOT NULL THEN r.return_value 
                -- Fallback calculation: Quantity * Unit Price
                ELSE (r.Return_Qty * po.Unit_Price_INR) 
            END
        ), 
        2
    ) AS total_return_monetary_value,
    
    -- Percentage Share of Overall Company Return Value
    ROUND(
        (
            SUM(
                CASE 
                    WHEN r.return_value IS NOT NULL THEN r.return_value 
                    ELSE (r.Return_Qty * po.Unit_Price_INR) 
                END
            ) / SUM(SUM(CASE WHEN r.return_value IS NOT NULL THEN r.return_value ELSE (r.Return_Qty * po.Unit_Price_INR) END)) OVER ()
        ) * 100, 
        2
    ) AS pct_share_of_total_return_value

FROM returns_clean r
JOIN purchase_orders_clean po 
  ON r.PO_ID = po.PO_ID -- Change to 'po_id' or 'order_id' based on your primary key
GROUP BY po.vendor_id
ORDER BY total_return_monetary_value DESC, total_returned_units DESC;