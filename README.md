# Wyze Competitive Analysis - Hands-On Lab

This guide covers the full setup of the Wyze Competitive Analysis demo environment for Snowflake Intelligence, including structured marketplace data, product review analysis with AI SQL functions, and a Cortex Agent with semantic search and web search.

---

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Part 1: Core Setup (Steps 1-9)](#part-1-core-setup-steps-1-9)
4. [Part 2: Choose Your Own Adventure](#part-2-choose-your-own-adventure)
5. [Sample Questions](#sample-questions)
6. [Data Summary](#data-summary)
7. [Troubleshooting](#troubleshooting)
8. [Teardown / Cleanup](#teardown--cleanup)

---

## Overview

### What You'll Build

- **258 product SKUs** across 26 Security & Surveillance brands (including Wyze) with pricing, ratings, and content scores
- **~2,770 weekly sales records** covering 66 weeks (2025W01-2026W14)
- **~4,650 search traffic records** across 74 Amazon search terms (including 9 Wyze-branded terms)
- **~1,500 promotion events** with lift analysis
- **~1,140 channel records** for 1P vs 3P sales split
- **110 product review summaries** searchable via Cortex Search
- **AI-powered sentiment analysis** using AI_SENTIMENT and CORTEX.COMPLETE
- **Semantic View** with 10 tables for natural language SQL queries
- **Cortex Agent** in Snowflake Intelligence with 3 tools (Analyst, ReviewSearch, WebSearch)

### Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        Snowflake Intelligence                           │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │              Competitive Analysis Assistant                      │   │
│  │  ┌──────────────┐  ┌──────────────┐  ┌────────────────────────┐│   │
│  │  │Cortex Analyst│  │Cortex Search │  │     Web Search         ││   │
│  │  │(Semantic View)│  │  (Reviews)   │  │(Market Intelligence)  ││   │
│  │  └──────────────┘  └──────────────┘  └────────────────────────┘│   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                │                                        │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                  WYZE_COMP_ANALYSIS Database                     │   │
│  │  ┌────────────────────┐  ┌──────────────────────────────────┐  │   │
│  │  │ RAW Schema          │  │ FINAL Schema                     │  │   │
│  │  │ - BRANDS (26)       │  │ - SALES_ENRICHED (DT)           │  │   │
│  │  │ - PRODUCTS (258)    │  │ - PROMO_ENRICHED (DT)           │  │   │
│  │  │ - ATLAS_SALES       │  │ - BRAND_REVIEW_SENTIMENT        │  │   │
│  │  │ - ATLAS_TRAFFIC     │  │ - SEGMENT_REVIEW_SENTIMENT      │  │   │
│  │  │ - ATLAS_PROMOTIONS  │  │ - PRODUCT_REVIEW_SEARCH (CSS)   │  │   │
│  │  │ - ATLAS_CHANNEL_*   │  │ - COMP_ANALYSIS_SEMANTIC_VIEW   │  │   │
│  │  │ - REVIEW_SENTIMENT  │  └──────────────────────────────────┘  │   │
│  │  │ - REVIEW_THEMES     │                                        │   │
│  │  └────────────────────┘                                         │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  SNOWFLAKE_INTELLIGENCE.AGENTS.COMP_ANALYSIS_AGENT              │   │
│  └─────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Prerequisites

- Snowflake account with Cortex features enabled
- ACCOUNTADMIN role (used for all setup steps; no other roles needed)
- Python 3.x (for Step 4 review file generation only; facilitator can provide pre-generated files)
- ~45-60 minutes for Part 1

### One-Time Account Setup

```sql
USE ROLE ACCOUNTADMIN;
ALTER ACCOUNT SET CORTEX_ENABLED_CROSS_REGION = 'ANY_REGION';


```

Then enable Web Search via UI: **AI & ML → Agents → Settings (gear icon) → Toggle Web search ON**

---

## Part 1: Core Setup (Steps 1-9)

### Folder Structure

```
setup/
├── 01_database/              # Create database, schemas, warehouse
├── 02_raw_tables/            # Create 9 source tables
├── 03_data_generation/       # Generate all synthetic data (pure SQL)
├── 04_product_reviews/       # Stage, source table, Cortex Search
├── 05_final_schema/          # Dynamic tables (denormalized views)
├── 06_ai_analysis/           # AI SQL: sentiment + theme extraction
├── 07_semantic_view/         # Semantic view (10 tables incl. sentiment)
├── 08_agent/                 # Cortex Agent with 3 tools
├── 09_grants/                # Grant permissions to PUBLIC
├── 99_teardown/              # Cleanup script
```

---

### Step 1: Database Setup

📁 **File**: `setup/01_database/01_create_database.sql`

Creates the WYZE_COMP_ANALYSIS database with RAW and FINAL schemas, plus the WYZE_COMP_WH warehouse.

**Verify:** `SHOW SCHEMAS IN DATABASE WYZE_COMP_ANALYSIS;`

---

### Step 2: Create Raw Tables

📁 **File**: `setup/02_raw_tables/01_create_tables.sql`

Creates 9 source tables:
- `BRANDS`, `SUBCATEGORIES`, `SEGMENTS`, `PRODUCTS`
- `ATLAS_SALES`, `ATLAS_TRAFFIC`, `ATLAS_PROMOTIONS`
- `ATLAS_CHANNEL_CATEGORY`, `ATLAS_CHANNEL_SEGMENT`

**Verify:** `SHOW TABLES IN SCHEMA WYZE_COMP_ANALYSIS.RAW;`

---

### Step 3: Generate Data

Run these scripts **in order** (later scripts depend on earlier data):

📁 **Files**:
```
setup/03_data_generation/01_insert_brands.sql
setup/03_data_generation/02_insert_subcategories_segments.sql
setup/03_data_generation/03_insert_products.sql
setup/03_data_generation/04_insert_sales.sql
setup/03_data_generation/05_insert_traffic.sql
setup/03_data_generation/06_insert_promotions.sql
setup/03_data_generation/07_insert_channel_data.sql
```

**Verify:**
```sql
SELECT 'BRANDS' AS TBL, COUNT(*) AS CNT FROM WYZE_COMP_ANALYSIS.RAW.BRANDS
UNION ALL SELECT 'PRODUCTS', COUNT(*) FROM WYZE_COMP_ANALYSIS.RAW.PRODUCTS
UNION ALL SELECT 'ATLAS_SALES', COUNT(*) FROM WYZE_COMP_ANALYSIS.RAW.ATLAS_SALES
UNION ALL SELECT 'ATLAS_TRAFFIC', COUNT(*) FROM WYZE_COMP_ANALYSIS.RAW.ATLAS_TRAFFIC
UNION ALL SELECT 'ATLAS_PROMOTIONS', COUNT(*) FROM WYZE_COMP_ANALYSIS.RAW.ATLAS_PROMOTIONS;
```

---

### Step 4: Product Reviews (Unstructured Data)

#### 4a: Generate Review Files

```bash
cd path/to/Wyze_CoCo_HOL/scripts/
python generate_product_reviews.py
```

Creates ~110 `.txt` files in `unstructured_data/product_reviews/`.

> **No Python?** Ask your facilitator for pre-generated files.

#### 4b: Create Stage

📁 **File**: `setup/04_product_reviews/01_create_stage.sql`

#### 4c: Upload Files via Snowsight

1. Navigate to **Data → Databases → WYZE_COMP_ANALYSIS → RAW → Stages**
2. Click **PRODUCT_REVIEWS_STAGE**
3. Click **+ Files** → select all `.txt` files → **Upload**

Then refresh:
```sql
ALTER STAGE WYZE_COMP_ANALYSIS.RAW.PRODUCT_REVIEWS_STAGE REFRESH;
SELECT COUNT(*) FROM DIRECTORY(@WYZE_COMP_ANALYSIS.RAW.PRODUCT_REVIEWS_STAGE);
-- Should return ~110
```

#### 4d: Create Source Table & Search Service

📁 **Files**:
```
setup/04_product_reviews/02_create_source_table.sql
setup/04_product_reviews/03_create_search_service.sql
```

Creates `PRODUCT_REVIEW_SOURCE` table and `PRODUCT_REVIEW_SEARCH` Cortex Search service.

---

### Step 5: Dynamic Tables (FINAL Schema)

📁 **Files**:
```
setup/05_final_schema/01_create_sales_enriched_dt.sql
setup/05_final_schema/02_create_promo_enriched_dt.sql
```

Creates dynamic tables that denormalize RAW data:
- **SALES_ENRICHED** - Sales + products + brands with ASP, content quality tiers
- **PROMO_ENRICHED** - Promotions + products with sales lift, ASP compression

---

### Step 6: AI SQL Analysis on Product Reviews

Uses Snowflake Cortex AI SQL functions to extract structured insights from unstructured review text.

📁 **File**: `setup/06_ai_analysis/01_create_review_sentiment.sql`

> **Note**: AI_SENTIMENT takes ~30 seconds, CORTEX.COMPLETE takes ~2-3 minutes. Be patient.

Creates four tables:

| Table | Schema | Description |
|-------|--------|-------------|
| `REVIEW_SENTIMENT` | RAW | Each review with sentiment (positive/negative/mixed) |
| `REVIEW_THEMES` | RAW | LLM-extracted themes (top praise, complaint, competitor mentions) |
| `BRAND_REVIEW_SENTIMENT` | FINAL | Brand-level aggregated sentiment scores |
| `SEGMENT_REVIEW_SENTIMENT` | FINAL | Brand + segment level sentiment scores |

Key patterns:
```sql
AI_SENTIMENT(CONTENT):categories[0]:sentiment::VARCHAR AS SENTIMENT_CATEGORY

SNOWFLAKE.CORTEX.COMPLETE('mistral-large2', 'prompt: ' || LEFT(CONTENT, 3000)) AS THEME_EXTRACTION
```

---

### Step 7: Semantic View

📁 **File**: `setup/07_semantic_view/01_create_semantic_view.sql`

Creates a Semantic View covering 10 tables (including `BRAND_REVIEW_SENTIMENT` and `SEGMENT_REVIEW_SENTIMENT` from Step 6, plus `SUBCATEGORIES` and `SEGMENTS` reference tables) for Cortex Analyst natural language queries.

**Verify:** `SHOW SEMANTIC VIEWS IN SCHEMA WYZE_COMP_ANALYSIS.FINAL;`

---

### Step 8: Cortex Agent

#### 8a: Enable Web Search (Account Level)

1. Navigate to **AI & ML → Agents → Settings** (gear icon)
2. Toggle **Web search** ON

> One-time account-level setting requiring ACCOUNTADMIN.

📁 **File**: `setup/08_agent/01_enable_web_search.sql`

#### 8b: Create Snowflake Intelligence Database

The `SNOWFLAKE_INTELLIGENCE` database is **not** automatically created. You must create it before creating agents.

📁 **File**: `setup/08_agent/02_create_agent_schema.sql`

```sql
USE ROLE ACCOUNTADMIN;

CREATE DATABASE IF NOT EXISTS SNOWFLAKE_INTELLIGENCE;
CREATE SCHEMA IF NOT EXISTS SNOWFLAKE_INTELLIGENCE.AGENTS;


```

ACCOUNTADMIN already has the necessary privileges to create agents.

> **Reference**: [Snowflake Intelligence Setup: Resolving "Database Does Not Exist" Error](https://community.snowflake.com/s/article/Snowflake-Intelligence-Setup-Resolving-Database-Does-Not-Exist-Error)

#### 8c: Create Agent

📁 **File**: `setup/08_agent/03_create_agent.sql`

```sql
USE ROLE ACCOUNTADMIN;

CREATE OR REPLACE AGENT SNOWFLAKE_INTELLIGENCE.AGENTS.COMP_ANALYSIS_AGENT
COMMENT = 'Amazon marketplace competitive analysis agent'
PROFILE = '{"display_name": "Competitive Analysis Assistant", "color": "green"}'
FROM SPECIFICATION $$
models:
  orchestration: claude-4-sonnet
tools:
  - tool_spec: { type: cortex_analyst_text_to_sql, name: Analyst }
  - tool_spec: { type: cortex_search, name: ReviewSearch }
  - tool_spec: { type: web_search, name: WebSearch }
tool_resources:
  Analyst:
    semantic_view: WYZE_COMP_ANALYSIS.FINAL.COMP_ANALYSIS_SEMANTIC_VIEW
  ReviewSearch:
    name: WYZE_COMP_ANALYSIS.FINAL.PRODUCT_REVIEW_SEARCH
    max_results: "10"
$$;
```

> **Important**: Any role with `CREATE AGENT` on the schema can create agents. ACCOUNTADMIN has this by default.

**Verify in Snowflake Intelligence:**
1. Navigate to **AI & ML → Snowflake Intelligence**
2. The **Competitive Analysis Assistant** should appear in the agent list
3. Click to open and test with: *"Which brands have the best customer sentiment?"*

---

### Step 9: Permissions

📁 **File**: `setup/09_grants/01_grant_permissions.sql`

Grants all objects to PUBLIC for HOL simplicity (database, schemas, tables, dynamic tables, search service, semantic view, warehouse, agent).

---

## Part 2: Choose Your Own Adventure

Extend the solution using **Cortex Code** — Snowflake's AI-powered development environment. You can use it two ways:

| | Cortex Code in Snowsight | Cortex Code CLI |
|---|---|---|
| **Access** | Built into Snowsight UI | Terminal on your laptop |
| **Best for** | SQL authoring, data exploration, account admin, working within Snowsight | Multi-step builds (Streamlit apps, pipelines, dbt projects, notebooks) |
| **How to start** | Click the Cortex Code icon in the bottom-right of Snowsight | Run `cortex` in your terminal |

---

### Setting Up Cortex Code CLI

Cortex Code CLI runs in your terminal and can generate code, create files, and execute multi-step workflows against your Snowflake account.

#### Prerequisites

- [Snowflake CLI](https://docs.snowflake.com/en/developer-guide/snowflake-cli/index) (`snow` command) installed on your machine
- A configured Snowflake connection in `~/.snowflake/connections.toml`
- macOS (Apple Silicon or Intel), Linux, or Windows (WSL or native)

#### Install

**macOS / Linux / WSL:**
```bash
curl -LsS https://ai.snowflake.com/static/cc-scripts/install.sh | sh
```

**Windows (PowerShell):**
```powershell
irm https://ai.snowflake.com/static/cc-scripts/install.ps1 | iex
```

#### Connect & Start

```bash
cortex
```

A setup wizard will guide you to select or create a Snowflake connection. Once connected, type natural language requests to build against your account.

> **Docs**: https://docs.snowflake.com/en/user-guide/cortex-code/cortex-code-cli

---

### Setting Up Cortex Code in Snowsight

Cortex Code is built into the Snowsight UI — no installation needed.

1. Sign in to Snowsight
2. Navigate to **Projects → Workspaces** and open a workspace
3. Click the **Cortex Code icon** in the bottom-right corner
4. Type a natural language request in the chat panel

Use `@` to reference catalog objects (tables, schemas, views) inline for added context.

> **Docs**: https://docs.snowflake.com/en/user-guide/cortex-code/cortex-code-snowsight

---

### Adventures for Cortex Code CLI

These adventures involve multi-step builds that create files, apps, and pipelines — ideal for the CLI.

#### Adventure A: Competitive Dashboard in Streamlit

**Goal**: Build an interactive marketplace dashboard.

**Prompt:**
```
Create a Streamlit app in Snowflake that shows a competitive analysis dashboard with:
1. Brand selector dropdown (from WYZE_COMP_ANALYSIS.RAW.BRANDS)
2. Key metrics cards: total sales, units sold, average ASP, number of SKUs
3. Weekly sales trend chart for the selected brand vs top 3 competitors
4. Content quality score comparison (radar chart)
5. Promotion effectiveness summary (avg discount %, avg sales lift by promo type)
Use data from WYZE_COMP_ANALYSIS.FINAL.SALES_ENRICHED and PROMO_ENRICHED.
```

#### Adventure B: Content Quality Audit

**Goal**: Generate AI-powered listing improvement recommendations.

**Prompt:**
```
Create a pipeline that:
1. Identifies products in WYZE_COMP_ANALYSIS.RAW.PRODUCTS with CONTENT_SCORE < 0.70
2. Uses SNOWFLAKE.CORTEX.COMPLETE to generate specific listing improvement recommendations
3. Stores results in WYZE_COMP_ANALYSIS.FINAL.CONTENT_RECOMMENDATIONS
Focus on actionable improvements based on which sub-score is lowest.
```

#### Adventure C: Promotion ROI Optimizer

**Goal**: Build a model to recommend optimal discount strategies.

**Prompt:**
```
Using WYZE_COMP_ANALYSIS.FINAL.PROMO_ENRICHED:
1. Calculate avg sales lift, ASP compression, and ROI by promo type and brand
2. Use Snowflake ML to predict SALES_LIFT_PCT from discount, promo type, brand, price
3. Register in Model Registry
4. Create a stored procedure to recommend optimal discount % for a product
```

#### Adventure D: Automated Competitive Alerts

**Goal**: Weekly notifications when competitors make significant moves.

**Prompt:**
```
Create a Snowflake Task that runs weekly and:
1. Flags brands with >20% WoW sales increase as "surging"
2. Detects new product launches and unusual promotion activity
3. Stores alerts in WYZE_COMP_ANALYSIS.FINAL.COMPETITIVE_ALERTS
```

---

### Adventures for Cortex Code in Snowsight

These adventures use SQL queries, data exploration, and analysis — ideal for the Snowsight UI.

#### Adventure E: Search Term Intelligence

**Goal**: Analyze search term performance and share of voice.

**Prompt:**
```
Using WYZE_COMP_ANALYSIS.RAW.ATLAS_TRAFFIC, write SQL that:
1. Ranks search terms by total organic impressions and clicks
2. Identifies "paid-dependent" terms (>70% paid impressions) vs "organic winners" (>80% organic)
3. Shows share of voice by brand for the top 10 search terms
```

#### Adventure F: Executive Briefing Query Pack

**Goal**: Build a set of executive-ready queries for competitive analysis.

**Prompt:**
```
Write a SQL query pack against WYZE_COMP_ANALYSIS that answers:
1. What is Wyze's market share trend over the last 12 weeks vs Ring, Blink, and Arlo?
2. Which product segments is Wyze gaining or losing share in?
3. How does Wyze's promotion frequency and discount depth compare to competitors?
4. What are the top 5 search terms where Wyze has low organic share but high paid share?
Use WYZE_COMP_ANALYSIS.FINAL.SALES_ENRICHED, PROMO_ENRICHED, and RAW.ATLAS_TRAFFIC.
```

#### Adventure G: Market Share Deep Dive

**Goal**: Analyze market share dynamics with SQL.

**Prompt:**
```
Write SQL queries using WYZE_COMP_ANALYSIS.FINAL.SALES_ENRICHED to calculate:
1. Weekly brand market share (% of total retail sales) for the last 12 weeks
2. 4-week rolling average market share by brand
3. Brands that gained or lost more than 2 percentage points of share
Categorize brands as "Gaining", "Stable", or "Losing".
```

#### Adventure H: Content Score vs Performance Correlation

**Goal**: Investigate whether content quality drives sales.

**Prompt:**
```
Using @WYZE_COMP_ANALYSIS.FINAL.SALES_ENRICHED, write a SQL analysis that:
1. Groups products by CONTENT_QUALITY_TIER and compares avg retail sales, units sold, and ASP
2. Shows the top 10 products with highest sales but content score below 0.70
3. Calculates correlation between content score and average weekly sales per product
```

---

## Sample Questions

### Sales Performance
- Which SKUs had the fastest-growing sales over the past 4 weeks? Which ones are declining?
- What are the total sales and units sold this month, broken down by brand and subcategory?
- How has average selling price (ASP) trended over the past 12 weeks, and which SKUs show the highest price volatility?

### 1P vs. 3P Channel Mix
- What is our current 1P vs 3P sales split, and how has it shifted compared to 4 weeks ago?
- Which categories or segments have an unusually high 3P share — and is there a channel cannibalization risk?

### Traffic & Advertising
- Which search terms are driving the most organic traffic? Which terms are almost entirely paid-dependent?
- For SKUs with the highest ad spend, how does ROAS look (sales generated vs. dollars spent)?
- Which SKUs are seeing declining organic traffic and may need increased paid support?

### Promotion Effectiveness
- On average, how much do coupon promotions lift sales and unit volume?
- Which SKUs see the biggest incremental sales lift during promotions — and which promotions show little to no effect?
- Are promotions compressing ASP, and does pricing recover after the promotion ends?

### Content Quality
- Which SKUs have content scores (title, image, video, A+) below threshold levels that may be hurting conversion?
- Is there a meaningful correlation between higher content scores and better review ratings or sales performance?

### Competitive & Segment View
- Within each segment, which competitor brands are growing faster than us — and is our market share expanding or contracting?
- Which SKUs have high sales volume but low ratings (below 4.0 stars) — representing a customer satisfaction risk?

### Sentiment Analysis (AI SQL)
- Which brands have the best overall customer sentiment?
- How does Wyze's sentiment compare to Ring and Arlo?
- Which product segments have the most negative reviews?

### Product Reviews (Cortex Search)
- What are customers saying about Ring doorbell cameras?
- Are there common complaints about battery life across outdoor cameras?
- What do reviews say about Wyze camera video quality compared to competitors?

### Web Search
- What recent news is there about Ring's product launches?
- What are the latest trends in the home security camera market?
- Are any competitors running major promotions or price cuts right now?

---

## Data Summary

| Component | Count |
|-----------|-------|
| Brands | 26 (including Wyze) |
| Subcategories | 12 |
| Segments | 15 |
| Products (SKUs) | 258 |
| Weekly Sales Records | ~2,770 |
| Search Traffic Records | ~4,650 |
| Promotion Events | ~1,500 |
| Channel Records | ~1,140 |
| Product Reviews | 110 |
| Review Sentiment Records | 110 |
| Brand Sentiment Summaries | 15 |
| Segment Sentiment Summaries | 56 |
| Dynamic Tables | 2 |
| Cortex Search Service | 1 |
| Semantic View | 1 (10 tables) |
| Cortex Agent | 1 (3 tools) |

### Key Business Context

| Term | Definition |
|------|-----------|
| ASP | Average Selling Price (retail_sales / units_sold) |
| WEEK_ID | Format YYYYWW (e.g., 202614 = week 14 of 2026) |
| 1P | First party - sold directly by Amazon |
| 3P | Third party - sold by marketplace sellers |
| Content Score | 0-1 scale measuring listing quality (title, bullet, image, video, A+) |
| Sales Lift | (promo_sales - baseline_sales) / baseline_sales * 100 |
| ASP Compression | Price reduction during promotions vs baseline |
| IS_WYZE_COMPETITOR | FALSE = Wyze (our brand), TRUE = competitor. Use to filter/group for Wyze vs competitor comparisons |

---

## Troubleshooting

### Dynamic tables not refreshing
```sql
ALTER DYNAMIC TABLE WYZE_COMP_ANALYSIS.FINAL.SALES_ENRICHED REFRESH;
ALTER DYNAMIC TABLE WYZE_COMP_ANALYSIS.FINAL.PROMO_ENRICHED REFRESH;
```

### Agent not appearing in Snowflake Intelligence
1. Verify agent was created: `SHOW AGENTS IN SCHEMA SNOWFLAKE_INTELLIGENCE.AGENTS;`
2. Ensure grants are applied: `GRANT USAGE ON AGENT ... TO ROLE PUBLIC;`
3. Check: `SHOW AGENTS IN SCHEMA SNOWFLAKE_INTELLIGENCE.AGENTS;`

### "Database 'SNOWFLAKE_INTELLIGENCE' does not exist" error
The SNOWFLAKE_INTELLIGENCE database must be created manually. Run Step 8b:
```sql
USE ROLE ACCOUNTADMIN;
CREATE DATABASE IF NOT EXISTS SNOWFLAKE_INTELLIGENCE;
CREATE SCHEMA IF NOT EXISTS SNOWFLAKE_INTELLIGENCE.AGENTS;
```

### "Insufficient privileges" when creating agent
Ensure you are using ACCOUNTADMIN, which has all necessary privileges.

### Cortex Search service not working
Cortex Search requires a **regular table** as source, not a directory table or dynamic table:
```sql
SELECT COUNT(*) FROM WYZE_COMP_ANALYSIS.RAW.PRODUCT_REVIEW_SOURCE;
```

### Product review upload issues
- Ensure files are `.txt` format
- Upload via Snowsight UI (Data → Databases → WYZE_COMP_ANALYSIS → RAW → Stages → PRODUCT_REVIEWS_STAGE)
- After upload: `ALTER STAGE WYZE_COMP_ANALYSIS.RAW.PRODUCT_REVIEWS_STAGE REFRESH;`

---

## Teardown / Cleanup

📁 **File**: `setup/99_teardown/01_teardown.sql`

```sql
USE ROLE ACCOUNTADMIN;
DROP AGENT IF EXISTS SNOWFLAKE_INTELLIGENCE.AGENTS.COMP_ANALYSIS_AGENT;
DROP CORTEX SEARCH SERVICE IF EXISTS WYZE_COMP_ANALYSIS.FINAL.PRODUCT_REVIEW_SEARCH;
DROP SEMANTIC VIEW IF EXISTS WYZE_COMP_ANALYSIS.FINAL.COMP_ANALYSIS_SEMANTIC_VIEW;
DROP DATABASE IF EXISTS WYZE_COMP_ANALYSIS;
DROP WAREHOUSE IF EXISTS WYZE_COMP_WH;
```

> **Note**: Do NOT drop the `SNOWFLAKE_INTELLIGENCE` database - it is system-managed and may contain other agents.

---

## Reference Documentation

- [Snowflake Cortex Agents](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-agents)
- [Cortex Search](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-search/cortex-search-overview)
- [Semantic Views](https://docs.snowflake.com/en/user-guide/views-semantic/overview)
- [Cortex Analyst](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-analyst)
- [Dynamic Tables](https://docs.snowflake.com/en/user-guide/dynamic-tables-about)
- [Cortex AI SQL Functions](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-llm-functions-reference)
- [Cortex Code CLI](https://docs.snowflake.com/en/user-guide/cortex-code/cortex-code-cli)
- [Cortex Code in Snowsight](https://docs.snowflake.com/en/user-guide/cortex-code/cortex-code-snowsight)
