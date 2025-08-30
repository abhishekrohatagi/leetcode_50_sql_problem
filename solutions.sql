select
product_id 
from products
where low_fats = 'Y' and recyclable = 'Y';


select
name
from Customer
where referee_id is null or referee_id != 2;


select
name,
population,
area
from World
where area >= 3000000 or population >= 25000000;




with cte_1 as(select 
author_id as id
from views
where author_id = viewer_id)

select 
distinct id 
from cte_1 
order by id asc;





select
tweet_id
from Tweets
where len(content) > 15;





select
u.unique_id,
e.name
from Employees as e
left join EmployeeUNI as u 
on e.id = u.id




	
select
p.product_name,
s.year,
s.price
from Sales as s
inner join Product as p
on s.product_id = p.product_id




	

select
v.customer_id as customer_id,
count(*) as count_no_trans
from visits as v
left join Transactions as t
on v.visit_id = t.visit_id
where t.visit_id is null
group by v.customer_id;






WITH cte AS (
    SELECT
        id,
        recordDate,
        temperature,
        LAG(recordDate)     OVER (ORDER BY recordDate) AS prev_date,
        LAG(temperature)    OVER (ORDER BY recordDate) AS prev_temp
    FROM Weather
)
SELECT
    id
FROM cte
WHERE
    DATEDIFF(day, prev_date, recordDate) = 1        
    AND prev_temp < temperature; 







select
e.name,
b.bonus
from Employee as e
left join Bonus as b
on e.empID = b.empID 
where b.bonus < 1000 or b.bonus is null;







WITH cte_1 AS (
    SELECT 
        student_id,
        student_name
    FROM students
)
SELECT 
    c.student_id,
    c.student_name,
    s.subject_name,
    COUNT(e.student_id) AS attended_exams
FROM cte_1 AS c
CROSS JOIN subjects AS s
LEFT JOIN Examinations AS e
    ON c.student_id = e.student_id 
   AND s.subject_name = e.subject_name
GROUP BY c.student_id, c.student_name, s.subject_name
ORDER BY c.student_id, c.student_name;








SELECT m.name
FROM Employee m
JOIN Employee e
    ON e.managerId = m.id
	GROUP BY m.id, m.name
HAVING COUNT(m.id) >= 5;






with cte_1 as
  (select 
s.user_id,
  c.action from Signups as s 
  left join Confirmations as c 
  on s.user_id = c.user_id) 
  select user_id,
  cast(cast (count(case when action = 'confirmed' then 1 end) as decimal (10,2))/ cast(count(user_id) as decimal(10,2)) as decimal(10,2)) as confirmation_rate
  from cte_1 
  group by user_id 
  order by confirmation_rate;






select 
*
from
Cinema
where id%2 !=0 and description != 'boring'
order by rating desc;




WITH PriceRanked AS (
    SELECT 
        product_id,
        start_date,
        end_date,
        price,
        ROW_NUMBER() OVER (
            PARTITION BY product_id, start_date, end_date 
            ORDER BY price ASC
        ) AS rn
    FROM Prices
)
SELECT
    p.product_id,
    ROUND(
        COALESCE(SUM(s.units * p.price) * 1.0 / NULLIF(SUM(s.units),0), 0),
        2
    ) AS average_price
FROM PriceRanked p
LEFT JOIN UnitsSold s
    ON s.product_id = p.product_id
   AND s.purchase_date BETWEEN p.start_date AND p.end_date
WHERE p.rn = 1  
GROUP BY p.product_id;






select
p.project_id,
round(sum(e.experience_years)*1.0/count(e.employee_id)*1.0,2) as average_years
from project as p
join Employee as e
on p.employee_id = e.employee_id
group by p.project_id;



SELECT
contest_id,
CAST(COUNT(DISTINCT user_id) * 1.0 / (SELECT COUNT(user_id) FROM Users) * 100 AS DECIMAL(10,2)) AS percentage
FROM Register
GROUP BY contest_id
order by percentage desc, contest_id asc;



select
query_name,
cast(avg(rating*1.0/position*1.0) as decimal (10,2)) as quality,
cast((count(case when rating < 3 then 1 end)*1.0/count(*)*1.0)*100 as decimal (10,2)) as poor_query_percentage
from Queries
group by query_name;




