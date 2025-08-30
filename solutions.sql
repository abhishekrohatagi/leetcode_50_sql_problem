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
group by c2.category;;



select
employee_id
from Employees
where salary < 30000
and manager_id is not null
and manager_id not in (select employee_id from Employees)
order by employee_id asc;



ITH cte AS (
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

select visited_on, amount, average_amount from cte_2 where rn >= 7





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
   or conditions like 'DIAB1%'  




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
having sum(o.unit) >=100



SELECT user_id, name, mail
FROM Users
WHERE mail  LIKE '[A-Za-z]%'
  AND mail COLLATE SQL_Latin1_General_CP1_CS_AS LIKE '%@leetcode.com'
  AND LEFT(mail, LEN(mail) - LEN('@leetcode.com'))  NOT LIKE '%[^A-Za-z0-9._-]%';

















#### `01_products_recyclable.sql`
```sql
-- Problem: Find products that are both low fat and recyclable
-- Source: https://leetcode.com/problems/recyclable-and-low-fat-products/

SELECT
    product_id 
FROM Products
WHERE low_fats = 'Y'
  AND recyclable = 'Y';
````

#### `02_customer_referee.sql`

```sql
-- Problem: Find customers not referred by customer 2
-- Source: https://leetcode.com/problems/find-customer-referee/

SELECT
    name
FROM Customer
WHERE referee_id IS NULL
   OR referee_id != 2;
```

#### `03_big_countries.sql`

```sql
-- Problem: Find countries with large area or population
-- Source: https://leetcode.com/problems/big-countries/

SELECT
    name,
    population,
    area
FROM World
WHERE area >= 3000000
   OR population >= 25000000;
```

#### `04_author_viewer.sql`

```sql
-- Problem: Find authors who viewed their own articles
-- Source: https://leetcode.com/problems/article-views-i/

WITH cte AS (
    SELECT author_id AS id
    FROM Views
    WHERE author_id = viewer_id
)
SELECT DISTINCT id
FROM cte
ORDER BY id ASC;
```

#### `05_tweets_length.sql`

```sql
-- Problem: Tweet IDs with content length > 15
-- Source: https://leetcode.com/problems/tweets/

SELECT
    tweet_id
FROM Tweets
WHERE LEN(content) > 15;
```

#### `06_employee_uni.sql`

```sql
-- Problem: List employees with unique IDs
-- Source: https://leetcode.com/problems/employee-uni/

SELECT
    u.unique_id,
    e.name
FROM Employees AS e
LEFT JOIN EmployeeUNI AS u
    ON e.id = u.id;
```

#### `07_sales_product.sql`

```sql
-- Problem: Sales records including product details
-- Source: https://leetcode.com/problems/sales-analysis-i/

SELECT
    p.product_name,
    s.year,
    s.price
FROM Sales AS s
INNER JOIN Product AS p
    ON s.product_id = p.product_id;
```

#### `08_visits_transactions.sql`

```sql
-- Problem: Customers who visited but made no transactions
-- Source: https://leetcode.com/problems/customer-who-visited-but-did-not-make-any-transactions/

SELECT
    v.customer_id,
    COUNT(*) AS count_no_trans
FROM Visits AS v
LEFT JOIN Transactions AS t
    ON v.visit_id = t.visit_id
WHERE t.visit_id IS NULL
GROUP BY v.customer_id;
```

#### `09_rising_temperature.sql`

```sql
-- Problem: Find days with rising temperature
-- Source: https://leetcode.com/problems/rising-temperature/

WITH cte AS (
    SELECT
        id,
        recordDate,
        temperature,
        LAG(recordDate) OVER (ORDER BY recordDate) AS prev_date,
        LAG(temperature) OVER (ORDER BY recordDate) AS prev_temp
    FROM Weather
)
SELECT id
FROM cte
WHERE DATEDIFF(day, prev_date, recordDate) = 1
  AND prev_temp < temperature;
```

#### `10_employee_bonus.sql`

```sql
-- Problem: Employees with low or missing bonus
-- Source: https://leetcode.com/problems/employee-bonus/

SELECT
    e.name,
    b.bonus
FROM Employee AS e
LEFT JOIN Bonus AS b
    ON e.empID = b.empID
WHERE b.bonus < 1000
   OR b.bonus IS NULL;
```

---

### (Solutions 11–20)

#### `11_students_examinations.sql`

```sql
-- Problem: Count attended exams per student per subject
-- Source: https://leetcode.com/problems/exam-attendance/

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
```

#### `12_managers_with_5.sql`

```sql
-- Problem: Managers with at least 5 direct reports
-- Source: https://leetcode.com/problems/managers-with-minimum-reports/

SELECT
    m.name
FROM Employee AS m
JOIN Employee AS e
    ON e.managerId = m.id
GROUP BY m.id, m.name
HAVING COUNT(m.id) >= 5;
```

#### `13_signup_confirmation_rate.sql`

```sql
-- Problem: Confirmation rate per user
-- Source: https://leetcode.com/problems/confirm-rate/

WITH cte_1 AS (
    SELECT
        s.user_id,
        c.action
    FROM Signups AS s
    LEFT JOIN Confirmations AS c
        ON s.user_id = c.user_id
)
SELECT
    user_id,
    CAST(
        CAST(COUNT(CASE WHEN action = 'confirmed' THEN 1 END) AS DECIMAL(10,2))
        / CAST(COUNT(user_id) AS DECIMAL(10,2))
        AS DECIMAL(10,2)
    ) AS confirmation_rate
FROM cte_1
GROUP BY user_id
ORDER BY confirmation_rate;
```

#### `14_cinema_rating.sql`

```sql
-- Problem: Find odd-ID cinemas not labeled 'boring'
-- Source: https://leetcode.com/problems/boring-cinema/

SELECT *
FROM Cinema
WHERE id % 2 != 0
  AND description != 'boring'
ORDER BY rating DESC;
```

#### `15_average_sales_price.sql`

```sql
-- Problem: Average price per product weighted by units sold
-- Source: https://leetcode.com/problems/average-sales-price/

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
        COALESCE(SUM(s.units * p.price) * 1.0 / NULLIF(SUM(s.units), 0), 0),
        2
    ) AS average_price
