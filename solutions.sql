
-- 1. Select Product IDs where product is low fat and recyclable
SELECT product_id
FROM Products
WHERE low_fats = 'Y' AND recyclable = 'Y';

-- 2. Customers without referee or referee not equal to 2
SELECT name
FROM Customer
WHERE referee_id IS NULL OR referee_id != 2;

-- 3. Large countries by population or area
SELECT name, population, area
FROM World
WHERE area >= 3000000 OR population >= 25000000;

-- 4. Find authors who viewed their own articles
WITH cte_1 AS (
    SELECT author_id AS id
    FROM Views
    WHERE author_id = viewer_id
)
SELECT DISTINCT id
FROM cte_1
ORDER BY id ASC;

-- 5. Tweets with content longer than 15 characters
SELECT tweet_id
FROM Tweets
WHERE LEN(content) > 15;

-- 6. Employee names with their unique IDs
SELECT u.unique_id, e.name
FROM Employees AS e
LEFT JOIN EmployeeUNI AS u ON e.id = u.id;

-- 7. Product sales information
SELECT p.product_name, s.year, s.price
FROM Sales AS s
INNER JOIN Product AS p ON s.product_id = p.product_id;

-- 8. Customers with no transactions
SELECT v.customer_id, COUNT(*) AS count_no_trans
FROM Visits AS v
LEFT JOIN Transactions AS t ON v.visit_id = t.visit_id
WHERE t.visit_id IS NULL
GROUP BY v.customer_id;

-- 9. Rising temperatures in consecutive days
WITH cte AS (
    SELECT id, recordDate, temperature,
           LAG(recordDate) OVER (ORDER BY recordDate) AS prev_date,
           LAG(temperature) OVER (ORDER BY recordDate) AS prev_temp
    FROM Weather
)
SELECT id
FROM cte
WHERE DATEDIFF(day, prev_date, recordDate) = 1 AND prev_temp < temperature;

-- 10. Employees with low or no bonus
SELECT e.name, b.bonus
FROM Employee AS e
LEFT JOIN Bonus AS b ON e.empID = b.empID
WHERE b.bonus < 1000 OR b.bonus IS NULL;

-- 11. Students, subjects, and attended exams
WITH cte_1 AS (
    SELECT student_id, student_name
    FROM Students
)
SELECT c.student_id, c.student_name, s.subject_name,
       COUNT(e.student_id) AS attended_exams
FROM cte_1 AS c
CROSS JOIN Subjects AS s
LEFT JOIN Examinations AS e
    ON c.student_id = e.student_id
   AND s.subject_name = e.subject_name
GROUP BY c.student_id, c.student_name, s.subject_name
ORDER BY c.student_id, c.student_name;

-- 12. Managers with at least 5 direct reports
SELECT m.name
FROM Employee m
JOIN Employee e ON e.managerId = m.id
GROUP BY m.id, m.name
HAVING COUNT(m.id) >= 5;

-- 13. User confirmation rate
WITH cte_1 AS (
    SELECT s.user_id, c.action
    FROM Signups AS s
    LEFT JOIN Confirmations AS c ON s.user_id = c.user_id
)
SELECT user_id,
       CAST(CAST(COUNT(CASE WHEN action = 'confirmed' THEN 1 END) AS DECIMAL(10,2)) /
            CAST(COUNT(user_id) AS DECIMAL(10,2)) AS DECIMAL(10,2)) AS confirmation_rate
FROM cte_1
GROUP BY user_id
ORDER BY confirmation_rate;

-- 14. Cinema movies with odd IDs and not boring
SELECT *
FROM Cinema
WHERE id % 2 != 0 AND description != 'boring'
ORDER BY rating DESC;

-- 15. Average price of sold units
WITH PriceRanked AS (
    SELECT product_id, start_date, end_date, price,
           ROW_NUMBER() OVER (PARTITION BY product_id, start_date, end_date ORDER BY price ASC) AS rn
    FROM Prices
)
SELECT p.product_id,
       ROUND(COALESCE(SUM(s.units * p.price) * 1.0 / NULLIF(SUM(s.units), 0), 0), 2) AS average_price