WITH Transformed AS (
    SELECT
        CAST(YEAR(trans_date) AS VARCHAR) + '-' + RIGHT('0' + CAST(MONTH(trans_date) AS VARCHAR), 2) AS month,
        country,
        amount,
        state
    FROM Transactions
)
SELECT
    month,
    country,
    COUNT(*) AS trans_count,
    SUM(CASE WHEN state = 'approved' THEN 1 ELSE 0 END) AS approved_count,
    SUM(amount) AS trans_total_amount,
    SUM(CASE WHEN state = 'approved' THEN amount ELSE 0 END) AS approved_total_amount
FROM Transformed
GROUP BY month, country
ORDER BY month, country;





with cte_1 as(
select
*,
(case when (order_date = customer_pref_delivery_date) then 'Immediate' else 'scheduled' end) as status,
RANK() over(partition by customer_id order by order_date) as rn
from Delivery),

cte_2 as(
select
*
from cte_1
where rn = 1
)
select 
cast(count(case when status = 'Immediate' then 1 end)*1.0/count(*)*100 as decimal(10,2)) as immediate_percentage
from cte_2;






WITH cte AS (
    SELECT 
        player_id,
        event_date,
        DATEDIFF(
            day, 
            LAG(event_date) OVER (PARTITION BY player_id ORDER BY event_date), 
            event_date
        ) AS days_diff,
        ROW_NUMBER() OVER (PARTITION BY player_id ORDER BY event_date) AS rn
    FROM Activity
)
SELECT 
    CAST(SUM(CASE WHEN days_diff = 1 AND rn = 2 THEN 1 ELSE 0 END) * 1.0 
         / COUNT(DISTINCT player_id) AS DECIMAL(10,2)) AS fraction
FROM cte;




select
teacher_id,
count(distinct subject_id) as cnt
from Teacher
group by teacher_id;



select 
activity_date as day,
count(distinct user_id) as active_users
from Activity
where activity_date between '2019-06-28' and '2019-07-27'
group by activity_date;



with cte_1 as (select
product_id,
year,
quantity,
price,
min(year) over(partition by product_id) as min_year
from Sales)

select
product_id,
year as first_year,
quantity,
price
from cte_1
where year=min_year;




select
class
from courses
group by Class
having count(distinct student) >=5;



select
user_id,
count(follower_id) as followers_count
from Followers
group by user_id;



select coalesce(
    (
        select  top 1 num
        from MyNumbers
        group by num
        having count(num) = 1
        order by num desc
        
    ), null
) as num;




select
customer_id
from customer
group by customer_id
having count(distinct product_key) = (select count(product_key) from Product)




with cte_1 as (
    select
        reports_to,
        count(reports_to) as reports_count,
        floor(cast(avg(cast(age as decimal(10,2))) as decimal(10,2)) + 0.5) as average_age
    from Employees
    where reports_to is not null
    group by reports_to
)
select
    e.employee_id,
    e.name,
    c.reports_count,
    c.average_age
from Employees as e
inner join cte_1 as c
    on c.reports_to = e.employee_id;




select
employee_id,
department_id
from Employee 
where Employee_id not in(select Employee_id from Employee where primary_flag = 'Y')
union all
 select 
 Employee_id,
 Department_id
 from Employee 
 where primary_flag = 'Y'




select
x,
y,
z,
case 
    when ((x+y)>z and (x+z) > y and (y+z)>x) then 'Yes'
    else 'No'
end as triangle
from Triangle;
    



with cte_1 as
(
select
id,
num,
lag(num, 1) over (order by id) AS prev1,
lag(num, 2) over (order by id) AS prev2
from Logs
)
select
distinct num as ConsecutiveNums
from cte_1
where num = prev1 and num = prev2;



with cte_1 as(select
product_id,
new_price as price,
change_date,
max(change_date) over(partition by product_id) as max_date
from Products
where change_date < = '2019-08-16')

select
product_id,
price
from cte_1
where change_date = max_date

union all

select
distinct product_id,
10
from Products
where product_id not in (select distinct product_id from products where change_date < = '2019-08-16');





with cte_1 as(select
turn,
person_id,
person_name,
weight,
sum(weight) over(order by turn) as total_weight
from Queue)

select top 1 person_name from cte_1
where total_weight <= 1000
order by total_weight desc;




with cte_1 as(select
*,
case
     when income > 50000 then 'High Salary'
	 when income >= 20000 and income <=50000 then 'Average Salary'
	 else 'Low Salary'
end as category
from Accounts),

cte_2 as (
    select 'High Salary' AS category
    union all
    select 'Average Salary'
    union all
    select 'Low Salary')

