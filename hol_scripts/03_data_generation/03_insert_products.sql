-- ============================================================
-- Step 3c: Generate 500 Products (SKUs)
-- ============================================================
-- Cross-joins brands x segments with HASH-based filtering and attributes

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE WYZE_COMP_WH;

TRUNCATE TABLE IF EXISTS WYZE_COMP_ANALYSIS.RAW.PRODUCTS;

INSERT INTO WYZE_COMP_ANALYSIS.RAW.PRODUCTS (
    PRODUCT_ID, ASIN, PRODUCT_NAME, BRAND_ID, SUBCATEGORY_ID, SEGMENT_ID,
    RETAIL_PRICE, RATING, REVIEW_COUNT, CONTENT_SCORE, TITLE_SCORE,
    BULLET_SCORE, IMAGE_SCORE, VIDEO_SCORE, APLUS_SCORE,
    IS_ACTIVE, FIRST_AVAILABLE_DATE
)
WITH brand_segment_cross AS (
    SELECT
        b.BRAND_ID,
        b.BRAND_NAME,
        s.SEGMENT_ID,
        s.SEGMENT_NAME,
        s.SUBCATEGORY_ID,
        ROW_NUMBER() OVER (ORDER BY b.BRAND_ID, s.SEGMENT_ID) AS rn,
        MOD(ABS(HASH(b.BRAND_ID || '-' || s.SEGMENT_ID || 'keep')), 100) AS keep_score
    FROM WYZE_COMP_ANALYSIS.RAW.BRANDS b
    CROSS JOIN WYZE_COMP_ANALYSIS.RAW.SEGMENTS s
),
filtered AS (
    SELECT *
    FROM brand_segment_cross
    WHERE keep_score < 70
    QUALIFY ROW_NUMBER() OVER (ORDER BY BRAND_ID, SEGMENT_ID) <= 500
),
base_prices AS (
    SELECT column1 AS seg_id, column2 AS base_low, column3 AS base_high
    FROM VALUES
        (3001, 20, 45), (3002, 50, 120), (3003, 30, 70), (3004, 80, 200),
        (3005, 40, 100), (3006, 60, 150), (3007, 30, 80), (3008, 80, 200),
        (3009, 80, 200), (3010, 150, 400), (3011, 250, 600), (3012, 25, 80),
        (3013, 30, 90), (3014, 60, 160), (3015, 50, 140)
)
SELECT
    'SKU' || LPAD(ROW_NUMBER() OVER (ORDER BY f.BRAND_ID, f.SEGMENT_ID)::VARCHAR, 5, '0') AS product_id,
    'B0' || UPPER(SUBSTR(MD5(f.BRAND_ID || '-' || f.SEGMENT_ID), 1, 8)) AS asin,
    f.BRAND_NAME || ' ' || f.SEGMENT_NAME ||
        CASE MOD(ABS(HASH(f.BRAND_ID || f.SEGMENT_ID || 'ver')), 5)
            WHEN 0 THEN ' Pro'
            WHEN 1 THEN ' Plus'
            WHEN 2 THEN ' V2'
            WHEN 3 THEN ' Lite'
            ELSE ''
        END AS product_name,
    f.BRAND_ID,
    f.SUBCATEGORY_ID,
    f.SEGMENT_ID,
    ROUND(bp.base_low + MOD(ABS(HASH(f.BRAND_ID || f.SEGMENT_ID || 'price')), (bp.base_high - bp.base_low)), 2) AS retail_price,
    ROUND(3.2 + MOD(ABS(HASH(f.BRAND_ID || f.SEGMENT_ID || 'rating')), 18) / 10.0, 2) AS rating,
    50 + MOD(ABS(HASH(f.BRAND_ID || f.SEGMENT_ID || 'reviews')), 9950) AS review_count,
    ROUND(0.40 + MOD(ABS(HASH(f.BRAND_ID || f.SEGMENT_ID || 'content')), 60) / 100.0, 4) AS content_score,
    ROUND(0.50 + MOD(ABS(HASH(f.BRAND_ID || f.SEGMENT_ID || 'title')), 50) / 100.0, 4) AS title_score,
    ROUND(0.30 + MOD(ABS(HASH(f.BRAND_ID || f.SEGMENT_ID || 'bullet')), 70) / 100.0, 4) AS bullet_score,
    ROUND(0.40 + MOD(ABS(HASH(f.BRAND_ID || f.SEGMENT_ID || 'image')), 60) / 100.0, 4) AS image_score,
    ROUND(0.00 + MOD(ABS(HASH(f.BRAND_ID || f.SEGMENT_ID || 'video')), 100) / 100.0, 4) AS video_score,
    ROUND(0.00 + MOD(ABS(HASH(f.BRAND_ID || f.SEGMENT_ID || 'aplus')), 100) / 100.0, 4) AS aplus_score,
    CASE WHEN MOD(ABS(HASH(f.BRAND_ID || f.SEGMENT_ID || 'active')), 100) < 90 THEN TRUE ELSE FALSE END AS is_active,
    DATEADD(day, -MOD(ABS(HASH(f.BRAND_ID || f.SEGMENT_ID || 'avail')), 1460), CURRENT_DATE()) AS first_available_date
FROM filtered f
LEFT JOIN base_prices bp ON f.SEGMENT_ID = bp.seg_id;

SELECT COUNT(*) AS total_products FROM WYZE_COMP_ANALYSIS.RAW.PRODUCTS;
SELECT BRAND_ID, COUNT(*) AS skus FROM WYZE_COMP_ANALYSIS.RAW.PRODUCTS GROUP BY BRAND_ID ORDER BY skus DESC LIMIT 10;