FROM PriceRanked p
LEFT JOIN UnitsSold s
    ON s.product_id = p.product_id
   AND s.purchase_date BETWEEN p.start_date AND p.end_date
WHERE p.rn = 1
GROUP BY p.product_id;
```

#### `16_project_employee_experience.sql`

```sql
-- Problem: Average experience years per project
-- Source: https://leetcode.com/problems/project-experience/

SELECT
    p.project_id,
    ROUND(SUM(e.experience_years) * 1.0 / COUNT(e.employee_id), 2) AS average_years
FROM project AS p
JOIN Employee AS e
    ON p.employee_id = e.employee_id
GROUP BY p.project_id;
```

#### `17_contest_percentage.sql`

```sql
-- Problem: Percentage of users per contest
-- Source: https://leetcode.com/problems/contest-participants/

SELECT
    contest_id,
    CAST(COUNT(DISTINCT user_id) * 1.0 / (SELECT COUNT(user_id) FROM Users) * 100 AS DECIMAL(10,2)) AS percentage
FROM Register
GROUP BY contest_id
ORDER BY percentage DESC, contest_id ASC;
```

#### `18_query_quality.sql`

```sql
-- Problem: Query quality and poor query percentage
-- Source: https://leetcode.com/problems/query-quality/

SELECT
    query_name,
    CAST(AVG(rating * 1.0 / position * 1.0) AS DECIMAL(10,2)) AS quality,
    CAST(
        (COUNT(CASE WHEN rating < 3 THEN 1 END) * 1.0 / COUNT(*) * 1.0) * 100 AS DECIMAL(10,2)
    ) AS poor_query_percentage
FROM Queries
GROUP BY query_name;
```

#### `19_transactions_summary.sql`

```sql
-- Problem: Monthly country-wise transaction summary
-- Source: https://leetcode.com/problems/transaction-summary-by-month/

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
```

#### `20_immediate_orders.sql`

```sql
-- Problem: Percent of first orders delivered immediately
-- Source: https://leetcode.com/problems/immediate-delivery-rate/

WITH cte_1 AS (
    SELECT
        *,
        (CASE WHEN (order_date = customer_pref_delivery_date) THEN 'Immediate' ELSE 'scheduled' END) AS status,
        RANK() OVER (PARTITION BY customer_id ORDER BY order_date) AS rn
    FROM Delivery
),
cte_2 AS (
    SELECT *
    FROM cte_1
    WHERE rn = 1
)
SELECT
    CAST(COUNT(CASE WHEN status = 'Immediate' THEN 1 END) * 1.0 / COUNT(*) * 100 AS DECIMAL(10,2)) AS immediate_percentage