select
c2.category,
count(c1.account_id) as accounts_count
from cte_2 as c2
left join cte_1 as c1
on c2.category = c1.category
group by c2.category;



select
employee_id
from Employees
where salary < 30000
and manager_id is not null
and manager_id not in (select employee_id from Employees)
order by employee_id asc;



WITH cte AS (
    SELECT
        r.movie_id,
        m.title,
        r.user_id,
        u.name,
        r.rating,
        r.created_at
    FROM MovieRating AS r
    JOIN Movies AS m
        ON r.movie_id = m.movie_id
    JOIN Users AS u
        ON r.user_id = u.user_id
),
cte_1 AS (
    SELECT 
        user_id,
        name,
        COUNT(user_id) AS cn
    FROM cte
    GROUP BY user_id, name
),
cte_2 AS (
    SELECT
        movie_id,
        title,
        sum(rating)*1.0/count(*)*1.0 AS avg_rating
    FROM cte
    where created_at between '2020-02-01' and '2020-02-29'
    GROUP BY movie_id, title
),
top_user AS (
    SELECT TOP 1 name AS results
    FROM cte_1
    ORDER BY cn DESC, name ASC
),
top_movie AS (
    SELECT TOP 1 title AS results
    FROM cte_2
    ORDER BY avg_rating DESC, title ASC
)
SELECT * FROM top_user
UNION ALL
SELECT * FROM top_movie;





with cte_1 as(
select 
visited_on,
sum(amount) as amount
from Customer
group by visited_on),

cte_2 as (select 
visited_on,
sum(amount) over(order by visited_on ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as amount,
cast(avg(amount*1.0) over(order by visited_on  ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as decimal(10,2)) as average_amount,
ROW_NUMBER() over(order by visited_on) as rn
from cte_1)

select visited_on, amount, average_amount from cte_2 where rn >= 7;





with cte_1 as(select
requester_id,
count(*) as rcn
from RequestAccepted
group by requester_id),

cte_2 as(select
accepter_id,
count(*) as acn
from RequestAccepted
group by accepter_id)

select top 1
case when requester_id is null then accepter_id else requester_id end as id,
(coalesce(rcn,0) +coalesce(acn,0)) as num
from cte_1 as c1
full outer join cte_2 as c2
on c1.requester_id = c2.accepter_id
order by num desc;





WITH duplicate_tiv AS (
    -- Step 1: tiv_2015 values that appear more than once
    SELECT tiv_2015
    FROM Insurance
    GROUP BY tiv_2015
    HAVING COUNT(*) > 1
),
unique_location AS (
    -- Step 2: unique (lat, lon) pairs
    SELECT lat, lon
    FROM Insurance
    GROUP BY lat, lon
    HAVING COUNT(*) = 1
)
SELECT 
    CAST(SUM(tiv_2016) AS DECIMAL(10,2)) AS tiv_2016
FROM Insurance i
JOIN duplicate_tiv d
    ON i.tiv_2015 = d.tiv_2015
JOIN unique_location u
    ON i.lat = u.lat AND i.lon = u.lon;




with cte as(select
d.name as Department,
e.name as Employee,
e.salary as Salary,
dense_rank() over(partition by d.name order by e.salary desc) as rn
from Employee as e
join Department as d
on e.departmentId = d.id)

select
Department,
Employee,
Salary
from cte
where rn < = 3;





select
user_id,
upper(left(name,1))+lower(substring(name,2,len(name))) as name
from Users 
order by user_id;



select *
from Patients
where conditions like '% DIAB1%'   
   or conditions like 'DIAB1%' ;




select
case when count(distinct salary) < 2 then null
else
(
select max(salary)
from Employee
where salary < (select max(salary) from Employee)
)
end as SecondHighestSalary
from Employee;



with cte as(
select distinct
sell_date,
product
from Activities
)

select
sell_date,
count(product) as num_sold,
string_agg(product, ',') as products
from cte
group by sell_date;





select
p.product_name,
sum(o.unit) as unit
from Orders as o
join Products as p
on o.product_id = p.product_id
where order_date between '2020-02-01' and '2020-02-29'
group by p.product_name
having sum(o.unit) >=100;



SELECT user_id, name, mail
FROM Users
WHERE mail  LIKE '[A-Za-z]%'
  AND mail COLLATE SQL_Latin1_General_CP1_CS_AS LIKE '%@leetcode.com'
  AND LEFT(mail, LEN(mail) - LEN('@leetcode.com'))  NOT LIKE '%[^A-Za-z0-9._-]%';










