-- first thing we want to do is create a staging table. This is the one we will work in and clean the data. We want a table with the raw data in case something happens
SELECT *
INTO hr_clean
FROM HR_dataset..hr_dataset;

-- dataset begins with 1485 rows of data
SELECT *
FROM hr_clean

-- Now we will conduct data cleaning using ctes to break down the stages of data cleaning
-- first we will remove rows that are blank
;WITH hr_cleaned AS
(
	SELECT [EmpID]
				, [Age]
				, [Attrition]
				, [Department]
				, [EducationField]
				, [Gender]
				, [JobInvolvement]
				, [JobLevel]
				, [JobRole]
				, [JobSatisfaction]
				, [MonthlyIncome]
				, [NumCompaniesWorked]
				, [PerformanceRating]
				, [TotalWorkingYears]
				, [TrainingTimesLastYear]
				, [WorkLifeBalance]
				, [YearsAtCompany]
				, [YearsSinceLastPromotion]
 FROM [dbo].[hr_clean]
 Where EmpID IS NOT NULL 
	AND Attrition IS NOT NULL
	AND Department IS NOT NULL
	AND Age != 0
	AND Age > 0
)

-- 1477 remain after removing blank fields. 8 rows were removed
--SELECT * 
--FROM hr_cleaned
, dup_locating AS
(
-- now we show the duplicates in the dataset 
select * , ROW_NUMBER() OVER (PARTITION BY EmpID, Attrition, Department, Gender, EducationField, 
JobSatisfaction ORDER BY Age)dup_flag
FROM hr_cleaned
)
--select * 
--from dup_locating
-- Now we will create a temp table to conduct the data analysis on with the cleaned data
SELECT *
INTO #hr_final_dataset
FROM dup_locating
WHERE dup_flag = 1

-- 1462 Rows remain in the final cleaned dataset with duplicates and blank fields removed
-- 15 duplicates were removed
SELECT *
FROM #hr_final_dataset

-- How many employees have left the company?
SELECT Attrition, COUNT(Attrition) count_attrition
FROM #hr_final_dataset
GROUP BY Attrition
-- There are currently 1230 employees at the company and 232 employees have left the company. 

--What is difference the time since last promotion in employees who left and who stayed at the company?
Select Attrition, AVG(CAST(YearsSinceLastPromotion AS DECIMAL(10, 2))) avg_years_since_last_promotion
FROM #hr_final_dataset
GROUP BY Attrition
--attrition yes - 1.98 and no 2.24
-- Interestingly employees who left received promotions more recently than those who are still at the company

--From is the difference between job satisfaction of employees who are still and who left the company?
Select Attrition, AVG(CAST(JobSatisfaction AS DECIMAL(10, 2))) avg_job_satisfaction
FROM #hr_final_dataset
GROUP BY Attrition
-- attrition yes 2.45 and no 2.78

--We will now go into more detail on the job satisfaction of the employees who left the company
SELECT
	job_satisfaction,
	COUNT(job_satisfaction) AS job_satisfaction_count
FROM (
	SELECT
		CASE
			WHEN JobSatisfaction = 1 THEN 'Poor job satisfaction'
			WHEN JobSatisfaction = 2 THEN 'Fair job satisfaction'
			WHEN JobSatisfaction = 3 THEN 'Good job satisfaction'
			ELSE 'Very good satisfaction'
	END AS job_satisfaction, Attrition
FROM #hr_final_dataset
WHERE Attrition = 'Yes'
) AS subquery
GROUP BY job_satisfaction
ORDER BY job_satisfaction_count DESC;
-- 45 fair satisfaction, 50 very good satisfaction, 66 poor job satisfaction, good job satisfaction 71
		 
--What is department that experienced the most attrition?
Select Department, COUNT(Attrition)
FROM #hr_final_dataset
WHERE Attrition = 'Yes'
GROUP BY Department
-- human resources 11, research and development 130, sales 91

--What was the average monthly income across departments?
Select Department, AVG(CAST(MonthlyIncome AS DECIMAL(10, 2))) monthly_income_across_departments
FROM #hr_final_dataset
GROUP BY Department
ORDER BY monthly_income_across_departments DESC;
--sales 6981,51, human resources 6720.48, research and development 6300,72

--What is the average length of employment for employees who have left the company?
Select Attrition, AVG(CAST(YearsAtCompany AS DECIMAL(10, 2))) years_at_company_by_attrition
FROM #hr_final_dataset
GROUP BY Attrition
ORDER BY years_at_company_by_attrition DESC;
-- attrition no 7.38, yes 5.22

--What is the job satisfaction based on the years employees have been at the company?
Select YearsAtCompany, AVG(CAST(JobSatisfaction AS DECIMAL(10, 2))) job_satisfaction_by_years
FROM #hr_final_dataset
GROUP BY YearsAtCompany
ORDER BY YearsAtCompany DESC;
-- it appears that the longer the years an individual stayed at the company the more satisfied they were as the higher averages were found in employees who were at the company longer

--What is the average tenure across departments?
Select Department, AVG(CAST(YearsAtCompany AS DECIMAL(10, 2))) years_at_company_by_years
FROM #hr_final_dataset
GROUP BY Department
ORDER BY years_at_company_by_years DESC;
-- human resources 7.34, sales 7.32, research and development 6.89

SELECT *
INTO hr_final_cleaned
FROM #hr_final_dataset;

select * 
from hr_final_cleaned

DROP TABLE #hr_final_dataset;