FROM cte_2;
```

---

### (Solutions 21–30)

#### `21_fraction_active_players.sql`

```sql
-- Problem: Fraction of players active on consecutive days
-- Source: https://leetcode.com/problems/player-a-day/

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
    CAST(SUM(CASE WHEN days_diff = 1 AND rn = 2 THEN 1 ELSE 0 END) * 1.0 / COUNT(DISTINCT player_id) AS DECIMAL(10,2)) AS fraction
FROM cte;
```

#### `22_teacher_subjects.sql`

```sql
-- Problem: Count distinct subjects per teacher
-- Source: https://leetcode.com/problems/teacher-subjects-count/

SELECT
    teacher_id,
    COUNT(DISTINCT subject_id) AS cnt
FROM Teacher
GROUP BY teacher_id;
```

#### `23_active_users.sql`

```sql
-- Problem: Daily active users over a month
-- Source: https://leetcode.com/problems/active-users/

SELECT
    activity_date AS day,
    COUNT(DISTINCT user_id) AS active_users
FROM Activity
WHERE activity_date BETWEEN '2019-06-28' AND '2019-07-27'
GROUP BY activity_date;
```

#### `24_sales_first_year.sql`

```sql
-- Problem: First year sales per product
-- Source: https://leetcode.com/problems/first-year-sales/

WITH cte_1 AS (
    SELECT
        product_id,
        year,
        quantity,
        price,
        MIN(year) OVER (PARTITION BY product_id) AS min_year
    FROM Sales
)
SELECT
    product_id,
    year AS first_year,
    quantity,
    price
FROM cte_1
WHERE year = min_year;
```

#### `25_class_students.sql`

```sql
-- Problem: Courses with at least 5 students
-- Source: https://leetcode.com/problems/courses-with-minimum-students/

SELECT class
FROM courses
GROUP BY Class
HAVING COUNT(DISTINCT student) >= 5;
```

#### `26_followers_count.sql`

```sql
-- Problem: Follower count per user
-- Source: https://leetcode.com/problems/followers-count/

SELECT
    user_id,
    COUNT(follower_id) AS followers_count
FROM Followers
GROUP BY user_id;
```

#### `27_unique_numbers.sql`

```sql
-- Problem: Highest unique number
-- Source: https://leetcode.com/problems/unique-number/

SELECT COALESCE((
    SELECT TOP 1 num
    FROM MyNumbers
    GROUP BY num
    HAVING COUNT(num) = 1
    ORDER BY num DESC
), NULL) AS num;
```

#### `28_customer_products.sql`

```sql
-- Problem: Customers who bought all products
-- Source: https://leetcode.com/problems/customers-who-bought-everything/

SELECT
    customer_id
FROM customer
GROUP BY customer_id
HAVING COUNT(DISTINCT product_key) = (SELECT COUNT(product_key) FROM Product);
```

#### `29_manager_reports.sql`

```sql
-- Problem: Reports count and average age of employees per manager
-- Source: https://leetcode.com/problems/employee-reporting-structure/

WITH cte_1 AS (
    SELECT
        reports_to,
        COUNT(reports_to) AS reports_count,
        FLOOR(CAST(AVG(CAST(age AS DECIMAL(10,2))) AS DECIMAL(10,2)) + 0.5) AS average_age
    FROM Employees
    WHERE reports_to IS NOT NULL
    GROUP BY reports_to
)
SELECT
    e.employee_id,
    e.name,
    c.reports_count,
    c.average_age
FROM Employees AS e
INNER JOIN cte_1 AS c
    ON c.reports_to = e.employee_id;
```

#### `30_employee_department.sql`

```sql
-- Problem: Primary and alternate department flags
-- Source: https://leetcode.com/problems/department-assignment/

SELECT
    employee_id,
    department_id
FROM Employee
WHERE employee_id NOT IN (
    SELECT employee_id FROM Employee WHERE primary_flag = 'Y'
)
UNION ALL
SELECT
    employee_id,
    department_id
FROM Employee
WHERE primary_flag = 'Y';
```

---

### (Solutions 31–40)

#### `31_triangle_validity.sql`

```sql
-- Problem: Check if sides can form a triangle
-- Source: https://leetcode.com/problems/triangle-validity/

SELECT
    x,
    y,
    z,
    CASE
        WHEN ((x + y) > z AND (x + z) > y AND (y + z) > x) THEN 'Yes'
        ELSE 'No'
    END AS triangle
FROM Triangle;
```

#### `32_consecutive_numbers.sql`

```sql
-- Problem: Consecutive repeating numbers
-- Source: https://leetcode.com/problems/consecutive-numbers/

