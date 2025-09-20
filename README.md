# Impact of HbA1c Measurement on Hospital Readmission Rates

## Table of Contents

- [Project Overview](#project-overview)
- [Data Sources](#data-sources)
- [Tools](#tools)
- [Data Cleaning](#data-cleaning)
- [Exploratory Data Analysis](#exploratory-data-analysis)
- [Data Analysis](#data-analysis)
- [Findings](#findings)
- [Recommendations](#recommendations)
- [Limitations](#limitations)
- [References](#references)

  
### Project Overview
This project investigates the relationship between HbA1c levels, a critical biomarker for diabetes management, and hospital readmission rates. 
The analysis aims to uncover:

1. How HbA1c measurements influence readmission patterns.  

2. The impact of medication changes across different HbA1c groups. 

3. Key trends and insights to inform better diabetes care and hospital management strategies.


### Data Sources

Diabetic Data: The primary dataset used for this analysis is the 'org_diabetic_data.csv,' containing 101,766 encounters focused on cases where diabetes is coded as an existing condition. Readmissions are classified as "readmitted" (within 30 days) or "otherwise," aiming to identify factors influencing early readmission and improve diabetes care strategies.

### Tools

- Excel: Data Cleaning [Download here](https://www.microsoft.com)
- SQL Server: Data Analysis [Download here](https://www.postgresql.org)
- PowerBi: Data Visualization  [Download here](https://www.microsoft.com)

### Data Cleaning
#### Data Loading and Inspection:
The dataset contained several features with significant missing values:
 - Weight: 97% missing, excluded due to sparsity.
 - Payer Code: 40% missing, removed as it was irrelevant to the outcome.
 - Medical Specialty: 47% missing, retained with missing values replaced by "missing." 

#### Handling Duplicates and Missing Values:
- Removed duplicate encounters.
- Retained only the first encounter for each patient as the primary admission.
- Replaced ? or missing values with "missing" for consistency.
- Excluded encounters resulting in discharge to hospice or patient death to avoid bias.

#### Enhancements and Formatting:
- Used TRIM(PROPER) to clean extra spaces and ensure consistent formatting.
- Mapped ICD codes and discharge IDs using lookup tables (ICD_Lookup.csv and IDs_Mapping_Lookup.csv).

After these steps, the dataset was reduced to 69,974 encounters, forming the final dataset for analysis.

### Exploratory Data Analysis (EDA)
The EDA focused on exploring key aspects of the diabetic dataset to address critical questions:
- What is the overall readmission rate?
- How does the readmission rate vary across the five HbA1c groups?
  1. No HbA1c test performed
  2. HbA1c within the normal range
  3. HbA1c > 8%, no change in diabetic medications
  4. HbA1c > 8%, with a change in diabetic medications
  5. HbA1c > 7% but < 8%
- What is the readmission rate comparison between shorter hospital stays (1–7 days) and longer stays (8–14 days) across the HbA1c groups?
- How do readmission rates differ across HbA1c groups when correlated with primary diagnoses?
- How do demographic factors (age, race, gender) influence readmission rates across HbA1c groups?
- How do high-risk HbA1c groups (HbA1c > 8% with medication change) compare to those with HbA1c > 8% but no medication change?

### Data Analysis
```sql
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
```

```sql
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
```

### Findings
- Overall Readmission Rate: 9.0%, with 6,277 patients readmitted.
- Readmission Rate by Medication Change: Patients without medication changes (4.7%) have a slightly higher readmission risk compared to those with medication changes (4.2%).
- Group Comparison: The ">8 no MedChange" group (7.4%) has a notably lower readmission rate compared to other groups.
- Untested Patients: Patients without HbA1c testing face increased readmission risk.
- Impact of Routine HbA1c Testing: Routine HbA1c testing could help reduce readmission rates by identifying high-risk patients early.
- Medication Changes: Medication changes show mixed results: a marginal benefit for prediabetic patients (HbA1c >7) but higher readmissions for patients with higher HbA1c levels (>8).
The HbA1c >8 with Medication Change group shows a higher readmission rate (8.6%), indicating limited effectiveness of medication adjustments in reducing readmissions.
- Stable Insulin Dosing: Stable insulin dosing is correlated with lower readmissions in patients with high HbA1c levels.
- Impact of Hospital Stay Duration: Longer hospital stays (8–14 days) are associated with higher readmissions (11.8%) compared to shorter stays (1–7 days) with 8.5%, suggesting premature discharge may not be a factor in higher readmissions.
- Primary Diagnosis Influence: Neoplasmic cases have the highest readmission rate (14.3%) at HbA1c >7. Circulatory (11.3%) and musculoskeletal (10.9%) risks differ depending on medication changes in the HbA1c >8 group.
- Age and Gender Influence: Older patients face higher readmission risks across all HbA1c groups. The highest readmission rate is found in females with HbA1c >7 (9.8%) and the lowest in males with HbA1c >8 and no medication changes (6.6%).

### Recommendations

1. Regular HbA1c testing should be encouraged to identify high-risk patients early. This could lead to better diabetes management and potentially lower readmission rates, especially for patients with higher HbA1c levels.
2. Reevaluate Medication Changes for High HbA1c Patients: The limited effectiveness of medication changes in reducing readmissions for patients with HbA1c >8 suggests a need for more targeted or alternative interventions. A deeper investigation into personalized treatment plans, including lifestyle changes, may yield better results than medication adjustments alone.
3. While longer hospital stays are linked to higher readmission rates, it’s important to focus on ensuring proper post-discharge care and monitoring rather than extending hospital stays.
4. Older patients and females with HbA1c >7 have the highest readmission rates. Implementing personalized care strategies for these groups, such as closer monitoring, support systems, and customized treatment plans, could improve patient outcomes.
5. Neoplasmic patients with HbA1c >7 face the highest readmission rates. Targeted interventions and tailored care for this group could help reduce readmission rates. Similarly, circulatory and musculoskeletal conditions should be specifically addressed, as they show differing outcomes with medication changes.

### Limitations

The dataset had significant missing values, with 97% of the weight data excluded, 40% of the payer code data removed due to irrelevance, and 47% of the medical specialty data retained with missing values replaced, which may introduce potential bias and limit the scope of the analysis. I also excluded encounters resulting in discharge to hospice or patient death to avoid bias.

### References
[Research Article](https://onlinelibrary.wiley.com/doi/10.1155/2014/781670)
