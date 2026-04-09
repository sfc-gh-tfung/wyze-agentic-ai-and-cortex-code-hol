-- ============================================================
-- Step 6: AI SQL Analysis on Product Reviews
-- ============================================================
-- Uses AI_SENTIMENT and CORTEX.COMPLETE to extract structured
-- insights from unstructured product review text files.
--
-- AI_SENTIMENT returns: 'positive', 'negative', or 'mixed'
-- CORTEX.COMPLETE uses an LLM to extract themes from free text.

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE WYZE_COMP_WH;

-- ============================================================
-- 1. Sentiment Analysis using AI_SENTIMENT
-- ============================================================
-- AI_SENTIMENT analyzes text and returns sentiment classification.
-- We extract the top-level sentiment category for each review.

CREATE OR REPLACE TABLE WYZE_COMP_ANALYSIS.RAW.REVIEW_SENTIMENT AS
SELECT
    FILE_NAME,
    BRAND_NAME,
    PRODUCT_SEGMENT,
    REVIEW_DATE,
    AI_SENTIMENT(CONTENT):categories[0]:sentiment::VARCHAR AS SENTIMENT_CATEGORY,
    CONTENT
FROM WYZE_COMP_ANALYSIS.RAW.PRODUCT_REVIEW_SOURCE;

SELECT SENTIMENT_CATEGORY, COUNT(*) AS CNT
FROM WYZE_COMP_ANALYSIS.RAW.REVIEW_SENTIMENT
GROUP BY SENTIMENT_CATEGORY
ORDER BY CNT DESC;

-- ============================================================
-- 2. Theme Extraction using CORTEX.COMPLETE
-- ============================================================
-- Uses a Cortex LLM to extract key themes from each review.

CREATE OR REPLACE TABLE WYZE_COMP_ANALYSIS.RAW.REVIEW_THEMES AS
SELECT
    FILE_NAME,
    BRAND_NAME,
    PRODUCT_SEGMENT,
    REVIEW_DATE,
    SNOWFLAKE.CORTEX.COMPLETE(
        'mistral-large2',
        'You are a product analyst. Given this Amazon product review summary, extract exactly 3 bullet points: ' ||
        '(1) TOP_PRAISE: the single most praised feature, ' ||
        '(2) TOP_COMPLAINT: the single most common complaint, ' ||
        '(3) COMPETITOR_MENTION: any competitor brand mentioned, or "none". ' ||
        'Return ONLY the 3 lines, no other text. ' ||
        'Review: ' || LEFT(CONTENT, 3000)
    ) AS THEME_EXTRACTION,
    CONTENT
FROM WYZE_COMP_ANALYSIS.RAW.PRODUCT_REVIEW_SOURCE;

SELECT BRAND_NAME, PRODUCT_SEGMENT, LEFT(THEME_EXTRACTION, 300) AS THEMES_PREVIEW
FROM WYZE_COMP_ANALYSIS.RAW.REVIEW_THEMES
LIMIT 5;

-- ============================================================
-- 3. Brand-Level Sentiment Summary
-- ============================================================
-- Aggregates sentiment to the brand level for competitive analysis.
-- Includes BRAND_ID to support semantic view FK relationship.

