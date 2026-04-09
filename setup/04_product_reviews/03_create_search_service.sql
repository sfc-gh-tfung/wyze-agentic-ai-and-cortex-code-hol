-- ============================================================
-- Step 4c: Create Cortex Search Service on Reviews
-- ============================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE WYZE_COMP_WH;

CREATE OR REPLACE CORTEX SEARCH SERVICE WYZE_COMP_ANALYSIS.FINAL.PRODUCT_REVIEW_SEARCH
    ON CONTENT
    ATTRIBUTES FILE_NAME, BRAND_NAME, PRODUCT_SEGMENT, REVIEW_DATE
    WAREHOUSE = WYZE_COMP_WH
    TARGET_LAG = '1 day'
    AS (
        SELECT
            FILE_NAME,
            BRAND_NAME,
            PRODUCT_SEGMENT,
            REVIEW_DATE,
            CONTENT
        FROM WYZE_COMP_ANALYSIS.RAW.PRODUCT_REVIEW_SOURCE
    );
