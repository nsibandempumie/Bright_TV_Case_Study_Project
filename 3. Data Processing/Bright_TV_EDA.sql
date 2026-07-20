----------------------------------------------------------------------------------------
        -- Retrieving the whole table before analysis to understand the dataset
----------------------------------------------------------------------------------------
SELECT *
FROM workspace.default.bright_tv_dataset_user_profiles
LIMIT 100;

----------------------------------------------------------------------------------------
        -- Data analysis (The size of the data)
----------------------------------------------------------------------------------------
SELECT COUNT(*) AS number_of_rows,                              --This data contains 5375 rows
       COUNT(DISTINCT UserID) AS number_subs                    -- Checking for duplicates (This data has no duplicates)
FROM workspace.default.bright_tv_dataset_user_profiles;

--- Another way to check duplicates on the data
SELECT userID, COUNT(*) AS duplicate_count
FROM workspace.default.bright_tv_dataset_user_profiles
GROUP BY UserID
HAVING COUNT(*) > 1;                                -- Returned no duplicates

----------------------------------------------------------------------------------------
        -- Checking for rows where userID is NULL 
----------------------------------------------------------------------------------------
SELECT COUNT(*) AS cnt
FROM workspace.default.bright_tv_dataset_user_profiles
WHERE UserID is NULL;                               -- The data does not have NULL values

----------------------------------------------------------------------------------------
        -- Checking Gender
----------------------------------------------------------------------------------------
SELECT DISTINCT gender
FROM workspace.default.bright_tv_dataset_user_profiles;     -- Returned 4 genders (female, male, none & an empty space)

SELECT COUNT(*)
FROM workspace.default.bright_tv_dataset_user_profiles;

-- Counting None values
SELECT COUNT(*) AS none_values
FROM workspace.default.bright_tv_dataset_user_profiles
WHERE gender ILIKE 'none';                 -- There are 702 none values on the gender column

-- Counting empty spaces on the gender column
SELECT COUNT(*) AS empty_values
FROM workspace.default.bright_tv_dataset_user_profiles
WHERE TRIM(gender) = '';                      -- There are 218 empty values on the gender column

--- Grouping genders and renaming missing values
SELECT
    COUNT(DISTINCT UserID) AS subs,
    CASE
        WHEN TRIM(gender) = '' THEN 'Unknown'
        WHEN gender ILIKE 'none' THEN 'Unknown'
        ELSE gender
    END AS Gender
FROM workspace.default.bright_tv_dataset_user_profiles
GROUP BY
    CASE
        WHEN TRIM(gender) = '' THEN 'Unknown'
        WHEN gender ILIKE 'none' THEN 'Unknown'
        ELSE gender
    END;              

SELECT COUNT(*)
FROM workspace.default.bright_tv_dataset_user_profiles
   WHERE Gender is NULL;  --No null values on the gender column

----------------------------------------------------------------------------------------
    -- Checking Race
----------------------------------------------------------------------------------------    
SELECT DISTINCT Race
FROM workspace.default.bright_tv_dataset_user_profiles;

SELECT DISTINCT COUNT(*) AS num_rows
FROM workspace.default.bright_tv_dataset_user_profiles
WHERE Race is NULL;                    -- No NULL values on the Race column

    --- Combining the other, none and empty space into one row
    SELECT DISTINCT
        CASE    
             WHEN Race ILIKE 'other' THEN 'None'
             WHEN Race = ' ' THEN 'None'
        ELSE Race
      END AS Ethnicity
  FROM workspace.default.bright_tv_dataset_user_profiles;

----------------------------------------------------------------------------------------
        -- Province Checks
----------------------------------------------------------------------------------------
 -- Different values on Province column
SELECT DISTINCT Province
FROM workspace.default.bright_tv_dataset_user_profiles; --- 11 Rows (Two more Provinces as none & empty space)


------
SELECT DISTINCT 
        CASE
           WHEN Province  = ' ' THEN 'Uncategorised'
           WHEN Province = 'None' THEN 'Uncategorised'
           ELSE Province
           END AS Region
FROM workspace.default.bright_tv_dataset_user_profiles; 
-- Combing the extra rows with one row where value = uncategorised

------------------------------------------------------------------------------------------------

        -- Checking Age
-----------------------------------------------------------------------------------------------

