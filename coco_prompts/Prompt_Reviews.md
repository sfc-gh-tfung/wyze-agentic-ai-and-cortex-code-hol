SUMMARY
This adventure adds product review analysis to the Competitive Analysis Agent. Customer reviews are stored as text files in a Snowflake DIRECTORY stage and made searchable via Cortex Search.

REQUIREMENTS
1. Run the Python script `unstructured_data_generation_script/generate_product_reviews.py` locally to generate ~150 review summary text files.
2. Upload the generated .txt files to the PRODUCT_REVIEWS_STAGE via Snowsight UI.
3. Create a source table that reads text files from the stage (using FILE_FORMAT with FIELD_DELIMITER=NONE, RECORD_DELIMITER=NONE to read entire file as one value).
4. Parse the filename to extract brand name, product segment, and review date.
5. Create a Cortex Search Service on the review content with brand name, product segment, and date as filterable attributes.

CRITICAL IMPLEMENTATION NOTES:
- Cortex Search requires a regular table, NOT a directory table or dynamic table on a directory table source.
- Use FILE_FORMAT with TYPE='CSV', FIELD_DELIMITER=NONE, RECORD_DELIMITER=NONE to read the entire file content as a single value ($1::VARCHAR).
- The filename parsing uses REGEXP to extract the date portion and SPLIT_PART/REPLACE for the brand/segment.
- Target lag for the search service is '1 day' since reviews don't change frequently.

Sample Questions:
- What are customers saying about Ring doorbell cameras?
- Which brands have the most negative customer feedback?
- Are there common complaints about battery life across outdoor cameras?
- What features do customers praise most in budget indoor cameras?
- How does customer sentiment compare between eufy and Reolink outdoor cameras?
