-- ============================================================
-- Step 3f: Generate Promotion Data (~3000 rows)
-- ============================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE WYZE_COMP_WH;

TRUNCATE TABLE IF EXISTS WYZE_COMP_ANALYSIS.RAW.ATLAS_PROMOTIONS;

INSERT INTO WYZE_COMP_ANALYSIS.RAW.ATLAS_PROMOTIONS (
    PROMO_ID, PRODUCT_ID, BRAND_ID, WEEK_ID, PROMO_TYPE,
    DISCOUNT_PCT, PROMO_SALES, PROMO_UNITS, BASELINE_SALES, BASELINE_UNITS
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
        p.RETAIL_PRICE,
        w.WEEK_ID,
        MOD(ABS(HASH(p.PRODUCT_ID || w.WEEK_ID || 'pkeep')), 100) AS keep_pct
    FROM WYZE_COMP_ANALYSIS.RAW.PRODUCTS p
    CROSS JOIN weeks w
    WHERE p.IS_ACTIVE = TRUE
),
filtered AS (
    SELECT *
    FROM product_weeks
    WHERE keep_pct < 10
    QUALIFY ROW_NUMBER() OVER (ORDER BY PRODUCT_ID, WEEK_ID) <= 3000
)
SELECT
    'PRM' || LPAD(ROW_NUMBER() OVER (ORDER BY PRODUCT_ID, WEEK_ID)::VARCHAR, 6, '0') AS promo_id,
    PRODUCT_ID,
    BRAND_ID,
    WEEK_ID,
    CASE MOD(ABS(HASH(PRODUCT_ID || WEEK_ID || 'ptype')), 100)
        WHEN 0 THEN 'LIGHTNING_DEAL'
        WHEN 1 THEN 'LIGHTNING_DEAL'
        WHEN 2 THEN 'LIGHTNING_DEAL'
        WHEN 3 THEN 'LIGHTNING_DEAL'
        WHEN 4 THEN 'LIGHTNING_DEAL'
        ELSE
            CASE
                WHEN MOD(ABS(HASH(PRODUCT_ID || WEEK_ID || 'ptype')), 100) < 70 THEN 'COUPON'
                WHEN MOD(ABS(HASH(PRODUCT_ID || WEEK_ID || 'ptype')), 100) < 88 THEN 'BEST_DEAL'
                ELSE 'PRIME_MEMBER'
            END
    END AS promo_type,
    ROUND(5.0 + MOD(ABS(HASH(PRODUCT_ID || WEEK_ID || 'disc')), 350) / 10.0, 2) AS discount_pct,
    ROUND(
        (20 + MOD(ABS(HASH(PRODUCT_ID || WEEK_ID || 'punits')), 280)) *
        RETAIL_PRICE * (1.0 - (5.0 + MOD(ABS(HASH(PRODUCT_ID || WEEK_ID || 'disc')), 350) / 10.0) / 100.0),
    2) AS promo_sales,
    20 + MOD(ABS(HASH(PRODUCT_ID || WEEK_ID || 'punits')), 280) AS promo_units,
    ROUND(
        (5 + MOD(ABS(HASH(PRODUCT_ID || WEEK_ID || 'bunits')), 95)) * RETAIL_PRICE,
    2) AS baseline_sales,
    5 + MOD(ABS(HASH(PRODUCT_ID || WEEK_ID || 'bunits')), 95) AS baseline_units
FROM filtered;

SELECT COUNT(*) AS total_promos FROM WYZE_COMP_ANALYSIS.RAW.ATLAS_PROMOTIONS;
SELECT PROMO_TYPE, COUNT(*) AS cnt, ROUND(AVG(DISCOUNT_PCT),1) AS avg_disc
FROM WYZE_COMP_ANALYSIS.RAW.ATLAS_PROMOTIONS GROUP BY PROMO_TYPE ORDER BY cnt DESC;
