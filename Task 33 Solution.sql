-- Problem 1. Find out the average sleep duration of top 15 male candidates who's 
-- sleep duration are equal to 7.5 or greater than 7.5.
-- ALTER TABLE sleep.sleep_efficiency 
-- CHANGE COLUMN ID id INTEGER, 
-- CHANGE COLUMN Age age INTEGER
SELECT AVG(sleep_duration) FROM sleep.sleep_efficiency
WHERE sleep_duration >= 7.5 AND gender = 'male'
ORDER BY sleep_duration DESC LIMIT 15;


-- Problem 2: Show avg deep sleep time for both gender. Round result at 2 decimal places.
-- Note: sleep time and deep sleep percentage will give you, deep sleep time.
SELECT gender,AVG(sleep_duration*(deep_sleep_percentage/100)) AS 'deep_sleep_time' 
FROM sleep.sleep_efficiency
GROUP BY gender;


-- Problem 3: Find out the lowest 10th to 30th light sleep percentage records where deep sleep percentage values
-- are between 25 to 45. Display age, light sleep percentage and deep sleep percentage columns only.
SELECT age,light_sleep_percentage,deep_sleep_percentage FROM sleep.sleep_efficiency
WHERE deep_sleep_percentage BETWEEN 25 AND 45
ORDER BY light_sleep_percentage LIMIT 10,20;


-- Problem 4: Group by on exercise frequency and smoking status and show average deep sleep time,  
-- average light sleep time and avg rem sleep time.
-- Note the differences in deep sleep time for smoking and non smoking status
SELECT exercise_frequency,smoking_status,
ROUND(AVG(sleep_duration*(deep_sleep_percentage/100)),2) AS 'deep_sleep_time',
ROUND(AVG(sleep_duration*(light_sleep_percentage/100)),2) AS 'light_sleep_time',
ROUND(AVG(sleep_duration*(rem_sleep_percentage/100)),2) AS 'rem_sleep_time'
FROM sleep.sleep_efficiency
GROUP BY exercise_frequency,smoking_status
ORDER BY exercise_frequency,smoking_status DESC;


-- Problem 5: Group By on Awekning and show AVG Caffeine consumption, AVG Deep sleep time and AVG 
-- Alcohol consumption only for people who do exercise atleast 3 days a week. Show result in descending
-- order awekenings
SELECT awakenings,
AVG(caffeine_consumption) AS 'avg_caffeine_consumption',
AVG(alcohol_consumption) AS 'avg_alcohol_consumption',
ROUND(AVG(sleep_duration*(deep_sleep_percentage/100)),2) AS 'deep_sleep_time'
FROM sleep.sleep_efficiency
WHERE exercise_frequency >= 3
GROUP BY awakenings
ORDER BY awakenings DESC ;


-- Problem 6 : Display those power stations which have average 'Monitored Cap.(MW)' (display the values) 
-- between 1000 and 2000 and the number of occurance of the power stations (also display these values) 
-- are greater than 200. Also sort the result in ascending order. 
-- NOTE Only 22387 rows imported so used 120 for filter instead of 200
SELECT `Power Station`,
ROUND(AVG(`Monitored Cap.(MW)`),2) AS 'avg_monitored_cap',
COUNT(*) AS 'num_stations'
FROM sleep.powergeneration
GROUP BY `Power Station` 
HAVING (avg_monitored_cap BETWEEN 1000 AND 2000) AND num_stations > 120
ORDER BY avg_monitored_cap;


-- Problem 7: Display top 10 lowest "value" State names of which the Year either belong to 
-- 2013 or 2017 or 2021 and type is 'Public In-State'. Also the number of occurance should be 
-- between 6 to 10. Display the average value upto 2 decimal places, state names and the occurance of 
-- the states.
SELECT `State`, 
ROUND(AVG(Value),2) AS 'avg_value',
COUNT(*) AS 'frequency'
FROM sleep.undergrad
WHERE `Year` IN (2013,2017,2021) AND `Type` = 'Public In-State' 
GROUP BY `State` HAVING `frequency` BETWEEN 6 AND 10
ORDER BY `avg_value` LIMIT 10 ;


-- Problem 8: Best state in terms of low education cost (Tution Fees) in 'Public' type university.
SELECT State, AVG(`Value`) AS 'avg_value' FROM undergrad
WHERE `Type` LIKE 'Public%' AND Expense = "Fees/Tuition"
GROUP BY State
ORDER BY avg_value LIMIT 1;


-- Problem 9: 2nd Costliest state for Private education in year 2021. Consider, Tution and Room fee both.
SELECT State, AVG(Value) AS 'value' FROM undergrad
WHERE `Type` LIKE '%Private%' AND `Year` = 2021
GROUP BY State 
ORDER BY value DESC LIMIT 1,1;


-- Problem 10: Display total and average values of Discount_offered for all the combinations of 
-- 'Mode_of_Shipment' (display this feature) and 'Warehouse_block' (display this feature also) for all 
-- male ('M') and 'High' Product_importance. Also sort the values in descending order of 
-- Mode_of_Shipment and ascending order of Warehouse_block.
SELECT Mode_of_Shipment, Warehouse_block,
SUM(Discount_offered) AS 'total_discount',
ROUND(AVG(Discount_offered),2) AS 'avg_discount'
FROM sleep.shipping_ecommerce
WHERE Gender = 'M' AND Product_importance = 'high'
GROUP BY Mode_of_Shipment,Warehouse_block
ORDER BY Mode_of_Shipment DESC,Warehouse_block ASC ;
