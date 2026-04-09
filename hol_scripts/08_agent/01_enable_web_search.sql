-- ============================================================
-- Step 8a: Enable Web Search (Account Level)
-- ============================================================
-- Web search must be enabled at the account level BEFORE creating
-- an agent that uses the web_search tool.
--
-- This step must be done via Snowsight UI:
-- 1. Sign in to Snowsight
-- 2. Navigate to AI & ML > Agents > Settings (gear icon)
-- 3. Toggle "Web search" to enable
--
-- Note: This is a one-time account-level setting. Once enabled,
-- individual agents can be configured to use web search.
-- ============================================================

USE ROLE ACCOUNTADMIN;
ALTER ACCOUNT SET CORTEX_ENABLED_CROSS_REGION = 'ANY_REGION';