FROM PriceRanked p
LEFT JOIN UnitsSold s
    ON s.product_id = p.product_id
   AND s.purchase_date BETWEEN p.start_date AND p.end_date
WHERE p.rn = 1
GROUP BY p.product_id;

-- 16. Average years of project employees
SELECT p.project_id,
       ROUND(SUM(e.experience_years) * 1.0 / COUNT(e.employee_id) * 1.0, 2) AS average_years
FROM Project AS p
JOIN Employee AS e ON p.employee_id = e.employee_id
GROUP BY p.project_id;

-- 17. Contest registration percentage
SELECT contest_id,
       CAST(COUNT(DISTINCT user_id) * 1.0 / (SELECT COUNT(user_id) FROM Users) * 100 AS DECIMAL(10,2)) AS percentage
FROM Register
GROUP BY contest_id
ORDER BY percentage DESC, contest_id ASC;

-- 18. Query quality and poor query percentage
SELECT query_name,
       CAST(AVG(rating * 1.0 / position * 1.0) AS DECIMAL(10,2)) AS quality,
       CAST((COUNT(CASE WHEN rating < 3 THEN 1 END) * 1.0 / COUNT(*) * 1.0) * 100 AS DECIMAL(10,2)) AS poor_query_percentage
FROM Queries
GROUP BY query_name;

-- 19. Monthly transaction report
WITH Transformed AS (
    SELECT CAST(YEAR(trans_date) AS VARCHAR) + '-' + RIGHT('0' + CAST(MONTH(trans_date) AS VARCHAR), 2) AS month,
           country, amount, state
    FROM Transactions
)
SELECT month, country,
       COUNT(*) AS trans_count,
       SUM(CASE WHEN state = 'approved' THEN 1 ELSE 0 END) AS approved_count,
       SUM(amount) AS trans_total_amount,
       SUM(CASE WHEN state = 'approved' THEN amount ELSE 0 END) AS approved_total_amount
FROM Transformed
GROUP BY month, country
ORDER BY month, country;

-- 20. Percentage of immediate deliveries
WITH cte_1 AS (
    SELECT *,
           CASE WHEN (order_date = customer_pref_delivery_date) THEN 'Immediate' ELSE 'Scheduled' END AS status,
           RANK() OVER (PARTITION BY customer_id ORDER BY order_date) AS rn
    FROM Delivery
),
cte_2 AS (
    SELECT * FROM cte_1 WHERE rn = 1
)
SELECT CAST(COUNT(CASE WHEN status = 'Immediate' THEN 1 END) * 1.0 / COUNT(*) * 100 AS DECIMAL(10,2)) AS immediate_percentage
FROM cte_2;

-- 21. Fraction of players who logged in on consecutive days
WITH cte AS (
    SELECT player_id, event_date,
           DATEDIFF(day, LAG(event_date) OVER (PARTITION BY player_id ORDER BY event_date), event_date) AS days_diff,
           ROW_NUMBER() OVER (PARTITION BY player_id ORDER BY event_date) AS rn
    FROM Activity
)
SELECT CAST(SUM(CASE WHEN days_diff = 1 AND rn = 2 THEN 1 ELSE 0 END) * 1.0 / COUNT(DISTINCT player_id) AS DECIMAL(10,2)) AS fraction
FROM cte;

-- 22. Number of subjects per teacher
SELECT teacher_id, COUNT(DISTINCT subject_id) AS cnt
FROM Teacher
GROUP BY teacher_id;

-- 23. Daily active users
SELECT activity_date AS day, COUNT(DISTINCT user_id) AS active_users
FROM Activity
WHERE activity_date BETWEEN '2019-06-28' AND '2019-07-27'
GROUP BY activity_date;

-- 24. First year of sales per product
WITH cte_1 AS (
    SELECT product_id, year, quantity, price,
           MIN(year) OVER (PARTITION BY product_id) AS min_year
    FROM Sales
)
SELECT product_id, year AS first_year, quantity, price
FROM cte_1
WHERE year = min_year;