SELECT  MIN(Age) AS min_age,    -- Youngest viewers = 0 years old
        MAX(Age) AS max_age     -- Oldest viewers = 114 years old
FROM workspace.default.bright_tv_dataset_user_profiles;


SELECT COUNT(*) AS cnt
FROM workspace.default.bright_tv_dataset_user_profiles
WHERE age IS NULL;


SELECT COUNT(DISTINCT userID) AS subs,
     CASE
        WHEN age = 0 THEN 'infant'
        WHEN age BETWEEN 1 AND 12 THEN 'kid'
        WHEN age BETWEEN 13 AND 19 THEN 'Teenager'
        WHEN age BETWEEN 20 AND 35 THEN 'Youth'
        WHEN age BETWEEN 36 AND 50 THEN 'Adult'
        WHEN age BETWEEN 51 AND 65 THEN 'Elder'
        WHEN age > 65 THEN 'Pensioner'
END AS age_groups
FROM workspace.default.bright_tv_dataset_user_profiles
GROUP BY age_groups;


----------------------------------------------------------------
        --Joining my tables using cte (To be studied further)
--------------------------------------------------------------

WITH user_profiles AS (                                                 --- Creating temporary table called user_profiles
SELECT userID,
     CASE
        WHEN Province IS NULL OR TRIM(Province) = '' OR LOWER(TRIM(Province)) = 'none' THEN 'Uncategorised'
        ELSE TRIM(Province)
     END AS Region,
     age,
     CASE
        WHEN age = 0 THEN 'infant'
        WHEN age BETWEEN 1 AND 12 THEN 'kid'
        WHEN age BETWEEN 13 AND 19 THEN 'Teenager'
        WHEN age BETWEEN 20 AND 35 THEN 'Youth'
        WHEN age BETWEEN 36 AND 50 THEN 'Adult'
        WHEN age BETWEEN 51 AND 65 THEN 'Elder'
        WHEN age > 65 THEN 'Pensioner'
     END AS age_groups,

      CASE
        WHEN age = 0 THEN 1
        WHEN age BETWEEN 1 AND 12 THEN 2
        WHEN age BETWEEN 13 AND 19 THEN 3
        WHEN age BETWEEN 20 AND 35 THEN 4
        WHEN age BETWEEN 36 AND 50 THEN 5
        WHEN age BETWEEN 51 AND 65 THEN 6
        WHEN age > 65 THEN 7
     END AS age_groups_order,

     CASE
        WHEN email IS NULL OR TRIM(email)=''OR LOWER(email)='none' THEN 'No'
        ELSE 'Yes'
     END AS email_flag,

     CASE
        WHEN `Social Media Handle` IS NULL OR TRIM(`Social Media Handle`)=''OR LOWER(`Social Media Handle`)='none'THEN 'No'
        ELSE 'Yes'
     END AS sm_flag,
        
     CASE    
        WHEN Race ILIKE 'other' THEN 'None'
        WHEN Race = ' ' THEN 'None'
        ELSE Race
     END AS Race,

     CASE
        WHEN Gender IS NULL THEN 'Unknown'
        WHEN TRIM(Gender)='' THEN 'Unknown'
        ELSE Gender
     END AS Gender
FROM workspace.default.bright_tv_dataset_user_profiles
),
--Creating temporary viewership table
viewership AS(                                                                  
SELECT COALESCE(UserID0,userid4,0) AS userid,
---Date
-- DAYOFWEEK(`RecordDate2`) AS day_number,
--- DAYNAME(`RecordDate2`) AS day_name,

date_format(RecordDate2, 'EEEE') AS day_name,
     CASE
        WHEN date_format(RecordDate2, 'EEEE') = 'Monday' THEN 1
        WHEN date_format(RecordDate2, 'EEEE') = 'Tuesday' THEN 2
        WHEN date_format(RecordDate2, 'EEEE') = 'Wednesday' THEN 3
        WHEN date_format(RecordDate2, 'EEEE') = 'Thursday' THEN 4
        WHEN date_format(RecordDate2, 'EEEE') = 'Friday' THEN 5
        WHEN date_format(RecordDate2, 'EEEE') = 'Saturday' THEN 6
        WHEN date_format(RecordDate2, 'EEEE') = 'Sunday' THEN 7
     END AS day_number,
       TO_DATE(RecordDate2) AS watch_date,                                      
       MONTH(`RecordDate2`) AS month_number,
       MONTHNAME(`RecordDate2`) AS month_name,
     CASE
        WHEN DAY(RecordDate2) BETWEEN 1 AND 7 THEN 'Week 1'
        WHEN DAY(RecordDate2) BETWEEN 8 AND 14 THEN 'Week 2'
        WHEN DAY(RecordDate2) BETWEEN 15 AND 21 THEN 'Week 3'
        WHEN DAY(RecordDate2) BETWEEN 22 AND 28 THEN 'Week 4'
        ELSE 'Week 5'
     END AS Week_of_Month,

     CASE
        WHEN DAY(RecordDate2) BETWEEN 1 AND 7 THEN 1
        WHEN DAY(RecordDate2) BETWEEN 8 AND 14 THEN 2
        WHEN DAY(RecordDate2) BETWEEN 15 AND 21 THEN 3
        WHEN DAY(RecordDate2) BETWEEN 22 AND 28 THEN 4
        ELSE 5
     END AS Week_order,

     CASE
        WHEN day_name IN ('Saturday', 'Sunday') THEN 'weekend'
        ELSE 'weekday'
        END AS day_classification,
 ---Time
 ---TIME(RecordDate2) AS watch_time,
 ---TO_CHAR(RecordDate2, 'DD') AS day_of_week,
    HOUR(RecordDate2) AS hour_of_day,
    HOUR(RecordDate2) AS Hour,
    
    CASE
       WHEN HOUR(RecordDate2) BETWEEN 0 AND 5 THEN 'Early Morning'
       WHEN HOUR(RecordDate2) BETWEEN 6 AND 11 THEN 'Morning'
       WHEN HOUR(RecordDate2) BETWEEN 12 AND 16 THEN 'Afternoon'
       ELSE 'Evening'
    END AS time_of_day,

    CASE
       WHEN HOUR(RecordDate2) BETWEEN 0 AND 5 THEN 1
       WHEN HOUR(RecordDate2) BETWEEN 6 AND 11 THEN 2
       WHEN HOUR(RecordDate2) BETWEEN 12 AND 16 THEN 3
       ELSE 4
    END AS time_sort,

    DATE_FORMAT(RecordDate2, 'HH:mm:ss') AS watch_time,
    DATE_FORMAT(`Duration 2`, 'HH:mm:ss') AS duration,
      
-- Numeric duration
   (HOUR(`Duration 2`) * 3600 + MINUTE(`Duration 2`) * 60 + SECOND(`Duration 2`)) 
            AS duration_seconds,
    ROUND ((HOUR(`Duration 2`) * 3600 + MINUTE(`Duration 2`) * 60 + SECOND(`Duration 2`))/60,2)
            AS duration_minutes,
    ROUND ((HOUR(`Duration 2`) * 3600 + MINUTE(`Duration 2`) * 60 + SECOND(`Duration 2`))/3600,2) 
            AS duration_hours,

    CASE
       WHEN watch_time BETWEEN "00:05:00" AND '00:3:00' THEN '01. Low Usage'
       WHEN watch_time BETWEEN "00:30:01" AND '00:59:59' THEN '02. Med Usage'
       WHEN watch_time >"00:59:59" THEN '03. High Usage'
       ELSE '04. No usage'
    END AS screen_time_bucket,

    CASE 
       WHEN Channel2 IN('SawSee', 'Sawsee') THEN 'SawSee'
       WHEN Channel2 IN('Supersport Live Events', 'Live on SuperSport', 'SuperSport Live Events', 'DStv Events 1') THEN 'Live Events'
       ELSE Channel2
    END AS TV_Channel
FROM workspace.default.bright_tv_dataset_viewership
)
SELECT  COALESCE(A.userid, B.userid) AS sub_id,
        TV_Channel,
        watch_date,
        month_number,
        month_name,
        Week_of_Month,
        Week_order,
        day_name,
        day_number,
        day_classification,
        watch_time,
        Hour,
        hour_of_day,
        time_sort,
        time_of_day,
        duration,
        duration_Hours,
        duration_minutes,
        duration_seconds,
        Region,
        age_groups,
        age_groups_order,
        screen_time_bucket,
        email_flag,
        sm_flag,
        Race,
        Gender
FROM viewership AS A
LEFT JOIN user_profiles AS B
ON A.userid = B.userid
GROUP BY ALL;