WITH cte_1 AS (
    SELECT
        id,
        num,
        LAG(num, 1) OVER (ORDER BY id) AS prev1,
        LAG(num, 2) OVER (ORDER BY id) AS prev2
    FROM Logs
)
SELECT DISTINCT num AS ConsecutiveNums
FROM cte_1
WHERE num = prev1 AND num = prev2;
```

#### `33_product_price_change.sql`

```sql
-- Problem: Latest price up to a given date, or default
-- Source: https://leetcode.com/problems/product-price-change/

WITH cte_1 AS (
    SELECT
        product_id,
        new_price AS price,
        change_date,
        MAX(change_date) OVER (PARTITION BY product_id) AS max_date
    FROM Products
    WHERE change_date <= '2019-08-16'
)
SELECT
    product_id,
    price
FROM cte_1
WHERE change_date = max_date

UNION ALL

SELECT DISTINCT
    product_id,
    10
FROM Products
WHERE product_id NOT IN (
    SELECT DISTINCT product_id FROM Products WHERE change_date <= '2019-08-16'
);
```

#### `34_queue_weight.sql`

```sql
-- Problem: Find the person with cumulative weight ≤ 1000 first
-- Source: https://leetcode.com/problems/winner-of-queue/

WITH cte_1 AS (
    SELECT
        turn,
        person_id,
        person_name,
        weight,
        SUM(weight) OVER (ORDER BY turn) AS total_weight
    FROM Queue
)
SELECT TOP 1 person_name
FROM cte_1
WHERE total_weight <= 1000
ORDER BY total_weight DESC;
```

#### `35_salary_categories.sql`

```sql
-- Problem: Count accounts per salary category
-- Source: https://leetcode.com/problems/salary-categories/

WITH cte_1 AS (
    SELECT
        *,
        CASE
            WHEN income > 50000 THEN 'High Salary'
            WHEN income >= 20000 AND income <= 50000 THEN 'Average Salary'
            ELSE 'Low Salary'
        END AS category
    FROM Accounts
),
cte_2 AS (
    SELECT 'High Salary' AS category
    UNION ALL
    SELECT 'Average Salary'
    UNION ALL
    SELECT 'Low Salary'
)
SELECT
    c2.category,
    COUNT(c1.account_id) AS accounts_count
FROM cte_2 AS c2
LEFT JOIN cte_1 AS c1
    ON c2.category = c1.category
GROUP BY c2.category;
```

#### `36_invalid_managers.sql`

```sql
-- Problem: Employees with invalid managers
-- Source: https://leetcode.com/problems/invalid-managers/

SELECT
    employee_id
FROM Employees
WHERE salary < 30000
  AND manager_id IS NOT NULL
  AND manager_id NOT IN (
    SELECT employee_id FROM Employees
)
ORDER BY employee_id ASC;
```

#### `37_top_movies_users.sql`

```sql
-- Problem: Top user and movie based on ratings in February 2020
-- Source: https://leetcode.com/problems/movie-rating/

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
        SUM(rating) * 1.0 / COUNT(*) * 1.0 AS avg_rating
    FROM cte
    WHERE created_at BETWEEN '2020-02-01' AND '2020-02-29'
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
```

#### `38_customer_spending.sql`

```sql
-- Problem: Moving sum and average of spending by date
-- Source: https://leetcode.com/problems/customer-spending/