-- 25. Classes with at least 5 students
SELECT class
FROM Courses
GROUP BY class
HAVING COUNT(DISTINCT student) >= 5;

-- 26. Followers count per user
SELECT user_id, COUNT(follower_id) AS followers_count
FROM Followers
GROUP BY user_id;

-- 27. Largest unique number
SELECT COALESCE(
    (SELECT TOP 1 num
     FROM MyNumbers
     GROUP BY num
     HAVING COUNT(num) = 1
     ORDER BY num DESC), NULL) AS num;

-- 28. Customers who bought all products
SELECT customer_id
FROM Customer
GROUP BY customer_id
HAVING COUNT(DISTINCT product_key) = (SELECT COUNT(product_key) FROM Product);

-- 29. Employees with report counts and average age
WITH cte_1 AS (
    SELECT reports_to, COUNT(reports_to) AS reports_count,
           FLOOR(CAST(AVG(CAST(age AS DECIMAL(10,2))) AS DECIMAL(10,2)) + 0.5) AS average_age
    FROM Employees
    WHERE reports_to IS NOT NULL
    GROUP BY reports_to
)
SELECT e.employee_id, e.name, c.reports_count, c.average_age
FROM Employees AS e
INNER JOIN cte_1 AS c ON c.reports_to = e.employee_id;

-- 30. Employee-department assignment with primary flag
SELECT employee_id, department_id
FROM Employee
WHERE Employee_id NOT IN (SELECT Employee_id FROM Employee WHERE primary_flag = 'Y')
UNION ALL
SELECT Employee_id, Department_id
FROM Employee
WHERE primary_flag = 'Y';

-- 31. Triangle validation
SELECT x, y, z,
       CASE WHEN ((x + y) > z AND (x + z) > y AND (y + z) > x) THEN 'Yes' ELSE 'No' END AS triangle
FROM Triangle;

-- 32. Consecutive numbers in logs
WITH cte_1 AS (
    SELECT id, num,
           LAG(num, 1) OVER (ORDER BY id) AS prev1,
           LAG(num, 2) OVER (ORDER BY id) AS prev2
    FROM Logs
)
SELECT DISTINCT num AS ConsecutiveNums
FROM cte_1
WHERE num = prev1 AND num = prev2;

-- 33. Latest price of products before date
WITH cte_1 AS (
    SELECT product_id, new_price AS price, change_date,
           MAX(change_date) OVER (PARTITION BY product_id) AS max_date
    FROM Products
    WHERE change_date <= '2019-08-16'
)
SELECT product_id, price
FROM cte_1
WHERE change_date = max_date
UNION ALL
SELECT DISTINCT product_id, 10
FROM Products
WHERE product_id NOT IN (SELECT DISTINCT product_id FROM Products WHERE change_date <= '2019-08-16');

-- 34. Heaviest person before 1000 weight limit
WITH cte_1 AS (
    SELECT turn, person_id, person_name, weight,
           SUM(weight) OVER (ORDER BY turn) AS total_weight
    FROM Queue
)
SELECT TOP 1 person_name
FROM cte_1
WHERE total_weight <= 1000
ORDER BY total_weight DESC;

