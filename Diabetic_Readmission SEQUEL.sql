DROP  DATABASE readmission_hba1c;
CREATE DATABASE readmission_hba1c;

CREATE TABLE DIABETIC_READMISSION_RATE (
	ENCOUNTER_ID BIGINT,
	PATIENT_NBR BIGINT,
	RACE VARCHAR(20),
	GENDER VARCHAR(20),
	AGE VARCHAR(20),
	ADMISSION_TYPE_ID INT,
	ADMISSION_TYPE_DESCRIPTION VARCHAR(50),
	DISCHARGE_DISPOSITION_ID INT,
	DISCHARGE_DESCRIPTION VARCHAR(200),
	ADMISSION_SOURCE_ID INT,
	ADMISSION_SOURCE_DESCRIPTION VARCHAR(100),
	TIME_IN_HOSPITAL INT,
	MEDICAL_SPECIALTY VARCHAR(100),
	NUM_LAB_PROCEDURES INT,
	NUM_PROCEDURES INT,
	NUM_MEDICATIONS INT,
	NUMBER_OUTPATIENT INT,
	NUMBER_EMERGENCY INT,
	NUMBER_INPATIENT INT,
	DIAG_1 VARCHAR(10),
	DIAG_1_GROUP_NAME VARCHAR(50),
	DIAG_2 VARCHAR(10),
	DIAG_2_GROUP_NAME VARCHAR(50),
	DIAG_3 VARCHAR(10),
	DIAG_3_GROUP_NAME VARCHAR(50),
	NUMBER_DIAGNOSES INT,
	MAX_GLU_SERUM VARCHAR(10),
	A1CRESULT VARCHAR(10),
	METFORMIN VARCHAR(10),
	REPAGLINIDE VARCHAR(10),
	NATEGLINIDE VARCHAR(10),
	CHLORPROPAMIDE VARCHAR(10),
	GLIMEPIRIDE VARCHAR(10),
	ACETOHEXAMIDE VARCHAR(10),
	GLIPIZIDE VARCHAR(10),
	GLYBURIDE VARCHAR(10),
	TOLBUTAMIDE VARCHAR(10),
	PIOGLITAZONE VARCHAR(10),
	ROSIGLITAZONE VARCHAR(10),
	ACARBOSE VARCHAR(10),
	MIGLITOL VARCHAR(10),
	TROGLITAZONE VARCHAR(10),
	TOLAZAMIDE VARCHAR(10),
	EXAMIDE VARCHAR(10),
	CITOGLIPTON VARCHAR(10),
	INSULIN VARCHAR(10),
	GLYBURIDE_METFORMIN VARCHAR(10),
	GLIPIZIDE_METFORMIN VARCHAR(10),
	GLIMEPIRIDE_PIOGLITAZONE VARCHAR(10),
	METFORMIN_ROSIGLITAZONE VARCHAR(10),
	METFORMIN_PIOGLITAZONE VARCHAR(10),
	CHANGE VARCHAR(10),
	DIABETESMED VARCHAR(10),
	READMITTED VARCHAR(10),
	READMISSION_STATUS VARCHAR(10)
);



-- Import patient readmission data into DIABETIC_READMISSION_RATE table
COPY DIABETIC_READMISSION_RATE
FROM
	'C:\Users\Aerene\Desktop\Readmission Analysis\diabetic_data_analysis.csv'
WITH
	(
		FORMAT CSV, -- Data is in CSV format
		HEADER      -- The first row contains column names
	);



-- Identifying readmission rate across the five HbA1c groups
SELECT
	-- Categorize HbA1c results into distinct groups based on A1CRESULT and medication changes
	CASE
		WHEN A1CRESULT = '>7' THEN '>7'
		WHEN A1CRESULT = 'None' THEN 'None'
		WHEN A1CRESULT = 'Norm' THEN 'Norm'
		WHEN A1CRESULT = '>8'
		AND CHANGE = 'Ch' THEN '>8 with Med Change'
		WHEN A1CRESULT = '>8'
		AND CHANGE = 'No' THEN '>8 without Med Change'
	END AS A1CRESULT_CATEGORY,
	
