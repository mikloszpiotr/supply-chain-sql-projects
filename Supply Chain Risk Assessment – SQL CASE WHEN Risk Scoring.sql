-- =====================================================
-- Supply Chain Risk Assessment - SQL CASE WHEN Risk Scoring  
-- Description: Multi-factor risk scoring system for supply chain components
-- Key Skills: CASE WHEN, Risk Calculations, Business Logic
-- =====================================================

SELECT 
    supplier_name,
    product_category,
    lead_time_days,                                    -- Core metric: delivery time
    inventory_level,                                   -- Current stock availability
    quality_score,                                     -- Supplier quality rating (1-100)
    
    -- Risk Level Classification using nested CASE WHEN
    CASE 
        WHEN lead_time_days > 30 AND inventory_level < 100 THEN 'CRITICAL'     -- High lead time + low stock
        WHEN quality_score < 70 OR lead_time_days > 21 THEN 'HIGH'             -- Poor quality or long lead time
        WHEN inventory_level < 200 AND lead_time_days > 14 THEN 'MEDIUM'       -- Moderate stock with medium lead time  
        ELSE 'LOW'                                                              -- All other scenarios are low risk
    END AS risk_level,
    
    -- Numerical Risk Score (0-100) for dashboard visualization
    (lead_time_days * 1.5) +                          -- Lead time penalty (weighted 1.5x)
    (CASE WHEN inventory_level < 100 THEN 40 ELSE 0 END) +    -- Critical stock penalty
    (100 - quality_score) AS risk_score,              -- Quality penalty (inverted score)
    
    -- Action Recommendation based on risk assessment
    CASE 
        WHEN lead_time_days > 30 THEN 'Find backup supplier'           -- Address lead time issues
        WHEN inventory_level < 100 THEN 'Emergency reorder required'   -- Stock shortage action
        WHEN quality_score < 70 THEN 'Quality review needed'           -- Quality improvement
        ELSE 'Monitor regularly'                                        -- Standard monitoring
    END AS recommended_action
    
FROM supply_chain_data
ORDER BY risk_score DESC;                             -- Prioritize highest risk items first
