-- Problem 1 Display the names of athletes who won a gold medal in the 2008 Olympics and whose height is   
-- greater than the average height of all athletes in the 2008 Olympics.
SELECT name FROM olympic_data
WHERE Year = 2008 AND Medal = "Gold" AND Height > (SELECT AVG(Height) FROM olympic_data WHERE Year = 2008);

-- Problem 2 Display the names of athletes who won a medal in the sport of basketball in the 2016 Olympics 
-- and whose weight is less than the average weight of all athletes who won a medal in the 2016 Olympics.
SELECT name FROM olympic_data
WHERE Year = 2016 AND Medal IS NOT NULL AND Sport = 'Basketball' AND 
Weight < (SELECT AVG(Weight) FROM olympic_data WHERE Year = 2016 AND Medal IS NOT NULL);

-- Problem 3 Display the names of all athletes who have won a medal in the sport of swimming in both the 
-- 2008 and 2016 Olympics.
SELECT Name FROM olympic_data
WHERE SPORT = "swimming" AND Medal IS NOT NULL AND Year IN(2008,2016)
GROUP BY ID,Name HAVING COUNT(*) = 2;

SELECT DISTINCT Name FROM olympic_data
WHERE SPORT = "swimming" AND Medal IS NOT NULL AND 
Name IN(SELECT name FROM olympic_data WHERE SPORT = "swimming" AND Medal IS NOT NULL AND Year = 2008) AND 
Name IN(SELECT name FROM olympic_data WHERE SPORT = "swimming" AND Medal IS NOT NULL AND Year = 2016)
ORDER BY Name;

-- Problem 4 Display the names of all countries that have won more than 50 medals in a single year.
SELECT DISTINCT Country FROM olympic_data
WHERE Medal IS NOT NULL
GROUP BY Year,Country HAVING COUNT(*) > 50;

-- Problem 5 Display the names of all athletes who have won medals in more than one sport in the same year.
SELECT Name FROM olympic_data
WHERE Medal IS NOT NULL 
GROUP BY ID,Name,Year
ORDER BY COUNT(DISTINCT Sport) DESC;

-- Problem 6 What is the average weight difference between male and female athletes in the Olympics 
-- who have won a medal in the same event same year same type of medal?
WITH filtered AS (SELECT t1.Year,t1.Event,
t1.name AS "Male_Athlete",t2.name AS 'Female_Athlete',
t1.Weight AS "Male_Weight",t2.Weight AS "Female_Weight",t1.Medal
FROM (SELECT Year,Event,Name,Medal,Weight FROM olympic_data
WHERE Medal IS NOT NULL AND Sex = 'M' AND Weight IS NOT NULL) AS t1
JOIN (SELECT Year,Event,Name,Medal,Weight FROM olympic_data
WHERE Medal IS NOT NULL AND Sex = 'F' AND Weight IS NOT NULL) AS  t2
ON t1.Event = t2.Event AND 
t1.Year = t2.Year AND
t1.Medal = t2.Medal
ORDER BY t1.Year) 
SELECT Event,AVG(Male_Weight),AVG(Female_Weight) FROM filtered 
GROUP BY Event;

-- Problem 6 What is the average weight difference between male and female athletes in the Olympics 
-- who have won a medal in the same event
SELECT A.Event,AVG(A.Weight) AS 'Male_Avg_Weight',
AVG(B.Weight) AS 'Female_Avg_Weight',
(AVG(A.Weight)- AVG(B.Weight)) AS "avg_weight_diff"
FROM (SELECT ID,Sex,Name,Event,Weight,Year FROM olympic_data
WHERE Medal IS NOT NULL AND Sex = "M" AND Weight IS NOT NULL) A
JOIN
(SELECT ID,Sex,Name,Event,Weight,Year FROM olympic_data
WHERE Medal IS NOT NULL AND Sex = "F" AND Weight IS NOT NULL) B
ON A.Event = B.Event AND A.Sex != B.Sex
GROUP BY A.Event;

-- Problem 7 How many patients have claimed more than the average claim amount for patients who are 
-- smokers and have at least one child, and belong to the southeast region?
SELECT COUNT(*) FROM insurance_db.insurance
WHERE claim > (SELECT AVG(claim) FROM insurance_db.insurance
WHERE smoker = 'Yes' AND children > 0 AND region ='southeast');

-- Problem 8 How many patients have claimed more than the average claim amount for patients who are not 
-- smokers and have a BMI greater than the average BMI for patients who have at least one child?
SELECT COUNT(*) FROM insurance_db.insurance
WHERE claim > (SELECT AVG(claim) FROM insurance_db.insurance
WHERE smoker = 'No' AND bmi > (SELECT AVG(bmi) FROM insurance_db.insurance WHERE children >=1));

-- Problem 9 How many patients have claimed more than the average claim amount for patients who have a 
-- BMI greater than the average BMI for patients who are diabetic, have at least one child, and are from 
-- the southwest region? 
SELECT COUNT(*) FROM insurance_db.insurance
WHERE claim > (SELECT AVG(claim) FROM insurance_db.insurance
				WHERE bmi > (SELECT AVG(bmi) FROM insurance_db.insurance 
							WHERE children >=1 AND diabetic = 'Yes' AND region = 'southwest'));

-- Problem 10 What is the difference in the average claim amount between patients who are smokers and 
-- patients who are non-smokers, and have the same BMI and number of children?
SELECT AVG(t1.claim) - AVG(t2.claim) AS 'avg_claim_difference' FROM (SELECT * FROM insurance_db.insurance
WHERE smoker = 'Yes') AS t1
JOIN (SELECT * FROM insurance_db.insurance
WHERE smoker = 'No') AS t2
ON t1.bmi = t2.bmi AND
t1.children = t2.children;



