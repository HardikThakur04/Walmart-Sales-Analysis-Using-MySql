create database if not exists walmartsales;

use walmartsales;

CREATE TABLE sales (
    invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(10) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    VAT FLOAT(6,4) NOT NULL,
    total DECIMAL(10,2) NOT NULL,
    date DATE NOT NULL,
    time TIME NOT NULL, -- Changed from TIMESTAMP to TIME, as it seems intended for time of day
    payment_method VARCHAR(30) NOT NULL, -- Changed from DECIMAL to VARCHAR for payment method
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_percentage FLOAT(5,2) NOT NULL, -- Adjusted to reflect realistic margin percentages
    gross_income DECIMAL(10,2) NOT NULL,
    rating FLOAT(3,1) NOT NULL -- Adjusted size for realistic rating values (e.g., 1.0 to 9.9)
);

drop table sales;

select * from sales;

####Generic Question
#How many unique cities does the data have?
select distinct city 
from sales;

select distinct branch 
from sales;

#In which city is each branch?
select distinct city 
from sales 
where branch in ("A","B","C");

####Product
#How many unique product_lines does the data have?
select distinct product_line 
from sales;

#What is the most common payment method?
select payment_method, count(*) 
from sales 
group by payment_method 
order by count(*) desc;

#What is the most selling product line?
select Product_line, count(*) 
from sales 
group by product_line 
order by count(*) desc;

#What is the total revenue by month?
select monthname(date) as Month,
round(sum(total)) as Total_Sales from sales 
group by monthname(date) 
order by Total_Sales desc;

#What month had the largest COGS?
select round(cogs) as Cogs 
from sales 
order by cogs desc;

#What product line had the largest revenue?
select Product_line, sum(total) as Total 
from sales 
group by product_line 
order by sum(total) desc;

#What is the city with the largest revenue?

select City, round(sum(total)) as Total
from sales 
group by city 
order by sum(total) desc;

#What product line had the largest VAT?
select product_line,VAT 
from sales 
order by VAT desc Limit 1;

select * from sales;

#Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales
SELECT 
    product_line,
    SUM(quantity) AS total_sales,
    CASE 
        WHEN SUM(quantity) > (SELECT AVG(total_quantity) FROM (SELECT SUM(quantity) AS total_quantity FROM sales GROUP BY product_line) AS avg_sales)
        THEN 'Good'
        ELSE 'Bad'
    END AS performance
FROM sales
GROUP BY product_line;

#Which branch sold more products than average product sold?
select branch,sum(quantity)
from sales 
group by branch
having sum(quantity) >(SELECT AVG(total_quantity) 
                        FROM (SELECT SUM(quantity) AS total_quantity 
                              FROM sales 
                              GROUP BY branch) AS avg_sold);

#What is the most common product line by gender?
select product_line,count(gender) from sales group by product_line;

SELECT gender, product_line, COUNT(*) AS count
FROM sales
GROUP BY gender, product_line
HAVING COUNT(*) = (
    SELECT MAX(product_count)
    FROM (
        SELECT gender AS g, product_line AS p, COUNT(*) AS product_count
        FROM sales
        GROUP BY gender, product_line
    ) AS subquery
    WHERE subquery.g = sales.gender
);

#What is the average rating of each product line?
select product_line,avg(rating) as Avg_Rating
from sales
group by product_line;


####Sales
#Number of sales made in each time of the day per weekday
select weekday(date),count(*) from sales group by weekday(date);

SELECT 
    WEEKDAY(date) AS weekday,
    CASE
        WHEN HOUR(time) BETWEEN 0 AND 5 THEN 'Late Night'
        WHEN HOUR(time) BETWEEN 6 AND 11 THEN 'Morning'
        WHEN HOUR(time) BETWEEN 12 AND 17 THEN 'Afternoon'
        WHEN HOUR(time) BETWEEN 18 AND 23 THEN 'Evening'
    END AS time_of_day,
    COUNT(*) AS sales_count
FROM sales
GROUP BY WEEKDAY(date), time_of_day
ORDER BY weekday, FIELD(time_of_day, 'Late Night', 'Morning', 'Afternoon', 'Evening');

#Which of the customer types brings the most revenue?
select * from sales;

select customer_type,sum(total) as Total
from sales
group by customer_type order by Total desc;

#Which city has the largest tax percent/ VAT (Value Added Tax)?
select city, AVG(VAT / (total - VAT)) * 100 as VAT
from sales
group by city 
order by VAT desc;

#Which customer type pays the most in VAT?
select customer_type, AVG(VAT / (total - VAT)) * 100 as VAT
from sales
group by customer_type
order by VAT desc;

####Customer
#How many unique customer types does the data have?
select distinct customer_type 
from sales;

#How many unique payment methods does the data have?
select distinct payment_method
from sales;

#What is the most common customer type?
select customer_type,count(*)
from sales
group by customer_type
order by count(*) desc limit 1;

#Which customer type buys the most?
select customer_type,sum(total) as Total
from sales
group by customer_type
order by total desc limit 1;

#What is the gender of most of the customers?
select gender, count(*) 
from sales 
group by gender
order by count(*) desc limit 1;

#What is the gender distribution per branch?
select branch, gender,count(gender)
from sales
group by branch,gender
order by branch,gender;

#Which time of the day do customers give most ratings?

select 
case
when hour(time) between 1 and 11 then "morining"
when hour(time) between 12 and 17 then "afternoon"
when hour(time) between 18 and 21 then "evening"
else "night"
end as Time_of_day,
count(rating)
from sales
group by Time_of_day
order by count(rating) desc;

#Which time of the day do customers give most ratings per branch?
select branch,time,count(*) 
from sales
group by time;

SELECT 
    branch,
    CASE 
        WHEN HOUR(time) BETWEEN 6 AND 11 THEN 'Morning'
        WHEN HOUR(time) BETWEEN 12 AND 17 THEN 'Afternoon'
        WHEN HOUR(time) BETWEEN 18 AND 21 THEN 'Evening'
        ELSE 'Night'
    END AS time_of_day,
    COUNT(*) AS rating_count
FROM sales
GROUP BY branch, time_of_day
ORDER BY branch, rating_count DESC;

#Which day fo the week has the best avg ratings?
select weekday(date),avg(rating)
from sales 
group by weekday(date);


#Which day of the week has the best average ratings per branch?
select branch,dayname(date) as Weekday,
avg(rating) as Rating
from sales
group by dayname(date),branch
order by avg(rating) desc;