-- Count total encounters in each HbA1c group
	COUNT(*) AS TOTAL_READMISSIONS,

-- Count only records where the patient was readmitted
	SUM(
		CASE
			WHEN READMISSION_STATUS = 'Readmitted' THEN 1
			ELSE 0
		END
	) AS ONLY_READMITTED,

-- Calculate the readmission rate as a percentage with one decimal point	
	ROUND(
		CAST(
			SUM(
				CASE
					WHEN READMISSION_STATUS = 'Readmitted' THEN 1
					ELSE 0
				END
			) AS DECIMAL
		) / COUNT(*) * 100, -- Formula: (readmitted / total) * 100
		1 -- Round to 1 decimal place
	) AS READMISSION_RATE
FROM
	DIABETIC_READMISSION_RATE
GROUP BY
	-- Group results by the categorized HbA1c groups
	A1CRESULT_CATEGORY;



-- Identifying readmission rate across HbA1c groups with shorter hospital stay (1 to 7 days)
SELECT
	-- Categorize HbA1c results based on A1CRESULT and medication changes
	CASE
		WHEN A1CRESULT = '>7' THEN '>7'
		WHEN A1CRESULT = 'None' THEN 'None'
		WHEN A1CRESULT = 'Norm' THEN 'Norm'
		WHEN A1CRESULT = '>8'
		AND CHANGE = 'Ch' THEN '>8 with Med Change'
		WHEN A1CRESULT = '>8'
		AND CHANGE = 'No' THEN '>8 without Med Change'
	END AS A1CRESULT_CATEGORY,

 -- Count total records in each HbA1c group
	COUNT(*) AS TOTAL_READMISSIONS,

-- Count only records where the patient was readmitted
	SUM(
		CASE
			WHEN READMISSION_STATUS = 'Readmitted' THEN 1
			ELSE 0
		END
	) AS ONLY_READMITTED,

-- Calculate the readmission rate for shorter hospital stays (1-7 days)
	ROUND(
		CAST(
			SUM(
				CASE
					WHEN READMISSION_STATUS = 'Readmitted' THEN 1
					ELSE 0
				END
			) AS DECIMAL
		) / COUNT(*) * 100, -- Formula: (readmitted / total) * 100
		1  -- Round to 1 decimal place
	) AS SHORTSTAY_READMISSION_RATE
FROM
 	-- Source table containing diabetic patient data
	DIABETIC_READMISSION_RATE
WHERE
	-- Filter encounters for hospital stays between 1 and 7 days
	TIME_IN_HOSPITAL >= 1
	AND TIME_IN_HOSPITAL <= 7
GROUP BY
 	-- Group results by the categorized HbA1c groups
	A1CRESULT_CATEGORY;



-- Identifying readmission rates across HbA1c groups with longer hospital stay (8 to 14 days)
SELECT
 	-- Categorize HbA1c results based on A1CRESULT and medication changes
	CASE
		WHEN A1CRESULT = '>7' THEN '>7'
		WHEN A1CRESULT = 'None' THEN 'None'
		WHEN A1CRESULT = 'Norm' THEN 'Norm'
		WHEN A1CRESULT = '>8'
		AND CHANGE = 'Ch' THEN '>8 with Med Change'
		WHEN A1CRESULT = '>8'
		AND CHANGE = 'No' THEN '>8 without Med Change'
	END AS A1CRESULT_CATEGORY,

-- Count total encounter in each HbA1c group
	COUNT(*) AS TOTAL_READMISSIONS,

-- Count only encounters where the patient was readmitted
	SUM(
		CASE
			WHEN READMISSION_STATUS = 'Readmitted' THEN 1
			ELSE 0
		END
	) AS ONLY_READMITTED,

-- Calculate the readmission rate for longer hospital stays (8-14 days)
	ROUND(
		CAST(
			SUM(
				CASE
					WHEN READMISSION_STATUS = 'Readmitted' THEN 1
					ELSE 0
				END
			) AS DECIMAL
		) / COUNT(*) * 100, -- Formula: (readmitted / total) * 100
		1  -- Round to 1 decimal place
	) AS LONGSTAY_READMISSION_RATE
