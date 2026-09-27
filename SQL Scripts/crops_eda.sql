CREATE DATABASE farm_feasibility;
USE farm_feasibility;
SHOW tables; 
SELECT * FROM crop_area_by_year LIMIT 5;
SELECT COUNT(*) FROM crop_yield_per_hectare;

-- Yield trend query
SELECT `Fiscal Year`, wheat AS wheat_yield
FROM crop_yield_per_hectare
ORDER BY `Fiscal Year`;

-- Year-over-year growth rate (how much % change happened) 
SELECT `Fiscal Year`,
       wheat,
       LAG(wheat) OVER (ORDER BY `Fiscal Year`) AS prev_year_wheat,
       ROUND(
           ((wheat - LAG(wheat) OVER (ORDER BY `Fiscal Year`))
           / LAG(wheat) OVER (ORDER BY `Fiscal Year`)) * 100,
           2
       ) AS pct_change
FROM crop_yield_per_hectare;

-- Revenue estimate (profitability core calculation)
SELECT 
    p.`Fiscal Year`,
    p.wheat AS production_tonnes, 
    pr.wheat AS price_per_40kg,
    ROUND(p.wheat * 25 * pr.wheat, 0) AS estimated_revenue_rs
FROM crop_production_by_year p
JOIN crop_procurement_prices pr 
    ON p.`Fiscal Year` = pr.fiscal_year
ORDER BY p.`Fiscal Year`;

-- Input cost side (fertilizer cost trend, for margin proxy)
SELECT fiscal_year, urea, dap
FROM fertilizer_retail_prices
ORDER BY fiscal_year;

-- Combine tables — Net Margin Proxy (revenue vs cost trend together)
SELECT 
    p.`Fiscal Year`,
    ROUND(p.wheat * 25 * pr.wheat, 0) AS revenue,
    f.urea,
    f.dap
FROM crop_production_by_year p
JOIN crop_procurement_prices pr 
    ON p.`Fiscal Year` = pr.fiscal_year
JOIN fertilizer_retail_prices f 
    ON p.`Fiscal Year` = f.fiscal_year
ORDER BY p.`Fiscal Year`;

-- Punjab vs Pakistan comparison
SELECT crop, year, pakistan_value, punjab_value, punjab_pct
FROM punjab_crop_share_vs_pakistan
WHERE metric = 'Production'
ORDER BY crop, year;

-- Land utilization province comparison
SELECT area_name, year, net_area_sown, culturable_waste
FROM land_utilization_by_province
WHERE year = '2024-25';

-- Crop output composition
SELECT crop_category, `2023-24`, `2024-25`
FROM crop_output_composition
WHERE level = 'crop';

-- Multiple crops yield comparison
SELECT 
    `Fiscal Year`,
    wheat,
    rice,
    cotton,
    sugarcane,
    maize
FROM crop_yield_per_hectare
ORDER BY `Fiscal Year`;

-- Production trend
SELECT 
    `Fiscal Year`,
    `Wheat`,
    `Rice`,
    `Cotton (000 tonnes)`,
    `Sugar-cane`,
    `Maize`
FROM crop_production_by_year
ORDER BY `Fiscal Year`;
