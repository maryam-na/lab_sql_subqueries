# 1- How many copies of the film Hunchback Impossible exist in the inventory system?
use sakila;
SELECT 
    film_inventory.title AS film_title,
    COUNT(*) AS number_of_copies
FROM
    (SELECT 
        f.film_id, f.title, i.inventory_id
    FROM
        film f
    JOIN inventory i ON f.film_id = i.film_id) AS film_inventory
WHERE
    film_inventory.title = 'HUNCHBACK IMPOSSIBLE'
;
# 2- List all films whose length is longer than the average of all the films.
SET @average_length = (select avg(length) from film);
select film_id, title as film_title, length from film
where length > @average_length;
select film_id, title, length, avg(length) as average_length from film;

# 3- Use subqueries to display all actors who appear in the film Alone Trip.

SELECT 
    CONCAT(af.first_name, ' ', af.last_name) AS actor_name
FROM
    (SELECT 
        f.film_id,
            f.title AS fil_title,
            a.actor_id,
            a.first_name,
            a.last_name
    FROM
        film f
    JOIN film_actor fa ON f.film_id = fa.film_id
    JOIN actor a ON fa.actor_id = a.actor_id
    WHERE
        f.title = 'ALONE TRIP') AS af;
        
# 4- Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
SELECT 
    cf.title AS film_title, cf.name AS film_category
FROM
    (SELECT 
        f.film_id, f.title, fc.category_id, c.name
    FROM
        film f
    JOIN film_category fc ON f.film_id = fc.film_id
    JOIN category c ON fc.category_id = c.category_id
    WHERE
        c.name = 'Family') AS cf;
        
# 5- Get name and email from customers from Canada using subqueries. Do the same with joins. Note that to create a join, you will have to identify the correct tables with their primary keys and foreign keys, that will help you get the relevant information.        
SELECT 
    CONCAT(ca.first_name, ' ', ca.last_name) AS customer_name, ca.email, ca.country 
FROM
    (SELECT 
        c.customer_id, c.first_name, c.last_name, c. email, co.country
    FROM
        customer c
    JOIN address a ON c.address_id = a.address_id
    JOIN city ci ON a.city_id = ci.city_id
    JOIN country co ON ci.country_id = co.country_id
    WHERE
        co.country = 'Canada') AS ca;
        
# 6- Which are films starred by the most prolific actor? Most prolific actor is defined as the actor that has acted in the most number of films. First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred.        
# first finding the actor_id of the most prolific actor
CREATE OR REPLACE VIEW profilic_actor AS
    SELECT 
        a.actor_id,
        CONCAT(a.first_name, ' ', a.last_name) AS actor_name,
        f.film_id,
        f.title AS film_title,
        COUNT(f.film_id) AS movie_numbers
    FROM
        film f
            JOIN
        film_actor fa ON f.film_id = fa.film_id
            JOIN
        actor a ON fa.actor_id = a.actor_id
    GROUP BY 1
    ORDER BY 4 DESC
    LIMIT 1;
SET @most_profilic_actor = (SELECT actor_id FROM  profilic_actor);
SELECT 
    f.title,
    CONCAT(a.first_name, ' ', a.last_name) AS actor_name
FROM
    film f
        JOIN
    film_actor fa ON f.film_id = fa.film_id
        JOIN
    actor a ON fa.actor_id = a.actor_id
WHERE
    a.actor_id = @most_profilic_actor;
    
# 7- Films rented by most profitable customer. You can use the customer table and payment table to find the most profitable customer is the customer that has made the largest sum of payments    
 # first finding the customer_id of the most prolific customer
  CREATE OR REPLACE VIEW profilic_customer AS
    SELECT 
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name, sum(p.amount) as total_payment
    FROM
        customer c
            JOIN
        payment p ON c.customer_id = p.customer_id
    GROUP BY 1
    ORDER BY 3 DESC
    LIMIT 1;
SET @most_profilic_customer = (SELECT customer_id FROM  profilic_customer);
SELECT CONCAT(c.first_name, ' ', c.last_name) AS customer_name, sum(p.amount) as total_payment
    FROM
        customer c
            JOIN
        payment p ON c.customer_id = p.customer_id
WHERE
    c.customer_id = @most_profilic_customer;
    
# 8- Get the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client. 
        
SELECT
    c. customer_id, concat(c.first_name, ' ', c.last_name) AS customer_name,
    round(sum(amount), 2) AS amount
FROM
    customer c
    JOIN payment p ON c.customer_id = p.customer_id
GROUP BY
    1
HAVING
    amount > (
        SELECT
            avg(amount)
        FROM
            (
                SELECT
                    concat(c.first_name, ' ', c.last_name) AS customer_name,
                    round(sum(amount), 2) AS amount
                FROM
                    customer c
                    JOIN payment p ON c.customer_id = p.customer_id
                GROUP BY
                    1
            ) AS cp
    )
ORDER BY
    3 DESC;        