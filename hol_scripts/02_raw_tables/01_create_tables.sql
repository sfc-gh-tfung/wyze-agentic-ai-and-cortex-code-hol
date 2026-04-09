-- ============================================================
-- Step 2: Create All Raw Tables
-- ============================================================
-- Tables for Amazon marketplace competitive analysis data

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE WYZE_COMP_WH;
USE DATABASE WYZE_COMP_ANALYSIS;
USE SCHEMA RAW;

-- ============================================================
-- 2a: BRANDS - Competitor brand reference data
-- ============================================================

CREATE OR REPLACE TABLE WYZE_COMP_ANALYSIS.RAW.BRANDS (
    BRAND_ID NUMBER(10,0) NOT NULL PRIMARY KEY,
    BRAND_NAME VARCHAR(255),
    BRAND_CATEGORY VARCHAR(100),
    HEADQUARTERS VARCHAR(255),
    FOUNDED_YEAR NUMBER(4,0),
    IS_WYZE_COMPETITOR BOOLEAN,
    CREATED_DATE TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================
-- 2b: SUBCATEGORIES - Product subcategory reference
-- ============================================================

CREATE OR REPLACE TABLE WYZE_COMP_ANALYSIS.RAW.SUBCATEGORIES (
    SUBCATEGORY_ID NUMBER(10,0) NOT NULL PRIMARY KEY,
    SUBCATEGORY_NAME VARCHAR(255),
    CATEGORY_NAME VARCHAR(100) DEFAULT 'Security & Surveillance',
    CREATED_DATE TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================
-- 2c: SEGMENTS - Product segment reference
-- ============================================================

CREATE OR REPLACE TABLE WYZE_COMP_ANALYSIS.RAW.SEGMENTS (
    SEGMENT_ID NUMBER(10,0) NOT NULL PRIMARY KEY,
    SEGMENT_NAME VARCHAR(255),
    SUBCATEGORY_ID NUMBER(10,0),
    CREATED_DATE TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================
-- 2d: PRODUCTS - Product catalog (SKU level)
-- ============================================================

CREATE OR REPLACE TABLE WYZE_COMP_ANALYSIS.RAW.PRODUCTS (
    PRODUCT_ID VARCHAR(20) NOT NULL PRIMARY KEY,
    ASIN VARCHAR(20),
    PRODUCT_NAME VARCHAR(500),
    BRAND_ID NUMBER(10,0),
    SUBCATEGORY_ID NUMBER(10,0),
    SEGMENT_ID NUMBER(10,0),
    RETAIL_PRICE NUMBER(10,2),
    RATING NUMBER(3,2),
    REVIEW_COUNT NUMBER(10,0),
    CONTENT_SCORE NUMBER(5,4),
    TITLE_SCORE NUMBER(5,4),
    BULLET_SCORE NUMBER(5,4),
    IMAGE_SCORE NUMBER(5,4),
    VIDEO_SCORE NUMBER(5,4),
    APLUS_SCORE NUMBER(5,4),
    IS_ACTIVE BOOLEAN,
    FIRST_AVAILABLE_DATE DATE,
    CREATED_DATE TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================
-- 2e: ATLAS_SALES - Weekly sales performance by SKU
-- ============================================================

CREATE OR REPLACE TABLE WYZE_COMP_ANALYSIS.RAW.ATLAS_SALES (
    SALE_ID VARCHAR(20) NOT NULL PRIMARY KEY,
    PRODUCT_ID VARCHAR(20),
    BRAND_ID NUMBER(10,0),
    WEEK_ID NUMBER(6,0),
    SUBCATEGORY_ID NUMBER(10,0),
    RETAIL_SALES NUMBER(14,2),
    UNITS_SOLD NUMBER(10,0),
    RETAIL_PRICE NUMBER(10,2),
    ORGANIC_SALES NUMBER(14,2),
    PAID_SALES NUMBER(14,2),
    CREATED_DATE TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================
-- 2f: ATLAS_TRAFFIC - Weekly search traffic by term
-- ============================================================

CREATE OR REPLACE TABLE WYZE_COMP_ANALYSIS.RAW.ATLAS_TRAFFIC (
    TRAFFIC_ID VARCHAR(20) NOT NULL PRIMARY KEY,
    PRODUCT_ID VARCHAR(20),
    BRAND_ID NUMBER(10,0),
    WEEK_ID NUMBER(6,0),
    SEARCH_TERM VARCHAR(500),
    ORGANIC_IMPRESSIONS NUMBER(12,0),
    PAID_IMPRESSIONS NUMBER(12,0),
    ORGANIC_CLICKS NUMBER(10,0),
    PAID_CLICKS NUMBER(10,0),
    AD_SPEND NUMBER(10,2),
    CREATED_DATE TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================
-- 2g: ATLAS_PROMOTIONS - Promotion events by SKU
-- ============================================================

CREATE OR REPLACE TABLE WYZE_COMP_ANALYSIS.RAW.ATLAS_PROMOTIONS (
    PROMO_ID VARCHAR(20) NOT NULL PRIMARY KEY,
    PRODUCT_ID VARCHAR(20),
    BRAND_ID NUMBER(10,0),
    WEEK_ID NUMBER(6,0),
    PROMO_TYPE VARCHAR(50),
    DISCOUNT_PCT NUMBER(5,2),
    PROMO_SALES NUMBER(14,2),
    PROMO_UNITS NUMBER(10,0),
    BASELINE_SALES NUMBER(14,2),
    BASELINE_UNITS NUMBER(10,0),
    CREATED_DATE TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================
-- 2h: ATLAS_CHANNEL_CATEGORY - 1P vs 3P by category
-- ============================================================

CREATE OR REPLACE TABLE WYZE_COMP_ANALYSIS.RAW.ATLAS_CHANNEL_CATEGORY (
    CHANNEL_ID VARCHAR(20) NOT NULL PRIMARY KEY,
    BRAND_ID NUMBER(10,0),
    WEEK_ID NUMBER(6,0),
    SUBCATEGORY_ID NUMBER(10,0),
    RETAIL_SALES NUMBER(14,2),
    UNITS_SOLD NUMBER(10,0),
    RETAIL_PRICE NUMBER(10,2),
    ONEP_SALES NUMBER(14,2),
    THREEP_SALES NUMBER(14,2),
    ONEP_UNITS_SOLD NUMBER(10,0),
    THREEP_UNITS_SOLD NUMBER(10,0),
    CREATED_DATE TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================
-- 2i: ATLAS_CHANNEL_SEGMENT - 1P vs 3P by segment
-- ============================================================

CREATE OR REPLACE TABLE WYZE_COMP_ANALYSIS.RAW.ATLAS_CHANNEL_SEGMENT (
    CHANNEL_SEG_ID VARCHAR(20) NOT NULL PRIMARY KEY,
    BRAND_ID NUMBER(10,0),
    WEEK_ID NUMBER(6,0),
    SEGMENT_ID NUMBER(10,0),
    RETAIL_SALES NUMBER(14,2),
    UNITS_SOLD NUMBER(10,0),
    ONEP_SALES NUMBER(14,2),
    THREEP_SALES NUMBER(14,2),
    ONEP_UNITS_SOLD NUMBER(10,0),
    THREEP_UNITS_SOLD NUMBER(10,0),
    CREATED_DATE TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================
-- Verify tables created
-- ============================================================

SHOW TABLES IN SCHEMA WYZE_COMP_ANALYSIS.RAW;
