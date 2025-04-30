-- SQL Retail Sales Analysis - P1

-- Create TABLE
USE retail_sales;
DROP TABLE IF EXISTS retail_sales;
CREATE TABLE retail_sales
					(
							transactions_id INT PRIMARY KEY,
							sale_date DATE,
							sale_time TIME,
							customer_id INT,
							gender VARCHAR(15),
							age INT,
							category VARCHAR(15),
							quantity INT,
							price_per_unit FLOAT,
							cogs FLOAT,
							total_sale FLOAT
					);
                    
SELECT * FROM retail_sales;

-- DATA CLEANING
SELECT COUNT(*) -- el resultado da 1987 y no 2000 porque MySQL no importó las 13 filas donde habían valores vacíos (10 de age y 3 de quantity)
FROM retail_sales;

SELECT * FROM retail_sales
WHERE total_sale IS NULL; -- Here we are reviewing if there are any null values

-- EDA

-- How many sales we have?
SELECT COUNT(*) AS total_sale
FROM retail_sales;

-- How many unique customers we have?
SELECT COUNT(DISTINCT customer_id) AS total_customers
FROM retail_sales;

-- how many unique categories we have
SELECT COUNT(DISTINCT category) AS total_customers
FROM retail_sales;

-- what are the unique categories we have
SELECT DISTINCT category
FROM retail_sales;

-- DATA ANALYSIS & BUSINESS KEY PROBLEMS & ANSWERS
-- Q.1 Retrieve all columns for sales made on '2022-11-05
-- Q.2 Retrieve all transactions where category is 'Clothing' and quantity sold is more than 10 in Nov-2022
-- Q.3 Calculate total sales (total_sale) for each category
-- Q.4 Find avg age of customers who purchased items from the 'Beauty' category
-- Q.5 Find all transactions where (total_sale) is > 1000
-- Q.6 Find total number of transactions (transaction_id) made by each gender in each category
-- Q.7 Calculate avg_sale for each month. Find out best selling month each year
-- Q.8 Find top 5 customers based on the highest_total_sales
-- Q.9 Find number of unique customers who purchased items from each category
-- Q.10 Create each shift and number of orders (Example Morning >=12, Afternoon Between 12 & 17, Evening > 17)

SELECT * FROM retail_sales;

-- Q.1 Retrieve all columns for sales made on '2022-11-05

SELECT *
FROM retail_sales
WHERE sale_date = '2022-11-05';

-- Q.2 Retrieve all transactions where category is 'Clothing' and quantity sold is more than 3 in the month Nov-2022

SELECT *		-- instructor solution
FROM retail_sales
WHERE 
	category = 'Clothing'
	AND 
    DATE_FORMAT(sale_date, '%Y-%m') = '2022-11' -- convierte la fecha en el formato que yo quiero para luego compararlo con el task que me dan 
	AND
	quantity > 3;

SELECT *	-- my solution
FROM retail_sales
WHERE category = 'Clothing'
	AND quantity > 3
	AND sale_date BETWEEN '2022-11-01' AND '2022-11-30';
    
-- Q.3 Calculate total sales (total_sale) for each category

SELECT
	category, 
    SUM(total_sale) AS net_sale,
    COUNT(*) AS number_of_sales
FROM retail_sales
GROUP BY 1
ORDER BY net_sale DESC;

-- Q.4 Find avg age of customers who purchased items from the 'Beauty' category

SELECT 
	ROUND(AVG(age), 2) AS avg_age
FROM retail_sales
WHERE category = 'Beauty';

-- Q.5 Find all transactions where (total_sale) is > 1000

SELECT *
FROM retail_sales
WHERE total_sale > 1000
ORDER BY total_sale DESC;

-- Q.6 Find total number of transactions (transaction_id) made by each gender in each category

SELECT 
    category,
    gender,
    COUNT(transactions_id) AS total_transactions
FROM retail_sales
GROUP BY 
	category, 
    gender
ORDER BY 1;

-- Q.7 Calculate avg_sale for each month. Find out best selling month each year

SELECT 
	year, 
	month, 
    avg_sale
FROM -- Subquery FROM 
	(
		SELECT
			YEAR(sale_date) AS year,
			MONTH(sale_date) AS month,
			ROUND(AVG(total_sale), 2) AS avg_sale,
			RANK() OVER(PARTITION BY YEAR(sale_date) ORDER BY ROUND(AVG(total_sale), 2) DESC) AS ranking -- Window function
			FROM retail_sales
			GROUP BY 1, 2
	) AS ranking_table
WHERE ranking = 1;

-- Q.8 Find top 5 customers based on the highest_total_sales

SELECT
	customer_id,
    SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- Q.9 Find number of unique customers who purchased items from each category

SELECT
	category,
	COUNT(DISTINCT customer_id) AS unique_customers
FROM retail_sales
GROUP BY 1
ORDER BY 2;

-- Q.10 Create each shift and number of orders (Example Morning >=12, Afternoon Between 12 & 17, Evening > 17)

WITH hourly_sale     -- CTE 
AS
(
SELECT *,
	CASE
		WHEN HOUR(sale_time) < 12 THEN 'Morning'
        WHEN HOUR(sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
	END AS shift
FROM retail_sales
)
SELECT
	shift,
	COUNT(*) AS total_orders
FROM hourly_sale
GROUP BY shift;

-- End of Project

