SELECT * FROM swiggy_data;


--Data Validation and Cleaning
--Null Check

SELECT 

SUM(CASE WHEN State IS NULL THEN 1 ELSE 0 END) AS null_state,
SUM(CASE WHEN City IS NULL THEN 1 ELSE 0 END) AS null_city,
SUM(CASE WHEN Order_Date IS NULL THEN 1 ELSE 0 END) AS null_order_date,
SUM(CASE WHEN Restaurant_Name IS NULL THEN 1 ELSE 0 END) AS null_restaurant_name,
SUM (CASE WHEN Location IS NULL THEN 1 ELSE 0 END) AS null_location,
SUM(CASE WHEN Category IS NULL THEN 1 ELSE 0 END) AS null_category,
SUM (CASE WHEN Dish_Name IS NULL THEN 1 ELSE 0 END) AS null_dish,
SUM(CASE WHEN Price_INR IS NULL THEN 1 ELSE 0 END) AS null_price,
SUM(CASE WHEN Rating IS NULL THEN 1 ELSE 0 END) AS null_rating,
SUM(CASE WHEN Rating_Count IS NULL THEN 1 ELSE 0 END) AS null_rating_count
FROM swiggy_data;



--Blank or Empty Strings
--Here we took only non-numeric columns or field as numeric filed like rating 
-- where rating are zero can give misleading results.

SELECT * FROM swiggy_data
WHERE 
State ='' OR City = '' OR Restaurant_Name ='' OR Location =''
OR Category ='' OR Dish_Name ='';

-- Duplicate Detection

SELECT 
State, City, Order_Date, Restaurant_Name, Location, Category, Dish_Name, Price_INR, Rating, Rating_Count,
COUNT(*) AS CNT
FROM swiggy_data
GROUP BY 
State, City, Order_Date, Restaurant_Name, Location, Category, Dish_Name, Price_INR, Rating, Rating_Count
HAVING COUNT(*)>1;

-- Delete Duplication

WITH CTE AS (
SELECT *, ROW_NUMBER() Over(
   PARTITION BY State, City, Order_Date, Restaurant_Name, Location, Category, Dish_Name, Price_INR, Rating, Rating_Count
ORDER BY (SELECT NULL)
) AS rn
FROM swiggy_data
) 
DELETE FROM CTE WHERE rn>1;

-- CREATING SCHEMA
--DIMENSION TABLES
-- DATE TABLE

/*CREATE TABLE dim_date(
date_id INT IDENTITY(1,1) PRIMARY KEY,
Full_date DATE,
Year INT NOT NULL,
Month INT NOT NULL,
Month_Name VARCHAR(20),
Quarter INT NOT NULL,
Day INT NOT NULL,
Week INT NOT NULL
); */

SELECT * FROM dim_date;


-- LOCATION TABLE


/*CREATE TABLE dim_location(
Location_id INT IDENTITY (1,1) PRIMARY KEY,
State VARCHAR(100),
City VARCHAR(100),
Location VARCHAR(200)
);*/

SELECT * FROM dim_location;


--RESTAURANT TABLE


/*CREATE TABLE dim_restaurant(
Restaurant_id INT IDENTITY(1,1) PRIMARY KEY,
Restaurant_name varchar(200)
);*/

SELECT * FROM dim_restaurant;

--CATEGORY TABLE

/*CREATE TABLE dim_category(
category_id INT IDENTITY(1,1) PRIMARY KEY,
Category VARCHAR(200)
);*/

SELECT * FROM dim_category;

--DISH TABLE

/*CREATE TABLE dim_dish(
Dish_id INT IDENTITY(1,1) PRIMARY KEY, 
Dish VARCHAR(200)
);*/

SELECT * FROM dim_dish;


--FACT TABLE

/*CREATE TABLE fact_swiggy_orders(
order_id INT IDENTITY (1,1) PRIMARY KEY,

date_id INT,
Price_INR DECIMAL(10,2),   --FACTS
Rating DECIMAL (4,2),      --FACTS   
Rating_Count INT,          --FACTS

Location_id INT,
Restaurant_id INT,
category_id INT,
Dish_id INT,

FOREIGN KEY (date_id) REFERENCES dim_date(date_id),
FOREIGN KEY (Location_id) REFERENCES dim_location(Location_id),
FOREIGN KEY (Restaurant_id) REFERENCES dim_restaurant(Restaurant_id),
FOREIGN KEY (category_id) REFERENCES dim_category(category_id),
FOREIGN KEY (Dish_id) REFERENCES dim_dish(Dish_id)
ON DELETE CASCADE
ON UPDATE CASCADE

);*/

SELECT * FROM fact_swiggy_orders;


--INSERT DATA IN TABLES

-- dim_date

INSERT INTO dim_date(Full_date, Year, Month, Month_Name, Quarter, Day, Week)
SELECT DISTINCT 
Order_Date,
YEAR(Order_Date),
MONTH(Order_Date),
DATENAME(MONTH, Order_Date),
DATEPART(QUARTER, Order_Date),
DAY(Order_Date),
DATEPART(WEEK, Order_Date)
FROM swiggy_data
WHERE Order_Date is NOT NULL;

SELECT * FROM dim_date;


--dim_location
INSERT INTO dim_location(State, City, Location)
SELECT DISTINCT
State,
City,
Location
FROM swiggy_data;

SELECT * FROM dim_location;

--dim_restaurant

INSERT INTO dim_restaurant (Restaurant_name)
SELECT DISTINCT
Restaurant_name
FROM swiggy_data;

SELECT * FROM dim_restaurant;

--dim_category

INSERT INTO dim_category(Category)
SELECT DISTINCT
Category 
FROM swiggy_data;

SELECT * FROM dim_category;

