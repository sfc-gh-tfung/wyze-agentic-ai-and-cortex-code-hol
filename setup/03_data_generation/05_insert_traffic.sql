-- ============================================================
-- Step 3e: Generate Traffic Data (~5000 rows)
-- ============================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE WYZE_COMP_WH;

TRUNCATE TABLE IF EXISTS WYZE_COMP_ANALYSIS.RAW.ATLAS_TRAFFIC;

INSERT INTO WYZE_COMP_ANALYSIS.RAW.ATLAS_TRAFFIC (
    TRAFFIC_ID, PRODUCT_ID, BRAND_ID, WEEK_ID, SEARCH_TERM,
    ORGANIC_IMPRESSIONS, PAID_IMPRESSIONS, ORGANIC_CLICKS, PAID_CLICKS, AD_SPEND
)
WITH search_terms AS (
    SELECT column1 AS term_id, column2 AS term
    FROM VALUES
        (1, 'security camera'), (2, 'outdoor security camera'), (3, 'indoor security camera'),
        (4, 'wireless security camera'), (5, 'home security camera'), (6, 'wifi camera'),
        (7, 'doorbell camera'), (8, 'ring doorbell'), (9, 'baby monitor'),
        (10, 'pet camera'), (11, 'nanny cam'), (12, 'surveillance camera'),
        (13, 'night vision camera'), (14, 'solar security camera'), (15, 'battery camera'),
        (16, 'floodlight camera'), (17, 'ptz camera'), (18, 'pan tilt camera'),
        (19, 'security camera system'), (20, 'nvr security system'),
        (21, 'ring camera'), (22, 'blink camera'), (23, 'arlo camera'),
        (24, 'nest camera'), (25, 'wyze camera'), (26, 'reolink camera'),
        (27, 'eufy camera'), (28, 'simplisafe camera'), (29, 'tapo camera'),
        (30, 'outdoor camera wireless'), (31, 'mini camera'), (32, 'hidden camera'),
        (33, 'dome camera'), (34, 'bullet camera'), (35, 'ip camera'),
        (36, 'smart home camera'), (37, 'alexa camera'), (38, 'google home camera'),
        (39, 'camera with two way audio'), (40, 'camera with siren'),
        (41, 'night owl camera'), (42, 'lorex camera'), (43, 'amcrest camera'),
        (44, '4k security camera'), (45, '2k security camera'), (46, '1080p camera'),
        (47, 'cloud storage camera'), (48, 'local storage camera'),
        (49, 'no subscription camera'), (50, 'camera sd card'),
        (51, 'front door camera'), (52, 'backyard camera'), (53, 'garage camera'),
        (54, 'driveway camera'), (55, 'porch camera'), (56, 'window camera'),
        (57, 'magnetic camera'), (58, 'spotlight camera'), (59, 'color night vision'),
        (60, 'person detection camera'), (61, 'vehicle detection camera'),
        (62, 'package detection camera'), (63, 'animal detection camera'),
        (64, 'camera with ai'), (65, 'best security camera 2025'),
        (66, 'wyze'), (67, 'wyze cam'), (68, 'wyze doorbell'),
        (69, 'wyze outdoor camera'), (70, 'wyze cam v3'),
        (71, 'wyze cam og'), (72, 'wyze garage camera'),
        (73, 'wyze window camera'), (74, 'wyze cam pan')
),
weeks AS (
    SELECT column1 AS WEEK_ID
    FROM VALUES
        (202540),(202541),(202542),(202543),(202544),(202545),(202546),(202547),
        (202548),(202549),(202550),(202551),(202552),
        (202601),(202602),(202603),(202604),(202605),(202606),
        (202607),(202608),(202609),(202610),(202611),(202612),(202613),(202614)
),
product_term_weeks AS (
    SELECT
        p.PRODUCT_ID,
        p.BRAND_ID,
        st.term_id,
        st.term AS SEARCH_TERM,
        w.WEEK_ID,
        MOD(ABS(HASH(p.PRODUCT_ID || st.term_id || w.WEEK_ID || 'tkeep')), 100) AS keep_pct
    FROM WYZE_COMP_ANALYSIS.RAW.PRODUCTS p
    CROSS JOIN search_terms st
    CROSS JOIN weeks w
    WHERE p.IS_ACTIVE = TRUE
),
filtered AS (
    SELECT *
    FROM product_term_weeks
    WHERE keep_pct < 1
    QUALIFY ROW_NUMBER() OVER (ORDER BY PRODUCT_ID, term_id, WEEK_ID) <= 5000
)
SELECT
    'TRF' || LPAD(ROW_NUMBER() OVER (ORDER BY PRODUCT_ID, term_id, WEEK_ID)::VARCHAR, 6, '0') AS traffic_id,
    PRODUCT_ID,
    BRAND_ID,
    WEEK_ID,
    SEARCH_TERM,
    500 + MOD(ABS(HASH(PRODUCT_ID || SEARCH_TERM || WEEK_ID || 'oimp')), 49500) AS organic_impressions,
    100 + MOD(ABS(HASH(PRODUCT_ID || SEARCH_TERM || WEEK_ID || 'pimp')), 19900) AS paid_impressions,
    10 + MOD(ABS(HASH(PRODUCT_ID || SEARCH_TERM || WEEK_ID || 'oclk')), 490) AS organic_clicks,
    5 + MOD(ABS(HASH(PRODUCT_ID || SEARCH_TERM || WEEK_ID || 'pclk')), 295) AS paid_clicks,
    ROUND(5.0 + MOD(ABS(HASH(PRODUCT_ID || SEARCH_TERM || WEEK_ID || 'spend')), 4950) / 10.0, 2) AS ad_spend
FROM filtered;

SELECT COUNT(*) AS total_traffic FROM WYZE_COMP_ANALYSIS.RAW.ATLAS_TRAFFIC;
SELECT SEARCH_TERM, COUNT(*) AS occurrences FROM WYZE_COMP_ANALYSIS.RAW.ATLAS_TRAFFIC GROUP BY SEARCH_TERM ORDER BY occurrences DESC LIMIT 10;