FROM
	DIABETIC_READMISSION_RATE
WHERE
	 -- Filter records for hospital stays between 8 and 14 days
	TIME_IN_HOSPITAL >= 8
	AND TIME_IN_HOSPITAL <= 14
GROUP BY
	 -- Group results by the categorized HbA1c groups
	A1CRESULT_CATEGORY;


-- Analyzing readmission rates across HbA1c groups in correlation to primary diagnoses
SELECT DISTINCT
	-- Include primary diagnosis from the first diagnostic group
	(DIAG_1_GROUP_NAME) AS PRIMARY_DIAGNOSIS,

-- Categorize HbA1c results into distinct groups based on A1CRESULT and medication changes
	CASE
		WHEN A1CRESULT = '>7' THEN '>7'
		WHEN A1CRESULT = 'None' THEN 'None'
		WHEN A1CRESULT = 'Norm' THEN 'Norm'
		WHEN A1CRESULT = '>8'
		AND CHANGE = 'Ch' THEN '>8 with Med Change'
		WHEN A1CRESULT = '>8'
		AND CHANGE = 'No' THEN '>8 without Med Change'
	END AS A1CRESULT_CATEGORY,

-- Count total records in each group	
	COUNT(*) AS TOTAL_READMISSIONS,

-- Count only records where the patient was readmitted
	SUM(
		CASE
			WHEN READMISSION_STATUS = 'Readmitted' THEN 1
			ELSE 0
		END
	) AS ONLY_READMITTED,

-- Calculate the readmission rate as a percentage with one decimal point
	ROUND(
		CAST(
			SUM(
				CASE
					WHEN READMISSION_STATUS = 'Readmitted' THEN 1
					ELSE 0
				END
			) AS DECIMAL
		) / COUNT(*) * 100,  -- Formula: (readmitted / total) * 100
		1   -- Round to 1 decimal place
	) AS READMISSION_RATE
FROM
	-- Source table containing diabetic patient data
	DIABETIC_READMISSION_RATE
GROUP BY
	-- Group by categorized HbA1c results and primary diagnosis
	A1CRESULT_CATEGORY,
	DIAG_1_GROUP_NAME;



-- Analyzing readmission rates across HbA1c groups segmented by age groups
SELECT
	-- Categorize HbA1c results into distinct groups based on A1CRESULT and medication changes
	CASE
		WHEN A1CRESULT = '>7' THEN '>7'
		WHEN A1CRESULT = 'None' THEN 'None'
		WHEN A1CRESULT = 'Norm' THEN 'Norm'
		WHEN A1CRESULT = '>8'
		AND CHANGE = 'Ch' THEN '>8 with Med Change'
		WHEN A1CRESULT = '>8'
		AND CHANGE = 'No' THEN '>8 without Med Change'
	END AS A1CRESULT_CATEGORY,

-- Segment patients into age groups
	CASE
		WHEN AGE BETWEEN '[0-10)' AND '[20-30)'  THEN '30 years Old or younger'
		WHEN AGE BETWEEN '[30-40)' AND '[50-60)'  THEN '30-60 years old'
		ELSE 'Older than 60'
	END AS AGE_GROUP,

-- Count total records in each group
	COUNT(*) AS TOTAL_READMISSIONS,

-- Count only records where the patient was readmitted
	SUM(
		CASE
			WHEN READMISSION_STATUS = 'Readmitted' THEN 1
			ELSE 0
		END
	) AS ONLY_READMITTED,

-- Calculate the readmission rate as a percentage with one decimal point
	ROUND(
		CAST(
			SUM(
				CASE
					WHEN READMISSION_STATUS = 'Readmitted' THEN 1
					ELSE 0
				END
			) AS DECIMAL
		) / COUNT(*) * 100,  -- Formula: (readmitted / total) * 100
		1 	-- Round to 1 decimal place
	) AS READMISSION_RATE
FROM
	-- Source table containing diabetic patient data
	DIABETIC_READMISSION_RATE
WHERE
	-- Ensure HbA1c results are not null
	A1CRESULT IS NOT NULL
