use sakila;

-- Get number of monthly active customers.
select count(customer_id) as active_customers, 
	substr(rental_date, 6, 2) as activity_month,
    substr(rental_date, 1, 4) as activity_year
from rental
group by activity_year, activity_month;

-- Active users in the previous month
-- 1 
create or replace view sakila.user_activity as
select count(distinct customer_id) as active_customers, 
	substr(rental_date, 6, 2) as activity_month,
    substr(rental_date, 1, 4) as activity_year
from rental
group by activity_year, activity_month;

-- 2
select activity_year, activity_month, active_customers,
lag(active_customers) over (order by activity_year, activity_month) as last_month
from user_activity;

-- 3
create or replace view sakila.diff_monthly_customers as
with cte_view as
(
	select activity_year, activity_month, active_customers,
	lag(active_customers) over (order by activity_year, activity_month) as last_month
	from user_activity
)
select activity_year, activity_month, active_customers, last_month,
	(active_customers - last_month) as difference
from cte_view;

select * from diff_monthly_customers;


-- Percentage change in the number of active customers.
create or replace view sakila.percentage_change as
with cte_view as
(
	select * from sakila.diff_monthly_customers
)
select activity_year, activity_month, active_customers, last_month, difference,
	round((difference / last_month) * 100, 2) + '%' as percentage
from cte_view;

select * from sakila.percentage_change;

-- Retained customers every month.
create or replace view sakila.churn_rate as
with cte_view as
(
	select * from sakila.percentage_change
)
select activity_year, activity_month, active_customers, last_month, difference, percentage,
	round((difference / last_month) * 100, 2) as CRR
from cte_view;

select * from sakila.churn_rate;





