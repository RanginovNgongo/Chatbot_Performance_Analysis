-- RANGINOV NGONGO
-- Business Intelligence Chatbot Performance Analytics SQL
/* ===============================================================================
1. SCHEMA SETUP 
===============================================================================
*/
USE AI_Chatbot_Data_Analyst_Project;
GO

ALTER TABLE BI_Chatbot_Interactions ADD Interaction_DateTime DATETIME;
ALTER TABLE BI_Chatbot_Interactions ADD Feedback_Category NVARCHAR(50);
ALTER TABLE BI_Chatbot_Interactions ADD Speed_Performance NVARCHAR(50);
GO

/* ===============================================================================
2. DATA CLEANING & NORMALIZATION
===============================================================================
*/

-- Fixes the 'Min:Sec.ms' string and rounds .9 up to the next second
UPDATE BI_Chatbot_Interactions
SET Interaction_DateTime = DATEADD(ms, 0, ROUND(TRY_CONVERT(DATETIME, '2024-01-01 00:' + timestamp, 121), 0));

-- Round confidence to 1 decimal place (e.g., 0.73 -> 0.7)
UPDATE BI_Chatbot_Interactions 
SET bot_response_confidence = ROUND(bot_response_confidence, 1);

-- Set data types for Power BI compatibility
ALTER TABLE BI_Chatbot_Interactions ALTER COLUMN bot_response_confidence DECIMAL(3,1);
ALTER TABLE BI_Chatbot_Interactions ALTER COLUMN user_feedback_rating INT;

-- Handle NULLs / Missing values
UPDATE BI_Chatbot_Interactions SET user_feedback_rating = 0 WHERE user_feedback_rating IS NULL;
UPDATE BI_Chatbot_Interactions SET department = 'Unassigned' WHERE department IS NULL;
UPDATE BI_Chatbot_Interactions SET user_role = 'General User' WHERE user_role IS NULL;
GO

/* ===============================================================================
3. BUSINESS LOGIC (Categorization)
===============================================================================
*/

-- Feedback Buckets
UPDATE BI_Chatbot_Interactions
SET Feedback_Category = CASE 
    WHEN user_feedback_rating >= 4 THEN 'Positive'
    WHEN user_feedback_rating = 3 THEN 'Neutral'
    WHEN user_feedback_rating BETWEEN 1 AND 2 THEN 'Negative'
    ELSE 'No Rating'
END;

-- Speed Performance (300ms/600ms Thresholds)
UPDATE BI_Chatbot_Interactions
SET Speed_Performance = CASE 
    WHEN response_time_ms < 300 THEN 'Instant' 
    WHEN response_time_ms BETWEEN 300 AND 600 THEN 'Fast'
    ELSE 'Slow'
END;
GO

/* ===============================================================================
4. THE CLEAN ANALYTICS VIEW
This is the final layer for the dashboard.
===============================================================================
*/

CREATE VIEW v_Chatbot_Performance_Dashboard AS
SELECT 
    interaction_id,
    
    -- Split Date and Time (Clean HH:MM:SS)
    CAST(Interaction_DateTime AS DATE) AS Interaction_Date,
    CONVERT(VARCHAR(8), Interaction_DateTime, 108) AS [Interaction_Time],
    
    REPLACE(UPPER(LEFT(department,1)) + LOWER(SUBSTRING(department, 2, LEN(department))), 'Hr', 'HR') AS Department,
    REPLACE(UPPER(LEFT(user_role,1)) + LOWER(SUBSTRING(user_role, 2, LEN(user_role))), 'Hr', 'HR') AS User_Role,
    
    user_query,
    query_category,
    metrics_requested,
    analysis_type,
    bot_response_confidence,
    response_time_ms,
    user_feedback_rating,
    estimated_business_impact,
    Feedback_Category,
    Speed_Performance,
    
    -- Success Flag (Using the 0.50 threshold)
    CASE 
        WHEN bot_response_confidence > 0.50 AND user_feedback_rating >= 3 THEN 'High Performance'
        ELSE 'Review Needed'
    END AS AI_Success_Flag
FROM dbo.BI_Chatbot_Interactions;
GO

-- Double check the results
SELECT * FROM v_Chatbot_Performance_Dashboard
ORDER BY Interaction_Date, [Interaction_Time];