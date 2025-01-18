# Walmart-Sales-Analysis-Using-MySql
This project focuses on analyzing Walmart's sales data using MySQL to extract actionable insights for performance enhancement and decision-making. The project involves querying and processing a dataset to uncover trends, patterns, and statistics related to Walmart's retail operations.

https://github.com/HardikThakur04/Walmart-Sales-Analysis-Using-MySql/blob/main/walmart.image.jpg

# Retail Sales Analysis Queries

## Generic Questions

### How many unique cities does the data have?
```sql
SELECT DISTINCT city 
FROM sales;
```

### How many unique branches does the data have?
```sql
SELECT DISTINCT branch 
FROM sales;
```

### In which city is each branch?
```sql
SELECT DISTINCT city 
FROM sales 
WHERE branch IN ("A", "B", "C");
```

## Product

### How many unique product lines does the data have?
```sql
SELECT DISTINCT product_line 
FROM sales;
```

### What is the most common payment method?
```sql
SELECT payment_method, COUNT(*) 
FROM sales 
GROUP BY payment_method 
ORDER BY COUNT(*) DESC;
```

### What is the most selling product line?
```sql
SELECT product_line, COUNT(*) 
FROM sales 
GROUP BY product_line 
ORDER BY COUNT(*) DESC;
```

### What is the total revenue by month?
```sql
SELECT MONTHNAME(date) AS Month,
       ROUND(SUM(total)) AS Total_Sales 
FROM sales 
GROUP BY MONTHNAME(date) 
ORDER BY Total_Sales DESC;
```

### What month had the largest COGS?
```sql
SELECT ROUND(cogs) AS Cogs 
FROM sales 
ORDER BY cogs DESC;
```

### What product line had the largest revenue?
```sql
SELECT product_line, SUM(total) AS Total 
FROM sales 
GROUP BY product_line 
ORDER BY SUM(total) DESC;
```

### What is the city with the largest revenue?
```sql
SELECT city, ROUND(SUM(total)) AS Total
FROM sales 
GROUP BY city 
ORDER BY SUM(total) DESC;
```

### What product line had the largest VAT?
```sql
SELECT product_line, VAT 
FROM sales 
ORDER BY VAT DESC LIMIT 1;
```

### Fetch each product line and add a column showing "Good" or "Bad" (based on average sales).
```sql
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
```

### Which branch sold more products than the average product sold?
```sql
SELECT branch, SUM(quantity)
FROM sales 
GROUP BY branch
HAVING SUM(quantity) > (SELECT AVG(total_quantity) 
                        FROM (SELECT SUM(quantity) AS total_quantity 
                              FROM sales 
                              GROUP BY branch) AS avg_sold);
```

### What is the most common product line by gender?
```sql
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
```

### What is the average rating of each product line?
```sql
SELECT product_line, AVG(rating) AS Avg_Rating
FROM sales
GROUP BY product_line;
```

## Sales

### Number of sales made at each time of the day per weekday
```sql
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
```

### Which customer type brings the most revenue?
```sql
SELECT customer_type, SUM(total) AS Total
FROM sales
GROUP BY customer_type 
ORDER BY Total DESC;
```

### Which city has the largest tax percent/VAT (Value Added Tax)?
```sql
SELECT city, AVG(VAT / (total - VAT)) * 100 AS VAT
FROM sales
GROUP BY city 
ORDER BY VAT DESC;
```

### Which customer type pays the most in VAT?
```sql
SELECT customer_type, AVG(VAT / (total - VAT)) * 100 AS VAT
FROM sales
GROUP BY customer_type
ORDER BY VAT DESC;
```

## Customer

### How many unique customer types does the data have?
```sql
SELECT DISTINCT customer_type 
FROM sales;
```

### How many unique payment methods does the data have?
```sql
SELECT DISTINCT payment_method
FROM sales;
```

### What is the most common customer type?
```sql
SELECT customer_type, COUNT(*)
FROM sales
GROUP BY customer_type
ORDER BY COUNT(*) DESC LIMIT 1;
```

### Which customer type buys the most?
```sql
SELECT customer_type, SUM(total) AS Total
FROM sales
GROUP BY customer_type
ORDER BY Total DESC LIMIT 1;
```

### What is the gender of most customers?
```sql
SELECT gender, COUNT(*) 
FROM sales 
GROUP BY gender
ORDER BY COUNT(*) DESC LIMIT 1;
```

### What is the gender distribution per branch?
```sql
SELECT branch, gender, COUNT(gender)
FROM sales
GROUP BY branch, gender
ORDER BY branch, gender;
```

### Which time of the day do customers give the most ratings?
```sql
SELECT 
    CASE
        WHEN HOUR(time) BETWEEN 1 AND 11 THEN 'Morning'
        WHEN HOUR(time) BETWEEN 12 AND 17 THEN 'Afternoon'
        WHEN HOUR(time) BETWEEN 18 AND 21 THEN 'Evening'
        ELSE 'Night'
    END AS time_of_day,
    COUNT(rating)
FROM sales
GROUP BY time_of_day
ORDER BY COUNT(rating) DESC;
```

### Which time of the day do customers give the most ratings per branch?
```sql
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
```

### Which day of the week has the best average ratings?
```sql
SELECT WEEKDAY(date), AVG(rating)
FROM sales 
GROUP BY WEEKDAY(date);
```

### Which day of the week has the best average ratings per branch?
```sql
SELECT branch, DAYNAME(date) AS Weekday,
       AVG(rating) AS Rating
FROM sales
GROUP BY DAYNAME(date), branch
ORDER BY AVG(rating) DESC;





