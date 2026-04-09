-- ============================================================
-- Step 4a: Create Stage for Product Reviews
-- ============================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE WYZE_COMP_WH;
USE DATABASE WYZE_COMP_ANALYSIS;
USE SCHEMA RAW;

CREATE OR REPLACE STAGE WYZE_COMP_ANALYSIS.RAW.PRODUCT_REVIEWS_STAGE
    DIRECTORY = (ENABLE = TRUE)
    ENCRYPTION = (TYPE = 'SNOWFLAKE_SSE');

SHOW STAGES LIKE 'PRODUCT_REVIEWS_STAGE' IN SCHEMA WYZE_COMP_ANALYSIS.RAW;

-- ============================================================
-- MANUAL STEP: Upload review files via Snowsight
-- ============================================================
-- 1. Navigate to Data > Databases > WYZE_COMP_ANALYSIS > RAW > Stages
-- 2. Click on PRODUCT_REVIEWS_STAGE
-- 3. Click + Files > Select all .txt files from unstructured_data/product_reviews/
-- 4. Click Upload
-- ============================================================

ALTER STAGE WYZE_COMP_ANALYSIS.RAW.PRODUCT_REVIEWS_STAGE REFRESH;

SELECT * FROM DIRECTORY(@WYZE_COMP_ANALYSIS.RAW.PRODUCT_REVIEWS_STAGE) LIMIT 10;
