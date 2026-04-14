# Facilitator Walkthrough Script

Bulletpointed guide for walking ~20 Wyze employees through the Competitive Analysis Agent HOL.

---

## Before the Session (~10 min early)

- Confirm projector/screen is working and you're logged into Snowsight on the big screen
- Verify pre-work: `CORTEX_ENABLED_CROSS_REGION = 'ANY_REGION'` is set, Web Search is toggled ON
- Have the GitHub repo open: `https://github.com/sfc-gh-tfung/wyze-agentic-ai-and-cortex-code-hol`
- Have a backup copy of the `unstructured_data/product_reviews/` folder ready on a USB or shared drive (for anyone who doesn't have Python)
- Open the README on screen for reference

---

## Welcome & Intro (~5 min)

- Welcome everyone, thank them for joining
- **What we're building today**: A Cortex Agent in Snowflake Intelligence that can answer competitive analysis questions about the Amazon Security & Surveillance marketplace using three tools:
  - **Cortex Analyst** — converts natural language to SQL against structured sales, traffic, and promotion data
  - **Cortex Search** — searches 110 product review summaries (unstructured text)
  - **Web Search** — pulls live market intelligence from the internet
- **What you'll learn**:
  - How to set up a database with synthetic marketplace data (pure SQL — no external tools)
  - How to use Snowflake's AI SQL functions (AI_SENTIMENT, CORTEX.COMPLETE) to extract insights from unstructured data
  - How to create a Semantic View so an AI agent can query your tables with natural language
  - How to create and use a Cortex Agent in Snowflake Intelligence
  - How to extend the solution with Cortex Code (CLI and Snowsight)
- **Time estimate**: ~45-60 min for Part 1 (the core build), then open-ended exploration in Part 2
- Ask everyone to clone the repo or download the ZIP now

---

## Step 1: Database Setup (~3 min)

- Open `hol_scripts/01_database/01_create_database.sql`
- Walk through what the script does:
  - Creates `WYZE_COMP_ANALYSIS` database
  - Creates `RAW` schema (for source data) and `FINAL` schema (for enriched/analytical tables)
  - Creates `WYZE_COMP_WH` warehouse (XSMALL — keeps costs low)
- Everyone: run the script
- **Verify**: `SHOW SCHEMAS IN DATABASE WYZE_COMP_ANALYSIS;`
  - Should see 4 schemas: FINAL, INFORMATION_SCHEMA, PUBLIC, RAW
- Pause — make sure everyone has 4 schemas before moving on

---

## Step 2: Create Raw Tables (~3 min)

- Open `hol_scripts/02_raw_tables/01_create_tables.sql`
- Briefly explain the 9 tables:
  - **BRANDS** — 26 brands in Security & Surveillance (Wyze + 25 competitors)
  - **PRODUCTS** — 258 SKUs with pricing, ratings, content scores
  - **ATLAS_SALES** — weekly retail sales data
  - **ATLAS_TRAFFIC** — Amazon search term impressions and clicks
  - **ATLAS_PROMOTIONS** — coupon/deal events with sales lift
  - **ATLAS_CHANNEL_CATEGORY / ATLAS_CHANNEL_SEGMENT** — 1P vs 3P sales split
  - **SUBCATEGORIES / SEGMENTS** — reference tables
- Everyone: run the script
- **Verify**: `SHOW TABLES IN SCHEMA WYZE_COMP_ANALYSIS.RAW;`
  - Should see 9 tables, all with 0 rows (data comes next)

---

## Step 3: Generate Data (~5 min)

- This is the longest step — 7 scripts that must run in order
- Open `hol_scripts/03_data_generation/` and walk through:
  - `01_insert_brands.sql` — 26 brands
  - `02_insert_subcategories_segments.sql` — 12 subcategories, 15 segments
  - `03_insert_products.sql` — 258 products (the biggest insert)
  - `04_insert_sales.sql` — ~2,770 weekly sales records across 66 weeks
  - `05_insert_traffic.sql` — ~4,650 search traffic records
  - `06_insert_promotions.sql` — ~1,500 promotion events
  - `07_insert_channel_data.sql` — ~1,140 channel records
- **Key point**: All data is generated with pure SQL — no external APIs or files needed
- Everyone: run all 7 scripts in order
- **Verify**: Run the UNION ALL count query from the README
  - BRANDS: 26, PRODUCTS: 258, ATLAS_SALES: 2773, ATLAS_TRAFFIC: 4659, ATLAS_PROMOTIONS: 1536
- Give people a minute to catch up — this is the most scripts they'll run at once

---

## Step 4: Product Reviews — Unstructured Data (~8 min)

- Explain: "Now we're adding unstructured data — 110 product review text files that we'll make searchable with Cortex Search"

### 4a: Generate Review Files (~2 min)
- If participants have Python: `cd unstructured_data_generation_script/ && python generate_product_reviews.py`
- If not: distribute the pre-generated `unstructured_data/product_reviews/` folder
- Should produce ~110 `.txt` files

### 4b: Create Stage (~1 min)
- Open `hol_scripts/04_product_reviews/01_create_stage.sql`
- Explain: "A stage is like a folder in Snowflake where we store files"
- Everyone: run the script

### 4c: Upload Files via Snowsight (~3 min)
- **Show on screen**: Navigate to **Catalog → Database Explorer → WYZE_COMP_ANALYSIS → RAW → Stages**
- Click **PRODUCT_REVIEWS_STAGE** → **+ Files** → select all `.txt` files → **Upload**
- Walk through this slowly — file uploads can be tricky
- After upload, run:
  ```sql
  ALTER STAGE WYZE_COMP_ANALYSIS.RAW.PRODUCT_REVIEWS_STAGE REFRESH;
  SELECT COUNT(*) FROM DIRECTORY(@WYZE_COMP_ANALYSIS.RAW.PRODUCT_REVIEWS_STAGE);
  ```
- Should see 110

### 4d: Source Table & Search Service (~2 min)
- Open `hol_scripts/04_product_reviews/02_create_source_table.sql` and `03_create_search_service.sql`
- Explain: "The source table reads the text files from the stage. The Cortex Search service indexes them so the agent can search review content."
- Everyone: run both scripts
- **Verify**: `SHOW CORTEX SEARCH SERVICES IN SCHEMA WYZE_COMP_ANALYSIS.FINAL;`
  - Should show PRODUCT_REVIEW_SEARCH, status ACTIVE, 110 rows

---

## Step 5: Dynamic Tables (~3 min)

- Open `hol_scripts/05_final_schema/`
- Explain: "Dynamic tables are like materialized views that auto-refresh. We're creating two that join and enrich the raw data."
  - **SALES_ENRICHED** — joins sales with products and brands, adds ASP and content quality tiers
  - **PROMO_ENRICHED** — joins promotions with products, adds sales lift and ASP compression
- Everyone: run both scripts
- **Verify**: Run the count query
  - SALES_ENRICHED: 2773, PROMO_ENRICHED: 1536
- If counts are 0: `ALTER DYNAMIC TABLE WYZE_COMP_ANALYSIS.FINAL.SALES_ENRICHED REFRESH;`

---

## Step 6: AI SQL Analysis (~5 min)

- This is a great demo moment — show the power of Snowflake AI SQL functions
- Open `hol_scripts/06_ai_analysis/01_create_review_sentiment.sql`
- Walk through the key SQL patterns:
  - `AI_SENTIMENT(CONTENT)` — classifies each review as positive/negative/mixed and gives a score
  - `SNOWFLAKE.CORTEX.COMPLETE('mistral-large2', prompt)` — LLM extracts themes (top praise, complaint, competitor mentions)
- **Heads up**: "This step takes 2-3 minutes because the LLM processes 110 reviews. Be patient."
- Everyone: run the script
- **Verify**: Run the count query
  - REVIEW_SENTIMENT: 110, REVIEW_THEMES: 110, BRAND_REVIEW_SENTIMENT: 15, SEGMENT_REVIEW_SENTIMENT: 56

---

## Step 7: Semantic View (~3 min)

- Open `hol_scripts/07_semantic_view/01_create_semantic_view.sql`
- Explain: "A Semantic View tells Cortex Analyst how your tables relate to each other and what the columns mean. It's like giving the AI a data dictionary so it can write accurate SQL from natural language questions."
- Covers 10 tables — all the RAW and FINAL tables we've built
- Everyone: run the script
- **Verify**: `SHOW SEMANTIC VIEWS IN SCHEMA WYZE_COMP_ANALYSIS.FINAL;`
  - Should see COMP_ANALYSIS_SEMANTIC_VIEW

---

## Step 8: Cortex Agent (~5 min)

### 8a: Enable Web Search (~1 min)
- Show on screen: **AI & ML → Agents → Settings** (gear icon) → Toggle **Web search** ON
- This is an account-level one-time setting

### 8b: Create Intelligence Database (~1 min)
- Open `hol_scripts/08_agent/02_create_agent_schema.sql`
- Explain: "The SNOWFLAKE_INTELLIGENCE database isn't created automatically — we need to create it to store our agent."
- Everyone: run the script

### 8c: Create the Agent (~3 min)
- Open `hol_scripts/08_agent/03_create_agent.sql`
- Walk through the CREATE AGENT statement:
  - **Orchestration model**: `claude-4-sonnet` — the LLM that decides which tool to use
  - **3 tools**:
    - `cortex_analyst_text_to_sql` → queries the Semantic View
    - `cortex_search` → searches product reviews
    - `web_search` → searches the internet
  - **tool_resources**: connects each tool to the right data source
- Everyone: run the script
- **Verify**: `SHOW AGENTS IN SCHEMA SNOWFLAKE_INTELLIGENCE.AGENTS;`
  - Should see COMP_ANALYSIS_AGENT

---

## Step 9: Permissions (~1 min)

- Open `hol_scripts/09_grants/01_grant_permissions.sql`
- Explain: "We're granting everything to PUBLIC for simplicity in this lab. In production, you'd use more granular roles."
- Everyone: run the script

---

## Step 10: Use the Agent — The Payoff! (~10 min)

- This is the fun part — show on screen first, then let everyone try
- Navigate to **AI & ML → Snowflake Intelligence**
- Click **Competitive Analysis Assistant**
- Demo these questions live, one from each tool:

### Analyst (structured data):
```
Which brands had the highest total retail sales last month?
```
- Point out: "The agent wrote SQL and queried your actual data — no hallucination."

### Review Search (unstructured data):
```
What are customers saying about Wyze camera video quality?
```
- Point out: "It searched the 110 review files we uploaded and found relevant passages."

### Web Search (live intelligence):
```
What recent news is there about Ring's product launches?
```
- Point out: "It searched the internet in real time."

### Multi-tool question:
```
How does Wyze compare to Ring in terms of sales, customer reviews, and recent news?
```
- Point out: "The agent decided on its own to use all three tools to answer one question."

- Let everyone experiment for 5-10 minutes — refer to the Sample Questions section in the README

---

## Part 2: Choose Your Own Adventure (~remaining time)

- Introduce Cortex Code — two ways to use it:
  - **Cortex Code in Snowsight**: Click the icon in the bottom-right corner. Best for SQL, data exploration.
  - **Cortex Code CLI**: Run `cortex` in your terminal. Best for building apps and pipelines.
- Walk through the adventures in the README:
  - **CLI adventures** (A-D): Streamlit dashboard, content audit, promo optimizer, automated alerts
  - **Snowsight adventures** (E-H): Search term intelligence, executive briefing, market share, content vs. performance
- Let people pick what interests them
- Float around and help as needed
- Encourage people to try the prompts in the README, but also to ask their own questions

---

## Wrap-Up (~5 min)

- Ask for a few people to share what they built or discovered
- Key takeaways:
  - Snowflake Intelligence lets you build AI agents that combine structured data, unstructured data, and live web search
  - Cortex AI SQL functions (AI_SENTIMENT, CORTEX.COMPLETE) can extract structured insights from unstructured text at scale
  - Semantic Views give AI a business-level understanding of your data
  - Cortex Code accelerates development — both in Snowsight and via CLI
- Resources:
  - The README has all the reference docs linked at the bottom
  - The repo stays available for them to revisit
- Thank everyone for their time

---

## Timing Summary

| Section | Duration |
|---------|----------|
| Welcome & Intro | 5 min |
| Steps 1-3 (Database, Tables, Data) | 11 min |
| Step 4 (Product Reviews) | 8 min |
| Steps 5-6 (Dynamic Tables, AI Analysis) | 8 min |
| Steps 7-9 (Semantic View, Agent, Grants) | 9 min |
| Step 10 (Use the Agent) | 10 min |
| Part 2 (Adventures) | remaining |
| Wrap-Up | 5 min |
| **Total Part 1** | **~51 min** |

---

## Common Issues to Watch For

- **"Database does not exist"** when creating agent → They forgot Step 8b (CREATE DATABASE SNOWFLAKE_INTELLIGENCE)
- **File upload issues** → Make sure they're in the right stage, using `.txt` files, and ran `ALTER STAGE ... REFRESH` after
- **Dynamic table counts = 0** → Run `ALTER DYNAMIC TABLE ... REFRESH;` — they just need a moment to initialize
- **AI analysis is slow** → Normal — CORTEX.COMPLETE processing 110 reviews takes 2-3 min
- **Agent not visible** → Check Step 9 grants were applied, and they're looking in **AI & ML → Snowflake Intelligence**
- **Cortex Search not ACTIVE** → The search service can take a minute to index. Have them wait and re-check.
