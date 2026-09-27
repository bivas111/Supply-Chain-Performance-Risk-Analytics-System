SELECT 
    Return_Reason,
    
    -- Frequency & Volume Metrics
    COUNT(*) AS total_return_incidents,
    SUM(Return_Qty) AS total_returned_units,
    
    -- Monetary Financial Loss
    ROUND(
        SUM(
            CASE 
                WHEN return_value IS NOT NULL THEN return_value 
                ELSE (Return_Qty * Unit_Price_INR) 
            END
        ), 
        2
    ) AS total_return_financial_value,
    
    -- Percentage Share of Total Return Value (Window Function)
    ROUND(
        (
            SUM(
                CASE 
                    WHEN return_value IS NOT NULL THEN return_value 
                    ELSE (Return_Qty * Unit_Price_INR) 
                END
            ) / SUM(SUM(CASE WHEN return_value IS NOT NULL THEN return_value ELSE (Return_Qty * Unit_Price_INR) END)) OVER ()
        ) * 100, 
        2
    ) AS pct_share_of_total_return_value

FROM returns_clean
WHERE Return_Reason IS NOT NULL
GROUP BY Return_Reason
ORDER BY total_return_financial_value DESC, total_returned_units DESC;