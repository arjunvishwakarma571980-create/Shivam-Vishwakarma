SELECT * FROM walmart_python_mysql_db;
use walmart_python_mysql_db;

select * from Walmart;

drop table Walmart;

select count(*) 
from Walmart;

select 
distinct payment_method 
from Walmart;

select payment_method 
from Walmart;

select payment_method, count(*) 
from Walmart 
group by payment_method;

select count(distinct branch)
from Walmart;

select max(quantity) from Walmart;

select min(quantity) from Walmart;

-- Business Problems
-- Q1) Find different payment method and number of transactions, number of qty sold

select 
    payment_method, 
    count(*) as no_payments,
    sum(quantity) as no_qty_sold
from Walmart 
group by payment_method;

-- Q2) Identify the highest-rated category in each branch, displaying the branch, category 
-- AVG RATING

select * from Walmart;

select * from (select branch, category, Avg(rating) as `avg_rating`,
Rank() over(partition by branch order by avg(rating) desc) as `rank`
from Walmart
group by 1 , 2) as t1
where `rank` = 1;
 
-- Q3) Identify the busiest day for each branch based on the number of transactions

select * from (
select 
    branch, 
	date_format(str_to_date(date, "%d/%m/%y"), "%W") as `day_name`,
    count(*) as `no_transactions`,
    Rank() over(partition by branch order by count(*) desc) as `rank`
from Walmart
group by branch, `day_name` #/1, 2
)  AS t2
where `rank` = 1;

-- Q4) Calculated the total quantity of items sold per payment method. List payment_method and total_quantity.

select * from Walmart;
 
select payment_method, sum(quantity) as total_quantity from Walmart
group by payment_method;

-- Q5) Determine the average, minimum, and maximum rating of products for each city.
-- List the city, average_rating, and max_rating

select * from Walmart;

select city, category, min(rating) as min_rating, max(rating) as max_rating, avg(rating) as avg_rating from Walmart
group by city, category;

-- Q6) Calculate the total profit for each category by considering by considering total_profit as
-- (unit_price * quantity * profit_margin),
-- List category and total_profit, ordered from highest to lowest profit.

select * from Walmart;

select category,
     sum(total) as total_revenue,    
	 sum(total * profit_margin) as profit 
	 from Walmart
group by 1;

-- Q7) Determine the most common payment method for each branch. Display Branch and the prefered_payment_method.

select * from Walmart;

with cte as(
select 
    branch, 
    payment_method,
    count(*) as `total_trans`, 
    rank() over(partition by branch order by count(*) desc) as `rank`
from Walmart
group by 1, 2
)
select *
from cte
where `rank` = 1;

-- Q8) Categorize sales into 3 group MORNING, AFTERNOON, EVENING
-- Find out which of the shift and number of invoices

select * from Walmart;

select
    *,
    case
        When hour(time) < 12 then 'Morning'
        When hour(Time) between 12 and 17 then 'Afternoon'
        else 'Evening'
    end as day_time
from Walmart;

-- Q9) Identify 5 branch with highest decrease ratio in
-- revenue compare to last year(current year 2023 and last year 2022)

-- rdr(revenue decrease ratio) formula = lastyear_revenue - currentyear_revenue/ last_year revenue*100

select * from Walmart;

select *, 
       year(str_to_date(date, '%d/%m/%y')) as formated_date
from Walmart;

-- Top 5 branches with the highest revenue decrease ratio (2022 vs 2023)
with revenue_2022 AS (
    select 
        branch,
        sum(total) AS revenue
    from Walmart
    where year(STR_TO_DATE(date, '%d/%m/%y')) = 2022
    group by branch
),
revenue_2023 as (
    Select 
        branch,
        SUM(total) AS revenue
    from Walmart
    Where year(STR_TO_DATE(date, '%d/%m/%y')) = 2023
    Group by branch
)
Select 
    ls.branch,
    ls.revenue as last_year_revenue,
    cs.revenue as cr_year_revenue,
    -- Formula: ((Last Year - Current Year) / Last Year) * 100
    round(((ls.revenue - cs.revenue) / ls.revenue) * 100, 2) as rev_dec_ratio
from revenue_2022 as ls
join revenue_2023 as cs 
  on ls.branch = cs.branch
Where ls.revenue > cs.revenue
order by rev_dec_ratio desc 
limit 5;