-- ============================================================
-- Step 3g: Generate Channel Data (1P vs 3P) (~10000 rows
-- ============================================================
-- Populates both ATLAS_CHANNEL_CATEGORY and ATLAS_CHANNEL_SEGMENT

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE WYZE_COMP_WH;

-- ============================================================
-- Channel by Category (~5000 rows)
-- ============================================================

TRUNCATE TABLE IF EXISTS WYZE_COMP_ANALYSIS.RAW.ATLAS_CHANNEL_CATEGORY;

INSERT INTO WYZE_COMP_ANALYSIS.RAW.ATLAS_CHANNEL_CATEGORY (
    CHANNEL_ID, BRAND_ID, WEEK_ID, SUBCATEGORY_ID,
    RETAIL_SALES, UNITS_SOLD, RETAIL_PRICE,
    ONEP_SALES, THREEP_SALES, ONEP_UNITS_SOLD, THREEP_UNITS_SOLD
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
brand_subcat_weeks AS (
    SELECT
        b.BRAND_ID,
        sc.SUBCATEGORY_ID,
        w.WEEK_ID,
        MOD(ABS(HASH(b.BRAND_ID || sc.SUBCATEGORY_ID || w.WEEK_ID || 'ckeep')), 100) AS keep_pct
    FROM WYZE_COMP_ANALYSIS.RAW.BRANDS b
    CROSS JOIN WYZE_COMP_ANALYSIS.RAW.SUBCATEGORIES sc
    CROSS JOIN weeks w
),
filtered AS (
    SELECT *
    FROM brand_subcat_weeks
    WHERE keep_pct < 3
    QUALIFY ROW_NUMBER() OVER (ORDER BY BRAND_ID, SUBCATEGORY_ID, WEEK_ID) <= 5000
)
SELECT
    'CHC' || LPAD(ROW_NUMBER() OVER (ORDER BY BRAND_ID, SUBCATEGORY_ID, WEEK_ID)::VARCHAR, 6, '0'),
    BRAND_ID,
    WEEK_ID,
    SUBCATEGORY_ID,
    ROUND((500 + MOD(ABS(HASH(BRAND_ID || SUBCATEGORY_ID || WEEK_ID || 'csales')), 49500)), 2) AS retail_sales,
    5 + MOD(ABS(HASH(BRAND_ID || SUBCATEGORY_ID || WEEK_ID || 'cunits')), 495) AS units_sold,
    ROUND(20 + MOD(ABS(HASH(BRAND_ID || SUBCATEGORY_ID || WEEK_ID || 'cprice')), 280), 2) AS retail_price,
    ROUND(
        (500 + MOD(ABS(HASH(BRAND_ID || SUBCATEGORY_ID || WEEK_ID || 'csales')), 49500)) *
        (0.30 + MOD(ABS(HASH(BRAND_ID || SUBCATEGORY_ID || WEEK_ID || '1ppct')), 50) / 100.0),
    2) AS onep_sales,
    ROUND(
        (500 + MOD(ABS(HASH(BRAND_ID || SUBCATEGORY_ID || WEEK_ID || 'csales')), 49500)) *
        (0.20 + MOD(ABS(HASH(BRAND_ID || SUBCATEGORY_ID || WEEK_ID || '3ppct')), 50) / 100.0),
    2) AS threep_sales,
    ROUND(
        (5 + MOD(ABS(HASH(BRAND_ID || SUBCATEGORY_ID || WEEK_ID || 'cunits')), 495)) *
        (0.30 + MOD(ABS(HASH(BRAND_ID || SUBCATEGORY_ID || WEEK_ID || '1ppct')), 50) / 100.0)
    ) AS onep_units_sold,
    ROUND(
        (5 + MOD(ABS(HASH(BRAND_ID || SUBCATEGORY_ID || WEEK_ID || 'cunits')), 495)) *
        (0.20 + MOD(ABS(HASH(BRAND_ID || SUBCATEGORY_ID || WEEK_ID || '3ppct')), 50) / 100.0)
    ) AS threep_units_sold
FROM filtered;

-- ============================================================
-- Channel by Segment (~5000 rows)
-- ============================================================

TRUNCATE TABLE IF EXISTS WYZE_COMP_ANALYSIS.RAW.ATLAS_CHANNEL_SEGMENT;

INSERT INTO WYZE_COMP_ANALYSIS.RAW.ATLAS_CHANNEL_SEGMENT (
    CHANNEL_SEG_ID, BRAND_ID, WEEK_ID, SEGMENT_ID,
    RETAIL_SALES, UNITS_SOLD,
    ONEP_SALES, THREEP_SALES, ONEP_UNITS_SOLD, THREEP_UNITS_SOLD
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
brand_seg_weeks AS (
    SELECT
        b.BRAND_ID,
        s.SEGMENT_ID,
        w.WEEK_ID,
        MOD(ABS(HASH(b.BRAND_ID || s.SEGMENT_ID || w.WEEK_ID || 'skeep')), 100) AS keep_pct
    FROM WYZE_COMP_ANALYSIS.RAW.BRANDS b
    CROSS JOIN WYZE_COMP_ANALYSIS.RAW.SEGMENTS s
    CROSS JOIN weeks w
),
filtered AS (
    SELECT *
    FROM brand_seg_weeks
    WHERE keep_pct < 2
    QUALIFY ROW_NUMBER() OVER (ORDER BY BRAND_ID, SEGMENT_ID, WEEK_ID) <= 5000
)
SELECT
    'CHS' || LPAD(ROW_NUMBER() OVER (ORDER BY BRAND_ID, SEGMENT_ID, WEEK_ID)::VARCHAR, 6, '0'),
    BRAND_ID,
    WEEK_ID,
    SEGMENT_ID,
    ROUND((500 + MOD(ABS(HASH(BRAND_ID || SEGMENT_ID || WEEK_ID || 'ssales')), 49500)), 2) AS retail_sales,
    5 + MOD(ABS(HASH(BRAND_ID || SEGMENT_ID || WEEK_ID || 'sunits')), 495) AS units_sold,
    ROUND(
        (500 + MOD(ABS(HASH(BRAND_ID || SEGMENT_ID || WEEK_ID || 'ssales')), 49500)) *
        (0.30 + MOD(ABS(HASH(BRAND_ID || SEGMENT_ID || WEEK_ID || 's1ppct')), 50) / 100.0),
    2) AS onep_sales,
    ROUND(
        (500 + MOD(ABS(HASH(BRAND_ID || SEGMENT_ID || WEEK_ID || 'ssales')), 49500)) *
        (0.20 + MOD(ABS(HASH(BRAND_ID || SEGMENT_ID || WEEK_ID || 's3ppct')), 50) / 100.0),
    2) AS threep_sales,
    ROUND(
        (5 + MOD(ABS(HASH(BRAND_ID || SEGMENT_ID || WEEK_ID || 'sunits')), 495)) *
        (0.30 + MOD(ABS(HASH(BRAND_ID || SEGMENT_ID || WEEK_ID || 's1ppct')), 50) / 100.0)
    ) AS onep_units_sold,
    ROUND(
        (5 + MOD(ABS(HASH(BRAND_ID || SEGMENT_ID || WEEK_ID || 'sunits')), 495)) *
        (0.20 + MOD(ABS(HASH(BRAND_ID || SEGMENT_ID || WEEK_ID || 's3ppct')), 50) / 100.0)
    ) AS threep_units_sold
FROM filtered;

SELECT COUNT(*) AS total_channel_category FROM WYZE_COMP_ANALYSIS.RAW.ATLAS_CHANNEL_CATEGORY;
SELECT COUNT(*) AS total_channel_segment FROM WYZE_COMP_ANALYSIS.RAW.ATLAS_CHANNEL_SEGMENT;

-- ============================================================
-- Verify All Step 3 Data (run after all 03_data_generation scripts)
-- ============================================================

SELECT 'BRANDS' AS TBL, COUNT(*) AS CNT FROM WYZE_COMP_ANALYSIS.RAW.BRANDS
UNION ALL SELECT 'SUBCATEGORIES', COUNT(*) FROM WYZE_COMP_ANALYSIS.RAW.SUBCATEGORIES
UNION ALL SELECT 'SEGMENTS', COUNT(*) FROM WYZE_COMP_ANALYSIS.RAW.SEGMENTS
UNION ALL SELECT 'PRODUCTS', COUNT(*) FROM WYZE_COMP_ANALYSIS.RAW.PRODUCTS
UNION ALL SELECT 'ATLAS_SALES', COUNT(*) FROM WYZE_COMP_ANALYSIS.RAW.ATLAS_SALES
UNION ALL SELECT 'ATLAS_TRAFFIC', COUNT(*) FROM WYZE_COMP_ANALYSIS.RAW.ATLAS_TRAFFIC
UNION ALL SELECT 'ATLAS_PROMOTIONS', COUNT(*) FROM WYZE_COMP_ANALYSIS.RAW.ATLAS_PROMOTIONS
UNION ALL SELECT 'ATLAS_CHANNEL_CATEGORY', COUNT(*) FROM WYZE_COMP_ANALYSIS.RAW.ATLAS_CHANNEL_CATEGORY
UNION ALL SELECT 'ATLAS_CHANNEL_SEGMENT', COUNT(*) FROM WYZE_COMP_ANALYSIS.RAW.ATLAS_CHANNEL_SEGMENT;