CREATE OR REPLACE TABLE WYZE_COMP_ANALYSIS.FINAL.BRAND_REVIEW_SENTIMENT AS
SELECT
    b.BRAND_ID,
    rs.BRAND_NAME,
    COUNT(*) AS TOTAL_REVIEWS,
    SUM(CASE WHEN rs.SENTIMENT_CATEGORY = 'positive' THEN 1 ELSE 0 END) AS POSITIVE_REVIEWS,
    SUM(CASE WHEN rs.SENTIMENT_CATEGORY = 'negative' THEN 1 ELSE 0 END) AS NEGATIVE_REVIEWS,
    SUM(CASE WHEN rs.SENTIMENT_CATEGORY = 'mixed' THEN 1 ELSE 0 END) AS MIXED_REVIEWS,
    ROUND(SUM(CASE WHEN rs.SENTIMENT_CATEGORY = 'positive' THEN 1
                   WHEN rs.SENTIMENT_CATEGORY = 'negative' THEN -1
                   ELSE 0 END)::FLOAT / NULLIF(COUNT(*), 0), 3) AS SENTIMENT_SCORE,
    CASE
        WHEN ROUND(SUM(CASE WHEN rs.SENTIMENT_CATEGORY = 'positive' THEN 1
                   WHEN rs.SENTIMENT_CATEGORY = 'negative' THEN -1
                   ELSE 0 END)::FLOAT / NULLIF(COUNT(*), 0), 3) >= 0.3 THEN 'Strong Positive'
        WHEN ROUND(SUM(CASE WHEN rs.SENTIMENT_CATEGORY = 'positive' THEN 1
                   WHEN rs.SENTIMENT_CATEGORY = 'negative' THEN -1
                   ELSE 0 END)::FLOAT / NULLIF(COUNT(*), 0), 3) >= 0.0 THEN 'Leaning Positive'
        WHEN ROUND(SUM(CASE WHEN rs.SENTIMENT_CATEGORY = 'positive' THEN 1
                   WHEN rs.SENTIMENT_CATEGORY = 'negative' THEN -1
                   ELSE 0 END)::FLOAT / NULLIF(COUNT(*), 0), 3) >= -0.3 THEN 'Leaning Negative'
        ELSE 'Strong Negative'
    END AS SENTIMENT_TIER,
    MAX(rs.REVIEW_DATE) AS LATEST_REVIEW_DATE
FROM WYZE_COMP_ANALYSIS.RAW.REVIEW_SENTIMENT rs
JOIN WYZE_COMP_ANALYSIS.RAW.BRANDS b ON rs.BRAND_NAME = b.BRAND_NAME
GROUP BY b.BRAND_ID, rs.BRAND_NAME;

SELECT * FROM WYZE_COMP_ANALYSIS.FINAL.BRAND_REVIEW_SENTIMENT
ORDER BY SENTIMENT_SCORE DESC;

-- ============================================================
-- 4. Segment-Level Sentiment Summary
-- ============================================================
-- Shows sentiment by product segment (e.g., Budget Indoor Cam vs Premium Outdoor Cam).

CREATE OR REPLACE TABLE WYZE_COMP_ANALYSIS.FINAL.SEGMENT_REVIEW_SENTIMENT AS
SELECT
    BRAND_NAME,
    PRODUCT_SEGMENT,
    COUNT(*) AS TOTAL_REVIEWS,
    SUM(CASE WHEN SENTIMENT_CATEGORY = 'positive' THEN 1 ELSE 0 END) AS POSITIVE_REVIEWS,
    SUM(CASE WHEN SENTIMENT_CATEGORY = 'negative' THEN 1 ELSE 0 END) AS NEGATIVE_REVIEWS,
    ROUND(SUM(CASE WHEN SENTIMENT_CATEGORY = 'positive' THEN 1
                   WHEN SENTIMENT_CATEGORY = 'negative' THEN -1
                   ELSE 0 END)::FLOAT / NULLIF(COUNT(*), 0), 3) AS SENTIMENT_SCORE
FROM WYZE_COMP_ANALYSIS.RAW.REVIEW_SENTIMENT
GROUP BY BRAND_NAME, PRODUCT_SEGMENT;

SELECT * FROM WYZE_COMP_ANALYSIS.FINAL.SEGMENT_REVIEW_SENTIMENT
ORDER BY SENTIMENT_SCORE DESC
LIMIT 10;

-- ============================================================
-- VERIFICATION
-- ============================================================

SELECT 'REVIEW_SENTIMENT' AS TBL, COUNT(*) AS CNT FROM WYZE_COMP_ANALYSIS.RAW.REVIEW_SENTIMENT
UNION ALL SELECT 'REVIEW_THEMES', COUNT(*) FROM WYZE_COMP_ANALYSIS.RAW.REVIEW_THEMES
UNION ALL SELECT 'BRAND_REVIEW_SENTIMENT', COUNT(*) FROM WYZE_COMP_ANALYSIS.FINAL.BRAND_REVIEW_SENTIMENT
UNION ALL SELECT 'SEGMENT_REVIEW_SENTIMENT', COUNT(*) FROM WYZE_COMP_ANALYSIS.FINAL.SEGMENT_REVIEW_SENTIMENT;
