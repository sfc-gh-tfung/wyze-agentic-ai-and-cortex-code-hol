SUMMARY
You will create an end-to-end demo for Amazon marketplace competitive analysis in the Security & Surveillance category. The goal is to build a "Competitive Analysis Agent" in Snowflake Intelligence that helps Wyze's marketplace team understand competitive dynamics, identify growth opportunities, optimize promotions, and monitor content quality across 25+ brands and 500+ SKUs.

Data is stored in its native formats (structured sales/traffic/promo data + unstructured product reviews) and consumed through a Cortex Agent in Snowflake Intelligence.

For all steps write them into a file structure including DDL, data generation, etc. so that I could reproduce this on my own in a different account. This is designed to be a hands-on lab for ~20 Wyze team members to implement step by step.

REQUIREMENTS
1. Create a WYZE_COMP_ANALYSIS database with RAW and FINAL schemas. Populate reference tables for brands (25 Security & Surveillance brands), subcategories (12), and segments (15). Generate 500 product SKUs across brands/segments using deterministic HASH-based random data.
2. Generate weekly sales data (~5000 rows) covering 66 weeks (2025W01-2026W14) with retail sales, units, ASP, organic/paid split.
3. Generate traffic data (~5000 rows) across 65 search terms with organic/paid impressions, clicks, and ad spend.
4. Generate promotion data (~3000 rows) with COUPON/BEST_DEAL/PRIME_MEMBER/LIGHTNING_DEAL types, discount %, baseline vs promo sales/units.
5. Generate 1P vs 3P channel data by category (~5000 rows) and by segment (~5000 rows).
6. Generate product review text files via Python script. Upload to a DIRECTORY stage and create a Cortex Search service for semantic search.
7. Create Dynamic Tables to enrich sales and promotions with product/brand/category metadata and calculated fields (ASP, content quality tier, sales lift, ASP compression).
8. Create a Semantic View covering all structured tables for Cortex Analyst text-to-SQL queries.
9. Create a Cortex Agent with 3 tools: Analyst (structured data), ReviewSearch (product reviews), WebSearch (public info).
10. Grant all permissions to PUBLIC for HOL simplicity.

Sample Questions For Agents:
- Which SKUs had the fastest-growing sales over the past 4 weeks? Which ones are declining?
- What are the total sales and units sold this month, broken down by brand and subcategory?
- How has average selling price (ASP) trended over the past 12 weeks, and which SKUs show the highest price volatility?
- What is our current 1P vs 3P sales split, and how has it shifted compared to 4 weeks ago?
- Which categories or segments have an unusually high 3P share - and is there a channel cannibalization risk?
- Which search terms are driving the most organic traffic? Which terms are almost entirely paid-dependent?
- For SKUs with the highest ad spend, how does ROAS look (sales generated vs. dollars spent)?
- Which SKUs are seeing declining organic traffic and may need increased paid support?
- On average, how much do coupon promotions lift sales and unit volume?
- Which SKUs see the biggest incremental sales lift during promotions - and which promotions show little to no effect?
- Are promotions compressing ASP, and does pricing recover after the promotion ends?
- Which SKUs have content scores (title, image, video, A+) below threshold levels that may be hurting conversion?
- Is there a meaningful correlation between higher content scores and better review ratings or sales performance?
- Within each segment, which competitor brands are growing faster than us - and is our market share expanding or contracting?
- Which SKUs have high sales volume but low ratings (below 4.0 stars) - representing a customer satisfaction risk?

References:
- Data modeled after Stackline Amazon marketplace intelligence (Security & Surveillance)
- Brands: Ring, Blink, Arlo, Google Nest, eufy, Reolink, TP-Link Tapo, SimpliSafe, Lorex, etc.