GROUP BY
	-- Group by categorized HbA1c results and age groups
	A1CRESULT_CATEGORY,
	CASE
		WHEN AGE BETWEEN '[0-10)' AND '[20-30)'  THEN '30 years Old or younger'
		WHEN AGE BETWEEN '[30-40)' AND '[50-60)'  THEN '30-60 years old'
		ELSE 'Older than 60'
	END
ORDER BY
	-- Order the output by age group in ascending order
	AGE_GROUP ASC;



-- Analyzing readmission rates across HbA1c groups segmented by race
SELECT
	-- Categorize HbA1c results into distinct groups based on A1CRESULT and medication changes
	CASE
		WHEN A1CRESULT = '>7' THEN '>7'
		WHEN A1CRESULT = 'None' THEN 'None'
		WHEN A1CRESULT = 'Norm' THEN 'Norm'
		WHEN A1CRESULT = '>8'
		AND CHANGE = 'Ch' THEN '>8 with Med Change'
		WHEN A1CRESULT = '>8'
		AND CHANGE = 'No' THEN '>8 without Med Change'
	END AS A1CRESULT_CATEGORY,

-- Include race of the patient for segmentation
	RACE,

-- Count total encounters in each group
	COUNT(*) AS TOTAL_READMISSIONS,

-- Count only encounters where the patient was readmitted
	SUM(
		CASE
			WHEN READMISSION_STATUS = 'Readmitted' THEN 1
			ELSE 0
		END
	) AS ONLY_READMITTED,

-- Calculate the readmission rate as a percentage with one decimal point
	ROUND(
		CAST(
			SUM(
				CASE
					WHEN READMISSION_STATUS = 'Readmitted' THEN 1
					ELSE 0
				END
			) AS DECIMAL
		) / COUNT(*) * 100, -- Formula: (readmitted / total) * 100
		1 -- Round to 1 decimal place
	) AS READMISSION_RATE
FROM
	-- Source table containing diabetic patient data
	DIABETIC_READMISSION_RATE
WHERE
	 -- Ensure HbA1c results are not null
	A1CRESULT IS NOT NULL
GROUP BY
	-- Group by categorized HbA1c results and race
	A1CRESULT_CATEGORY,
	RACE
ORDER BY
	-- Order the output by race in ascending order
	RACE ASC;



-- Analyzing readmission rates across HbA1c groups segmented by gender
SELECT 
	-- Categorize HbA1c results into distinct groups based on A1CRESULT and medication changes
    CASE 
        WHEN A1Cresult = '>7' THEN '>7'
        WHEN A1Cresult = 'None' THEN 'None'
        WHEN A1Cresult = 'Norm' THEN 'Norm'
        WHEN A1Cresult = '>8' AND change = 'Ch' THEN '>8 with Med Change'
        WHEN A1Cresult = '>8' AND change = 'No' THEN '>8 without Med Change'
    END AS A1Cresult_category,

-- Include gender of the patient for segmentation
	gender,

-- Count total encounters in each group
    COUNT(*) AS total_readmissions,

-- Count only records where the patient was readmitted
   SUM(
	CASE
		WHEN READMISSION_STATUS = 'Readmitted' THEN 1
		ELSE 0
	END
) AS ONLY_READMITTED,

-- Calculate the readmission rate as a percentage with one decimal point
ROUND(
        CAST(
            SUM(
                CASE 
                    WHEN readmission_status = 'Readmitted' THEN 1 
                    ELSE 0 
                END
            ) AS DECIMAL
        ) / COUNT(*) * 100, -- Formula: (readmitted / total) * 100
        1 -- Round to 1 decimal place
    ) AS readmission_rate
FROM
	 -- Source table containing diabetic patient data
    diabetic_readmission_rate
 WHERE 
	 -- Ensure HbA1c results are not null
	 a1cresult IS NOT NULL 
	-- Exclude invalid or unknown gender values
	AND gender NOT IN ('Unknown/Invalid') 
GROUP BY 
	-- Group by categorized HbA1c results and gender
    A1Cresult_category, 
	gender
ORDER BY 
	-- Order the output by gender in ascending order
	gender ASC;
