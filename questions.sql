

-- What day of the week is used for each week_date value?
SELECT week_date,to_char(week_date,'Day') as weekday from actual_sales;

-- What range of week numbers are missing from the dataset?
with cte as(
    SELECT generate_series(1,52) as weeks
)
SELECT cte.weeks from cte left join actual_sales a on cte.weeks=a.week_number
WHERE a.week_number IS NULL;

-- How many total transactions were there for each year in the dataset?
SELECT calender_year,sum(transactions) as total
from actual_sales GROUP BY calender_year ORDER BY calender_year;

-- What is the total sales for each region for each month?
SELECT region,month_number,sum(sales) as total_sales
from actual_sales GROUP BY region,month_number ORDER BY region,month_number;

-- What is the total count of transactions for each platform
SELECT platform,sum(transactions)
from actual_sales GROUP BY platform ORDER BY platform;

-- What is the percentage of sales for Retail vs Shopify for each month?
SELECT month_number,
round(sum(case when platform='Retail' then sales else 0 end)/sum(sales) * 100,2) as retail_sales,
round(sum(case when platform='Shopify' then sales else 0 end)/sum(sales) * 100,2) as shopify_sales
from actual_sales GROUP BY month_number ORDER BY month_number;

-- What is the percentage of sales by demographic for each year in the dataset?
SELECT calender_year,
round(sum(case when demographic='Families' then sales else 0 end)/sum(sales) * 100,2) as family_sales,
round(sum(case when demographic='Couples' then sales else 0 end)/sum(sales) * 100,2) as couples_sales,
round(sum(case when demographic='unknown' then sales else 0 end)/sum(sales) * 100,2) as unknown_sales
from actual_sales GROUP BY calender_year ORDER BY calender_year;


-- Which age_band and demographic values contribute the most to Retail sales?
select age_band,demographic
from actual_sales WHERE platform='Retail' ORDER BY sales DESC LIMIT 1;

-- Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?
SELECT calender_year,platform,
round(sum(sales)/sum(transactions),0) as avg_transection_size
from actual_sales GROUP BY calender_year,platform ORDER BY calender_year,platform;

with cte as(
    SELECT 
sum(case when week_number BETWEEN 21 and 24
then sales else 0 end) as before_sales,
sum(case when week_number BETWEEN 25 and 28
then sales else 0 end) as after_sales
from actual_sales WHERE calender_year=2020
)
SELECT after_sales-before_sales as diff,round((after_sales-before_sales)/before_sales::NUMERIC * 100,2)
as percent_diff
from cte;

-- what abour entire 12 weeks before and after?
with cte as(
    SELECT 
sum(case when week_number BETWEEN 13 and 24
then sales else 0 end) as before_sales,
sum(case when week_number BETWEEN 25 and 36
then sales else 0 end) as after_sales
from actual_sales WHERE calender_year=2020
)
SELECT after_sales-before_sales as diff,round((after_sales-before_sales)/before_sales::NUMERIC * 100,2)
as percent_diff
from cte;

-- 12 weeks before and after for each year?
with cte as(
    SELECT calender_year,
sum(case when week_number BETWEEN 13 and 24
then sales else 0 end) as before_sales,
sum(case when week_number BETWEEN 25 and 36
then sales else 0 end) as after_sales
from actual_sales GROUP BY calender_year
)
SELECT calender_year,after_sales-before_sales as diff,round((after_sales-before_sales)/before_sales::NUMERIC * 100,2)
as percent_diff
from cte;

-- what is 4 weeks bofre and after for each year?
with cte as(
    SELECT calender_year,
sum(case when week_number BETWEEN 21 and 24
then sales else 0 end) as before_sales,
sum(case when week_number BETWEEN 25 and 28
then sales else 0 end) as after_sales
from actual_sales GROUP BY calender_year
)
SELECT calender_year,after_sales-before_sales as diff,round((after_sales-before_sales)/before_sales::NUMERIC * 100,2)
as percent_diff
from cte;


-- which areas of business have hihest negative impact on 2020 before and after 12 weeks pg_get_serial_sequence
with cte as(
SELECT region,platform,age_band,demographic,customer_type,
sum(case when week_number BETWEEN 13 and 24
then sales else 0 end) as before_sales,
sum(case when week_number BETWEEN 25 and 36
then sales else 0 end) as after_sales
from actual_sales WHERE calender_year=2020
GROUP BY region,platform,age_band,demographic,customer_type
)
SELECT region,platform,age_band,demographic,customer_type,after_sales-before_sales as diff,round((after_sales-before_sales)/before_sales::NUMERIC * 100,2)
as percent_diff
from cte ORDER BY percent_diff LIMIT 5;