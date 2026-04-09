-- ============================================================
-- Step 3d: Generate Weekly Sales Data (~5000 rows)
-- ============================================================
-- Cross-joins products x weeks with HASH-based sales metrics

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE WYZE_COMP_WH;

TRUNCATE TABLE IF EXISTS WYZE_COMP_ANALYSIS.RAW.ATLAS_SALES;

INSERT INTO WYZE_COMP_ANALYSIS.RAW.ATLAS_SALES (
    SALE_ID, PRODUCT_ID, BRAND_ID, WEEK_ID, SUBCATEGORY_ID,
    RETAIL_SALES, UNITS_SOLD, RETAIL_PRICE, ORGANIC_SALES, PAID_SALES
)
WITH weeks AS (
    SELECT column1 AS WEEK_ID
    FROM VALUES
        (202501),(202502),(202503),(202504),(202505),(202506),
        (202507),(202508),(202509),(202510),(202511),(202512),
        (202513),(202514),(202515),(202516),(202517),(202518),
        (202519),(202520),(202521),(202522),(202523),(202524),
        (202525),(202526),(202527),(202528),(202529),(202530),
        (202531),(202532),(202533),(202534),(202535),(202536),
        (202537),(202538),(202539),(202540),(202541),(202542),
        (202543),(202544),(202545),(202546),(202547),(202548),
        (202549),(202550),(202551),(202552),
        (202601),(202602),(202603),(202604),(202605),(202606),
        (202607),(202608),(202609),(202610),(202611),(202612),
        (202613),(202614)
),
product_weeks AS (
    SELECT
        p.PRODUCT_ID,
        p.BRAND_ID,
        p.SUBCATEGORY_ID,
        p.RETAIL_PRICE AS BASE_PRICE,
        w.WEEK_ID,
        MOD(ABS(HASH(p.PRODUCT_ID || w.WEEK_ID || 'keep')), 100) AS keep_pct
    FROM WYZE_COMP_ANALYSIS.RAW.PRODUCTS p
    CROSS JOIN weeks w
    WHERE p.IS_ACTIVE = TRUE
),
filtered AS (
    SELECT *
    FROM product_weeks
    WHERE keep_pct < 18
    QUALIFY ROW_NUMBER() OVER (ORDER BY PRODUCT_ID, WEEK_ID) <= 5000
)
SELECT
    'SAL' || LPAD(ROW_NUMBER() OVER (ORDER BY PRODUCT_ID, WEEK_ID)::VARCHAR, 6, '0') AS sale_id,
    PRODUCT_ID,
    BRAND_ID,
    WEEK_ID,
    SUBCATEGORY_ID,
    ROUND(
        (10 + MOD(ABS(HASH(PRODUCT_ID || WEEK_ID || 'units')), 490)) * 
        (BASE_PRICE * (0.85 + MOD(ABS(HASH(PRODUCT_ID || WEEK_ID || 'disc')), 30) / 100.0)),
    2) AS retail_sales,
    10 + MOD(ABS(HASH(PRODUCT_ID || WEEK_ID || 'units')), 490) AS units_sold,
    ROUND(BASE_PRICE * (0.85 + MOD(ABS(HASH(PRODUCT_ID || WEEK_ID || 'disc')), 30) / 100.0), 2) AS retail_price,
    ROUND(
        (10 + MOD(ABS(HASH(PRODUCT_ID || WEEK_ID || 'units')), 490)) * 
        (BASE_PRICE * (0.85 + MOD(ABS(HASH(PRODUCT_ID || WEEK_ID || 'disc')), 30) / 100.0)) *
        (0.50 + MOD(ABS(HASH(PRODUCT_ID || WEEK_ID || 'org')), 40) / 100.0),
    2) AS organic_sales,
    ROUND(
        (10 + MOD(ABS(HASH(PRODUCT_ID || WEEK_ID || 'units')), 490)) * 
        (BASE_PRICE * (0.85 + MOD(ABS(HASH(PRODUCT_ID || WEEK_ID || 'disc')), 30) / 100.0)) *
        (0.10 + MOD(ABS(HASH(PRODUCT_ID || WEEK_ID || 'paid')), 40) / 100.0),
    2) AS paid_sales
FROM filtered;

SELECT COUNT(*) AS total_sales FROM WYZE_COMP_ANALYSIS.RAW.ATLAS_SALES;
SELECT WEEK_ID, COUNT(*) AS rows_per_week, ROUND(SUM(RETAIL_SALES),0) AS total_sales
FROM WYZE_COMP_ANALYSIS.RAW.ATLAS_SALES GROUP BY WEEK_ID ORDER BY WEEK_ID LIMIT 10;
