USE farm_feasibility;

-- Population trend — which animal grows the fastest 
SELECT fiscal_year,
       cattle_million,
       buffalo_million,
       goat_million,
       sheep_million,
       poultry_million
FROM livestock_population_national
ORDER BY fiscal_year;

-- growth trend comparison (side-by-side):
SELECT 
    p.`Fiscal Year`,
    p.`Wheat` AS wheat_production,
    l.cattle_million,
    l.poultry_million
FROM crop_production_by_year p
JOIN livestock_population_national l 
    ON p.`Fiscal Year` = l.fiscal_year
ORDER BY p.`Fiscal Year`;

-- Livestock population growth (2010-11 vs 2023-24)
WITH start_pop AS (
    SELECT cattle_million, buffalo_million, goat_million, sheep_million, poultry_million
    FROM livestock_population_national
    WHERE fiscal_year = '2010-11'
),
end_pop AS (
    SELECT cattle_million, buffalo_million, goat_million, sheep_million, poultry_million
    FROM livestock_population_national
    WHERE fiscal_year = '2023-24'
)
SELECT
    ROUND(end_pop.cattle_million / start_pop.cattle_million, 2) AS cattle_growth_multiple,
    ROUND(end_pop.buffalo_million / start_pop.buffalo_million, 2) AS buffalo_growth_multiple,
    ROUND(end_pop.goat_million / start_pop.goat_million, 2) AS goat_growth_multiple,
    ROUND(end_pop.sheep_million / start_pop.sheep_million, 2) AS sheep_growth_multiple,
    ROUND(end_pop.poultry_million / start_pop.poultry_million, 2) AS poultry_growth_multiple
FROM start_pop, end_pop;

-- Livestock products growth (2010-11 vs 2023-24) — milk, beef, mutton, poultry, eggs sab ek sath
WITH start_prod AS (
    SELECT milk_000t, beef_000t, mutton_000t, poultry_meat_000t, eggs_million
    FROM livestock_products_output
    WHERE fiscal_year = '2010-11'
),
end_prod AS (
    SELECT milk_000t, beef_000t, mutton_000t, poultry_meat_000t, eggs_million
    FROM livestock_products_output
    WHERE fiscal_year = '2023-24'
)
SELECT
    start_prod.milk_000t AS milk_start, end_prod.milk_000t AS milk_end,
    ROUND((end_prod.milk_000t - start_prod.milk_000t) / start_prod.milk_000t * 100, 2) AS milk_growth_pct,

    start_prod.beef_000t AS beef_start, end_prod.beef_000t AS beef_end,
    ROUND((end_prod.beef_000t - start_prod.beef_000t) / start_prod.beef_000t * 100, 2) AS beef_growth_pct,

    start_prod.mutton_000t AS mutton_start, end_prod.mutton_000t AS mutton_end,
    ROUND((end_prod.mutton_000t - start_prod.mutton_000t) / start_prod.mutton_000t * 100, 2) AS mutton_growth_pct,

    start_prod.poultry_meat_000t AS poultry_meat_start, end_prod.poultry_meat_000t AS poultry_meat_end,
    ROUND((end_prod.poultry_meat_000t - start_prod.poultry_meat_000t) / start_prod.poultry_meat_000t * 100, 2) AS poultry_meat_growth_pct,

    start_prod.eggs_million AS eggs_start, end_prod.eggs_million AS eggs_end,
    ROUND((end_prod.eggs_million - start_prod.eggs_million) / start_prod.eggs_million * 100, 2) AS eggs_growth_pct
FROM start_prod, end_prod;

-- Crop vs Livestock growth comparison (wheat vs milk) — using CTE + UNION
WITH wheat_growth AS (
    SELECT 
        'Wheat Production' AS indicator,
        ROUND(
            (MAX(CASE WHEN `Fiscal Year` = '2023-24' THEN `Wheat` END) -
             MAX(CASE WHEN `Fiscal Year` = '2010-11' THEN `Wheat` END))
            / MAX(CASE WHEN `Fiscal Year` = '2010-11' THEN `Wheat` END) * 100, 2
        ) AS growth_pct
    FROM crop_production_by_year
    WHERE `Fiscal Year` IN ('2010-11', '2023-24')
),
milk_growth AS (
    SELECT 
        'Milk Production' AS indicator,
        ROUND(
            (MAX(CASE WHEN fiscal_year = '2023-24' THEN milk_000t END) -
             MAX(CASE WHEN fiscal_year = '2010-11' THEN milk_000t END))
            / MAX(CASE WHEN fiscal_year = '2010-11' THEN milk_000t END) * 100, 2
        ) AS growth_pct
    FROM livestock_products_output
    WHERE fiscal_year IN ('2010-11', '2023-24')
)
SELECT * FROM wheat_growth
UNION ALL
SELECT * FROM milk_growth;

-- Crop vs Livestock — Regional Strength
-- Punjab's share of Pakistan's crop production
SELECT
    p.`Fiscal Year`,
    p.Crop,
    p.Value AS pakistan_production,
    j.Value AS punjab_production,
    ROUND((j.Value / p.Value) * 100, 2) AS punjab_share_pct
FROM punjab_crop_share_vs_pakistan p
JOIN punjab_crop_share_vs_pakistan j
    ON p.`Fiscal Year` = j.`Fiscal Year`
    AND p.Crop = j.Crop
WHERE p.Metric = 'Production'
  AND j.Metric = 'Production'
  AND p.Geography = 'Pakistan'
  AND j.Geography = 'Punjab'
ORDER BY p.Crop, p.`Fiscal Year`;

-- Livestock regional strength
SELECT 
    region,
    cattle,
    buffaloes,
    sheep,
    goats
FROM livestock_population_by_province
WHERE region != 'Pakistan'
ORDER BY (cattle + buffaloes + sheep + goats) DESC;