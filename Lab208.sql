USE sakila;

-- 1. Write a query to display for each store its store ID, city, and country

SELECT s.store_id, ci.city, co.country
FROM sakila.address a
INNER JOIN sakila.store s
USING(address_id)
INNER JOIN sakila.city ci
USING(city_id)
INNER JOIN country co
USING(country_id);

-- 2. Write a query to display how much business, in dollars, each store brought in

SELECT s.store_id, SUM(p.amount) AS Amount
FROM sakila.payment p
INNER JOIN sakila.staff s 
USING(staff_id)
GROUP BY store_id;

-- 3. Which film categories are longest?

SELECT c.name AS Category, AVG(f.length) AS Longest
FROM sakila.film f 
INNER JOIN film_category fc
USING(film_id) 
INNER JOIN sakila.category c
USING(category_id)
GROUP BY c.name
ORDER BY Longest DESC;

-- 4. Display the most frequently rented movies in descending order

SELECT f.title, COUNT(f.film_id) AS Number_Times_Rented
FROM  sakila.film f
INNER JOIN sakila.inventory i 
USING (film_id)
INNER JOIN sakila.rental r 
USING (inventory_id)
GROUP BY f.title 
ORDER BY Number_Times_Rented DESC;

-- 5. List the top five genres in gross revenue in descending order

SELECT c.name AS 'Top_Five_Genres', SUM(p.amount) AS 'Gross_Revenue'
FROM sakila.payment p
INNER JOIN sakila.rental r
USING (rental_id)
INNER JOIN sakila.inventory i
USING (inventory_id)
INNER JOIN sakila.film_category fc
USING (film_id)
INNER JOIN sakila.category c
USING (category_id) 
GROUP BY c.name 
ORDER BY SUM(p.amount) DESC
LIMIT 5;

-- 6. Is "Academy Dinosaur" available for rent from Store 1?

SELECT COUNT(DISTINCT i.inventory_id) AS "Copies_Availables_for_Rent"
FROM sakila.inventory i
INNER JOIN sakila.rental r
USING (inventory_id) 
JOIN sakila.film f
USING (film_id)
WHERE ((f.title = 'Academy Dinosaur') AND (i.store_id = 1) AND (r.return_date IS NOT NULL));

-- 7. Get all pairs of actors that worked together

SELECT f.film_id, CONCAT (a1.first_name, ' ', a1.last_name) AS First_Actor, 
CONCAT (a2.first_name, ' ', a2.last_name) AS Second_Actor
FROM sakila.film f
INNER JOIN sakila.film_actor fa1
USING (film_id)
INNER JOIN sakila.actor a1
ON fa1.actor_id=a1.actor_id
INNER JOIN sakila.film_actor fa2
USING (film_id)
INNER JOIN sakila.actor a2
ON  fa2.actor_id=a2.actor_id
WHERE (a1.first_name, ' ', a1.last_name) != (a2.first_name, ' ', a2.last_name)
AND (a1.first_name, ' ', a1.last_name) < (a2.first_name, ' ', a2.last_name)
GROUP BY a1.actor_id
ORDER BY a1.first_name;

-- 8. Get all pairs of customers that have rented the same film more than 3 times

SELECT r1.customer_id AS Customer_1, r2.customer_id AS Customer_2, COUNT(DISTINCT r1.inventory_id) as Number_of_Times
FROM sakila.rental r1 
JOIN sakila.rental r2
ON r1.inventory_id = r2.inventory_id AND r1.customer_id < r2.customer_id
GROUP BY r1.customer_id, r2.customer_id
HAVING Number_of_Times >=3
ORDER BY Number_of_Times DESC;

-- 9. For each film, list actor that has acted in more films

SELECT f.title, y.first_name, y.last_name, appearances
FROM (
SELECT x.film_id, x.actor_id, a.first_name, a.last_name, appearances
FROM 
	(SELECT fa.film_id, fa.actor_id, appearances, row_number() 
    OVER (partition by fa.film_id ORDER BY appearances DESC) AS row_num
    FROM sakila.film_actor fa
    INNER JOIN (
		SELECT fa.actor_id, COUNT(*) AS appearances
        FROM sakila.film_actor fa
        GROUP BY fa.actor_id
        ORDER BY appearances DESC) ap
        ON ap.actor_id=fa.actor_id) x
	INNER JOIN sakila.actor a
    ON x.actor_id=a.actor_id
    WHERE x.row_num=1) y
    JOIN sakila.film f
    ON (f.film_id=y.film_id);
