# Problem 1: What are the top 5 patients who claimed the highest insurance amounts?
SELECT PatientID,claim,
RANK() OVER(ORDER BY claim DESC) 
FROM insurance LIMIT 5;

SELECT PatientID,claim FROM insurance
ORDER BY claim DESC LIMIT 5; 

# Problem 2: What is the average insurance claimed by patients based on the number of children 
# they have?
SELECT children,avg_claim FROM (SELECT children,
ROUND(AVG(claim) OVER(PARTITION BY children),2) AS 'avg_claim',
ROW_NUMBER() OVER(PARTITION BY children) AS 'row_num'
FROM insurance) t
WHERE t.row_num = 1;

# Problem 3: What is the highest and lowest claimed amount by patients in each region?
SELECT DISTINCT region,
MAX(claim) OVER(PARTITION BY region) AS 'max_claim',
MIN(claim) OVER(PARTITION BY region) AS 'min_claim'
FROM insurance;

SELECT region,max_claim,min_claim FROM(SELECT DISTINCT region,
MAX(claim) OVER(PARTITION BY region) AS 'max_claim',
MIN(claim) OVER(PARTITION BY region) AS 'min_claim',
ROW_NUMBER() OVER(PARTITION BY region) AS 'row_num'
FROM insurance) t
WHERE t.row_num = 1;

# Problem 4: What is the percentage of smokers in each age group?
SELECT age,`% smoker` FROM(WITH smoker_data AS(SELECT * FROM insurance
WHERE smoker = 'Yes')
SELECT age,
(COUNT(smoker) OVER(PARTITION BY age)/(SELECT COUNT(*) FROM smoker_data))*100 AS '% smoker',
ROW_NUMBER() OVER(PARTITION BY age) AS 'row_num'
FROM smoker_data) t
WHERE t.row_num = 1;

# Problem 5: What is the difference between the claimed amount of each patient and the claim  
# amount of first patient ?
SELECT PatientID,
ROUND(claim - FIRST_VALUE(claim) OVER(),2) AS 'claim_diff_with_first_patient'
FROM insurance;

# Problem 6: For each patient, calculate the difference between their claimed amount and the 
# average claimed amount of patients with the same number of children.
SELECT PatientID,claim,
ROUND(claim - AVG(claim) OVER(PARTITION BY children),2) AS 'avg_claim_difference'
FROM insurance;

# Problem 7: Show the patient with the highest BMI in each region and their respective overall rank.
SELECT t.PatientID,bmi,bmi_overall_rank,region_bmi_rank,region FROM(SELECT PatientID, bmi,region,
DENSE_RANK() OVER(PARTITION BY region ORDER BY bmi DESC) AS 'region_bmi_rank',
DENSE_RANK() OVER(ORDER BY bmi DESC) AS 'bmi_overall_rank',
MAX(bmi) OVER(PARTITION BY region) AS 'max_bmi_regionwise'
FROM insurance) t
WHERE t.bmi = max_bmi_regionwise
ORDER BY PatientID;

# Problem 8: Calculate the difference between the claimed amount of each patient and the claimed 
# amount of the patient who has the highest BMI in their region.
SELECT *,
claim - FIRST_VALUE(claim) OVER(PARTITION BY region ORDER BY bmi DESC) AS 'claim_diff'
FROM insurance;

# Problem 9: For each patient, calculate the difference in claim amount between the patient and 
# the patient with the highest claim amount among patients with the same bmi and smoker status, 
# within the same region. Return the result in descending order difference.
SELECT *,
ROUND(Max(claim) OVER(PARTITION BY region,smoker) - claim,2) AS 'claim_diff'
FROM insurance
ORDER BY claim_diff DESC;

# Problem 10: For each patient, find the maximum BMI value among their next three records 
-- (ordered by age)
SELECT *,
MAX(bmi) OVER(ORDER BY age ROWS BETWEEN 1 FOLLOWING AND 3 FOLLOWING)
FROM insurance;

# Problem 11: For each patient, find the rolling average of the last 2 claims.
SELECT *,
AVG(claim) OVER(ROWS BETWEEN 2 PRECEDING AND 1 PRECEDING)
FROM insurance;

# Problem 12: Find the first claimed insurance value for male and female patients, within each 
# region order the data by patient age in ascending order, and only include patients who are 
# non-diabetic and have a bmi value between 25 and 30.
SELECT region,gender,first_claim FROM (SELECT *,
FIRST_VALUE(claim) OVER(PARTITION BY region,gender ORDER BY age ASC) AS 'first_claim',
ROW_NUMBER() OVER(PARTITION BY region,gender ORDER BY age ASC) AS 'row_num'
FROM insurance
WHERE diabetic = "No" AND bmi BETWEEN 25 AND 30) t
WHERE t.row_num = 1;