--dim_dish

INSERT INTO dim_dish (Dish)
SELECT DISTINCT
Dish_Name
FROM swiggy_data;

SELECT * FROM dim_dish;

--Fact Table

INSERT INTO fact_swiggy_orders(

date_id,
Price_INR,
Rating, 
Rating_Count,

Location_id,
Restaurant_id,
category_id,
Dish_id
)

SELECT 
dd.date_id,
s.Price_INR,
s.Rating,
s.Rating_Count,

dl.Location_id,
dr.Restaurant_id,
dc.category_id,
dsh.dish_id
FROM swiggy_data as s

JOIN dim_date as dd
ON dd.Full_date = s.Order_Date

JOIN dim_location as dl
ON dl.State = s.State AND dl.City = s.City AND dl.Location = s.Location

JOIN dim_restaurant as dr
ON dr.Restaurant_name = s.Restaurant_Name

JOIN dim_category as dc
ON dc.Category = s.Category

JOIN dim_dish as dsh
ON dsh.Dish = s.Dish_Name;

SELECT * FROM fact_swiggy_orders;


SELECT * FROM fact_swiggy_orders as f
INNER JOIN dim_date d ON f.date_id = d.date_id
INNER JOIN dim_location l ON f.location_id = l.location_id
INNER JOIN dim_restaurant r ON f.restaurant_id = r.restaurant_id
INNER JOIN dim_category c ON f.category_id = c.category_id
INNER JOIN dim_dish di ON f.dish_id = di.dish_id;


--KPI

-- TOTAL ORDERS

SELECT COUNT(*) as Total_orders FROM fact_swiggy_orders;

-- TOTAL REVENUE IN INR

SELECT 
FORMAT(SUM(CONVERT(FLOAT,Price_INR))/1000000,'N2') + 'INR Million' 
as Total_Revenue 
FROM fact_swiggy_orders;

-- AVERAGE DISH PRICE

SELECT 
FORMAT(AVG(CONVERT(FLOAT,Price_INR)),'N2') +'INR'
as Average_Dish_Price FROM fact_swiggy_orders;

--AVERAGE RATING

SELECT AVG(Rating) AS Average_Rating FROM fact_swiggy_orders;

-- DEEP DIVE BUSINESS ANALYSIS

--MONTHLY ORDER TRENDS

SELECT 
d.year,
d.month,
d.month_name,
count(*) as Total_orders
FROM fact_swiggy_orders as f
JOIN dim_date as d ON f.date_id = d.date_id
GROUP BY d.year, d.month, d.month_name;

--QUARTERLY ORDER TRENDS
SELECT 
d.year,
d.Quarter,
count(*) as Total_orders
FROM fact_swiggy_orders as f
JOIN dim_date as d ON f.date_id = d.date_id
GROUP BY d.year, d.Quarter;



--YEARLY ORDER TRENDS

SELECT 
d.year,
count(*) as Total_orders
FROM fact_swiggy_orders as f
JOIN dim_date as d ON f.date_id = d.date_id
GROUP BY d.year;

--DAY OF WEEK PATTERNS

SELECT 
DATENAME (WEEKDAY, d.full_date) AS day_name,
COUNT(*) AS Total_orders
FROM fact_swiggy_orders as f
JOIN dim_date as d ON f.date_id = d.date_id
GROUP BY DATENAME (WEEKDAY , d.full_date), DATEPART(WEEKDAY, d.full_date)
ORDER BY DATEPART (WEEKDAY, d.full_Date);

--LOCATION BASE ANALYSIS - TOP 10 CITIES

SELECT TOP 10
l.City,
COUNT(*) AS Total_orders 
FROM fact_swiggy_orders f 
INNER JOIN dim_location as l 
ON l.location_id = f.location_id
GROUP BY l.City
ORDER BY COUNT(*) DESC;



--BOTTOM 10


SELECT TOP 10
l.City,
SUM(f.Price_INR) AS Total_Revenue
FROM fact_swiggy_orders f 
INNER JOIN dim_location as l 
ON l.location_id = f.location_id
GROUP BY l.City
ORDER BY SUM(f.Price_INR) ASC;



-- REVENUE CONTRIBUTION BY STATES

SELECT 
l.State,
SUM(f.Price_INR) AS Total_Revenue
FROM fact_swiggy_orders f 
INNER JOIN dim_location as l 
ON l.location_id = f.location_id
GROUP BY l.State
ORDER BY SUM(f.Price_INR) DESC;


-- TOP 10 RESTAURANT BY ORDERS

SELECT TOP 10
r.restaurant_name,
SUM(f.order_id) AS Total_orders
FROM fact_swiggy_orders f 
INNER JOIN dim_restaurant as r
ON r.restaurant_id = f.restaurant_id
GROUP BY r.restaurant_name
ORDER BY SUM(f.Price_INR) DESC;


-- TOP CATEGORIES

SELECT 
c.category,
COUNT(*) AS Total_category
FROM fact_swiggy_orders f 
INNER JOIN dim_category as c
ON c.category_id = f.category_id
GROUP BY c.category
ORDER BY Total_category DESC;

-- MOST ORDERES DISH
SELECT
d.dish,
COUNT(*) AS order_count
FROM fact_swiggy_orders as f
INNER JOIN dim_dish d ON f.dish_id = d.dish_id
GROUP BY d.dish
ORDER BY order_count DESC;


--CUISINE PERFORMANCE

SELECT c.category,
COUNT(*) AS total_orders,
AVG(CONVERT(FLOAT, f.rating)) AS avg_rating
FROM fact_swiggy_orders as f
INNER JOIN dim_category as c ON f.category_id = c.category_id
GROUP BY c.category
ORDER BY total_orders DESC;