WITH cte_1 AS (
    SELECT
        visited_on,
        SUM(amount) AS amount
    FROM Customer
    GROUP BY visited_on
),
cte_2 AS (
    SELECT
        visited_on,
        SUM(amount) OVER (ORDER BY visited_on ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS amount,
        CAST(AVG(amount * 1.0) OVER (ORDER BY visited_on ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS DECIMAL(10,2)) AS average_amount,
        ROW_NUMBER() OVER (ORDER BY visited_on) AS rn
    FROM cte_1
)
SELECT
    visited_on,
    amount,
    average_amount
FROM cte_2
WHERE rn >= 7;
```

#### `39_most_friends.sql`

```sql
-- Problem: Most connected user (requests received or sent)
-- Source: https://leetcode.com/problems/most-friends/

WITH cte_1 AS (
    SELECT
        requester_id,
        COUNT(*) AS rcn
    FROM RequestAccepted
    GROUP BY requester_id
),
cte_2 AS (
    SELECT
        accepter_id,
        COUNT(*) AS acn
    FROM RequestAccepted
    GROUP BY accepter_id
)
SELECT TOP 1
    CASE WHEN requester_id IS NULL THEN accepter_id ELSE requester_id END AS id,
    (COALESCE(rcn, 0) + COALESCE(acn, 0)) AS num
FROM cte_1 AS c1
FULL OUTER JOIN cte_2 AS c2
    ON c1.requester_id = c2.accepter_id
ORDER BY num DESC;
```

#### `40_total_insurance.sql`

```sql
-- Problem: Sum tiv_2016 for duplicate tiv_2015 and unique lat/lon
-- Source: https://leetcode.com/problems/insurance-claim/

WITH duplicate_tiv AS (
    SELECT tiv_2015
    FROM Insurance
    GROUP BY tiv_2015
    HAVING COUNT(*) > 1
),
unique_location AS (
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
```

---

### (Solutions 41–47)

*(Note: I only count 47 here; if you have 50, you might need to add more. Adjust numbering and files accordingly.)*

#### `41_top_3_salaries.sql`

```sql
-- Problem: Top 3 salaries in each department
-- Source: https://leetcode.com/problems/top-three-salaries/

WITH cte AS (
    SELECT
        d.name AS Department,
        e.name AS Employee,
        e.salary AS Salary,
        DENSE_RANK() OVER (PARTITION BY d.name ORDER BY e.salary DESC) AS rn
    FROM Employee AS e
    JOIN Department AS d
        ON e.departmentId = d.id
)
SELECT
    Department,
    Employee,
    Salary
FROM cte
WHERE rn <= 3;
```

#### `42_user_name_format.sql`

```sql
-- Problem: Capitalize user name properly
-- Source: https://leetcode.com/problems/capitalize-name/

SELECT
    user_id,
    UPPER(LEFT(name, 1)) + LOWER(SUBSTRING(name, 2, LEN(name))) AS name
FROM Users
ORDER BY user_id;
```

#### `43_patients_diabetes.sql`

```sql
-- Problem: Patients with 'DIAB1' in conditions
-- Source: https://leetcode.com/problems/patients-with-diabetes/

SELECT *
FROM Patients
WHERE conditions LIKE '% DIAB1%'
   OR conditions LIKE 'DIAB1%';
```

#### `44_second_highest_salary.sql`

```sql
-- Problem: Second highest salary
-- Source: https://leetcode.com/problems/second-highest-salary/

SELECT
    CASE WHEN COUNT(DISTINCT salary) < 2 THEN NULL
    ELSE (
        SELECT MAX(salary)
        FROM Employee
        WHERE salary < (SELECT MAX(salary) FROM Employee)
    )
    END AS SecondHighestSalary
FROM Employee;
```

#### `45_daily_products.sql`

```sql
-- Problem: Daily product aggregation
-- Source: https://leetcode.com/problems/daily-products/

WITH cte AS (
    SELECT DISTINCT
        sell_date,
        product
    FROM Activities
)
SELECT
    sell_date,
    COUNT(product) AS num_sold,
    STRING_AGG(product, ',') AS products
FROM cte
GROUP BY sell_date;
```

#### `46_february_orders.sql`

```sql
-- Problem: Products ordered ≥100 units in Feb 2020
-- Source: https://leetcode.com/problems/february-orders/

SELECT
    p.product_name,
    SUM(o.unit) AS unit
FROM Orders AS o
JOIN Products AS p
    ON o.product_id = p.product_id
WHERE order_date BETWEEN '2020-02-01' AND '2020-02-29'
GROUP BY p.product_name
HAVING SUM(o.unit) >= 100;
```

#### `47_valid_emails.sql`

```sql
-- Problem: Users with valid LeetCode emails
-- Source: https://leetcode.com/problems/valid-username/

SELECT user_id, name, mail
FROM Users
WHERE mail LIKE '[A-Za-z]%'
  AND mail COLLATE SQL_Latin1_General_CP1_CS_AS LIKE '%@leetcode.com'
  AND LEFT(mail, LEN(mail) - LEN('@leetcode.com')) NOT LIKE '%[^A-Za-z0-9._-]%';
```

---

## How to Use

1. Copy the `.sql` blocks above and paste each into its own file in the `solutions/` folder, naming them as shown (`01_products_recyclable.sql`, etc.).
2. Replace the `Source:` placeholders with the actual LeetCode problem URL.
3. Upload your `README.md` and `solutions/` folder to GitHub.

---

This all-in-one canvas gives you both a well-formatted README and all 47 (or 50, depending on your set) SQL solution files ready to go. Want help generating the final zip or pushing it to your repo?

