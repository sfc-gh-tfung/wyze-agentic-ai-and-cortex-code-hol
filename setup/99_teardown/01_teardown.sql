-- ============================================================
-- TEARDOWN: Remove All HOL Objects
-- ============================================================
-- WARNING: This will permanently delete all data and objects!

USE ROLE ACCOUNTADMIN;

DROP AGENT IF EXISTS SNOWFLAKE_INTELLIGENCE.AGENTS.COMP_ANALYSIS_AGENT;
DROP CORTEX SEARCH SERVICE IF EXISTS WYZE_COMP_ANALYSIS.FINAL.PRODUCT_REVIEW_SEARCH;
DROP SEMANTIC VIEW IF EXISTS WYZE_COMP_ANALYSIS.FINAL.COMP_ANALYSIS_SEMANTIC_VIEW;
DROP DATABASE IF EXISTS WYZE_COMP_ANALYSIS;
DROP WAREHOUSE IF EXISTS WYZE_COMP_WH;

-- NOTE: Do NOT drop the SNOWFLAKE_INTELLIGENCE database.
-- It is system-managed and may contain other agents.

-- ============================================================
-- VERIFICATION
-- ============================================================

SHOW DATABASES LIKE 'WYZE_COMP_ANALYSIS';
SHOW WAREHOUSES LIKE 'WYZE_COMP_WH';
SHOW AGENTS IN SCHEMA SNOWFLAKE_INTELLIGENCE.AGENTS;