-- 35. Account categorization by salary
WITH cte_1 AS (
    SELECT *,
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
SELECT c2.category, COUNT(c1.account_id) AS accounts_count
FROM cte_2 AS c2
LEFT JOIN cte_1 AS c1 ON c2.category = c1.category
GROUP BY c2.category;

-- 36. Employees with missing managers
SELECT employee_id
FROM Employees
WHERE salary < 30000
  AND manager_id IS NOT NULL
  AND manager_id NOT IN (SELECT employee_id FROM Employees)
ORDER BY employee_id ASC;

-- 37. Top user and top movie in Feb 2020
WITH cte AS (
    SELECT r.movie_id, m.title, r.user_id, u.name, r.rating, r.created_at
    FROM MovieRating AS r
    JOIN Movies AS m ON r.movie_id = m.movie_id
    JOIN Users AS u ON r.user_id = u.user_id
),
cte_1 AS (
    SELECT user_id, name, COUNT(user_id) AS cn
    FROM cte
    GROUP BY user_id, name
),
cte_2 AS (
    SELECT movie_id, title, SUM(rating) * 1.0 / COUNT(*) * 1.0 AS avg_rating
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

-- 38. 7-day rolling average of customers
WITH cte_1 AS (
    SELECT visited_on, SUM(amount) AS amount
    FROM Customer
    GROUP BY visited_on
),
cte_2 AS (
    SELECT visited_on,
           SUM(amount) OVER (ORDER BY visited_on ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS amount,
           CAST(AVG(amount * 1.0) OVER (ORDER BY visited_on ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS DECIMAL(10,2)) AS average_amount,
           ROW_NUMBER() OVER (ORDER BY visited_on) AS rn
    FROM cte_1
)
SELECT visited_on, amount, average_amount
FROM cte_2
WHERE rn >= 7;

-- 39. Person with most accepted requests
WITH cte_1 AS (
    SELECT requester_id, COUNT(*) AS rcn
    FROM RequestAccepted
    GROUP BY requester_id
),
cte_2 AS (
    SELECT accepter_id, COUNT(*) AS acn
    FROM RequestAccepted
    GROUP BY accepter_id
)
SELECT TOP 1
       CASE WHEN requester_id IS NULL THEN accepter_id ELSE requester_id END AS id,
       (COALESCE(rcn, 0) + COALESCE(acn, 0)) AS num
FROM cte_1 AS c1
FULL OUTER JOIN cte_2 AS c2 ON c1.requester_id = c2.accepter_id
ORDER BY num DESC;

-- 40. Total tiv_2016 with conditions
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
SELECT CAST(SUM(tiv_2016) AS DECIMAL(10,2)) AS tiv_2016
FROM Insurance i
JOIN duplicate_tiv d ON i.tiv_2015 = d.tiv_2015
JOIN unique_location u ON i.lat = u.lat AND i.lon = u.lon;

-- 41. Top 3 salaries per department
WITH cte AS (
    SELECT d.name AS Department, e.name AS Employee, e.salary AS Salary,
           DENSE_RANK() OVER (PARTITION BY d.name ORDER BY e.salary DESC) AS rn
    FROM Employee AS e
    JOIN Department AS d ON e.departmentId = d.id
)
SELECT Department, Employee, Salary
FROM cte
WHERE rn <= 3;

-- 42. Format user names
SELECT user_id,
       UPPER(LEFT(name, 1)) + LOWER(SUBSTRING(name, 2, LEN(name))) AS name
FROM Users
ORDER BY user_id;

-- 43. Patients with diabetes
SELECT *
FROM Patients
WHERE conditions LIKE '% DIAB1%'
   OR conditions LIKE 'DIAB1%';

-- 44. Second highest salary
SELECT CASE WHEN COUNT(DISTINCT salary) < 2 THEN NULL ELSE (
           SELECT MAX(salary)
           FROM Employee
           WHERE salary < (SELECT MAX(salary) FROM Employee)) END AS SecondHighestSalary
FROM Employee;

-- 45. Number of products sold per day
WITH cte AS (
    SELECT DISTINCT sell_date, product
    FROM Activities
)
SELECT sell_date, COUNT(product) AS num_sold, STRING_AGG(product, ',') AS products
FROM cte
GROUP BY sell_date;

-- 46. Products with sales >= 100 units
SELECT p.product_name, SUM(o.unit) AS unit
FROM Orders AS o
JOIN Products AS p ON o.product_id = p.product_id
WHERE order_date BETWEEN '2020-02-01' AND '2020-02-29'
GROUP BY p.product_name
HAVING SUM(o.unit) >= 100;

-- 47. Valid user emails
SELECT user_id, name, mail
FROM Users
WHERE mail LIKE '[A-Za-z]%'
  AND mail COLLATE SQL_Latin1_General_CP1_CS_AS LIKE '%@leetcode.com'
  AND LEFT(mail, LEN(mail) - LEN('@leetcode.com')) NOT LIKE '%[^A-Za-z0-9._-]%';








