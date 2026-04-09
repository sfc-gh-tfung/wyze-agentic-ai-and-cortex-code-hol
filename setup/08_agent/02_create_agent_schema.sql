-- ============================================================
-- Step 8b: Create Snowflake Intelligence Database
-- ============================================================
-- The SNOWFLAKE_INTELLIGENCE database is NOT automatically created.
-- You must create it before creating any agents.
-- Reference: https://community.snowflake.com/s/article/Snowflake-Intelligence-Setup-Resolving-Database-Does-Not-Exist-Error

USE ROLE ACCOUNTADMIN;

CREATE DATABASE IF NOT EXISTS SNOWFLAKE_INTELLIGENCE;
CREATE SCHEMA IF NOT EXISTS SNOWFLAKE_INTELLIGENCE.AGENTS;

SHOW SCHEMAS IN DATABASE SNOWFLAKE_INTELLIGENCE;
