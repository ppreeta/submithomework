use sakila;

#Display the first and last names of all actors from the table `actor`
select first_name,last_name from actor;

#Display the first and last name of each actor in a single column in upper case letters. 
#Name the column `Actor Name`.0
select upper(concat(first_name ,"  ", last_name)) as ActorName from actor;

#You need to find the ID number, first name, and last name of an actor, of whom you know only
#the first name, "Joe." what is one query would you use to obtain this information?
select * from actor where first_name="Joe";

#Find all actors whose last name contain the letters `GEN`
select * from actor where last_name like "%GEN%";

#Find all actors whose last names contain the letters `LI`. This time, order the rows
#by last name and first name, in that order

select * from actor where last_name like "%LI%" order by last_name,first_name;

#Using `IN`, display the `country_id` and `country` columns of the following countries:
#Afghanistan, Bangladesh, and China:
select * from country where country in ("Afghanistan", "Bangladesh","China");

#3a. You want to keep a description of each actor.
ALTER TABLE actor ADD description BLOB;

#3b. Very quickly you realize that entering descriptions for each actor is too much effort.
#Delete the `description` column.
ALTER TABLE actor DROP COLUMN description;
select * from actor;

#4a and 4b. List the last names of actors, as well as how many actors have that last name.
select last_name,count(last_name) from actor group by last_name having count(last_name)>=2;

#4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. 
#Write a query to fix the record.
UPDATE actor SET first_name = "Harpo", last_name = "Williams" where first_name="GROUCHO" and
last_name="WILLIAMS";

#* 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` 
#was the correct name after all!In a single query, if the first name of the actor is currently 
#`HARPO`, change it to `GROUCHO`.
SET SQL_SAFE_UPDATES = 0;
UPDATE actor SET first_name = "GROUCHO" where first_name="HARPO";

#5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
show create table address;

# 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member.
#Use the tables `staff` and `address`:

SELECT first_name, last_name,address FROM staff join address;

# 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005.
# Use tables `staff` and `payment`.
SELECT first_name, last_name, SUM(amount) FROM staff s INNER JOIN payment p ON s.staff_id = p.staff_id
GROUP BY p.staff_id
ORDER BY last_name ASC;

#6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` 
#and `film`. Use inner join.
SELECT title, COUNT(actor_id) FROM film f INNER JOIN film_actor fa ON f.film_id = fa.film_id
GROUP BY title;


# 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?

SELECT title, COUNT(inventory_id) FROM film f INNER JOIN inventory i 
ON f.film_id = i.film_id
WHERE title = "Hunchback Impossible";

# 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by 
#each customer. List the customers alphabetically by last name:
SELECT last_name, first_name, SUM(amount)
FROM payment p
INNER JOIN customer c
ON p.customer_id = c.customer_id
GROUP BY p.customer_id
ORDER BY last_name ASC;

# 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` 
#and `Q` whose language is English.
USE Sakila;

SELECT title FROM film
WHERE language_id in
	(SELECT language_id 
	FROM language
	WHERE name = "English" )
AND (title LIKE "K%") OR (title LIKE "Q%");


-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.

USE Sakila;

SELECT last_name, first_name
FROM actor
WHERE actor_id in
	(SELECT actor_id FROM film_actor
	WHERE film_id in 
		(SELECT film_id FROM film
		WHERE title = "Alone Trip"));
        
-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. 
-- Use joins to retrieve this information.

USE Sakila;

SELECT country, last_name, first_name, email
FROM country c
LEFT JOIN customer cu
ON c.country_id = cu.customer_id
WHERE country = 'Canada';

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies 
-- categorized as family films.

USE Sakila;

SELECT title, category
FROM film_list
WHERE category = 'Family';
		

-- 7e. Display the most frequently rented movies in descending order.

USE Sakila;

SELECT i.film_id, f.title, COUNT(r.inventory_id)
FROM inventory i
INNER JOIN rental r
ON i.inventory_id = r.inventory_id
INNER JOIN film_text f 
ON i.film_id = f.film_id
GROUP BY r.inventory_id
ORDER BY COUNT(r.inventory_id) DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.

SELECT store.store_id, SUM(amount)
FROM store
INNER JOIN staff
ON store.store_id = staff.store_id
INNER JOIN payment p 
ON p.staff_id = staff.staff_id
GROUP BY store.store_id
ORDER BY SUM(amount);

-- 7g. Write a query to display for each store its store ID, city, and country.

USE Sakila;

SELECT s.store_id, city, country
FROM store s
INNER JOIN customer cu
ON s.store_id = cu.store_id
INNER JOIN staff st
ON s.store_id = st.store_id
INNER JOIN address a
ON cu.address_id = a.address_id
INNER JOIN city ci
ON a.city_id = ci.city_id
INNER JOIN country coun
ON ci.country_id = coun.country_id;
WHERE country = 'CANADA' AND country = 'AUSTRAILA';


-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following 
-- tables: category, film_category, inventory, payment, and rental.)

USE Sakila;

SELECT name, SUM(p.amount)
FROM category c
INNER JOIN film_category fc
INNER JOIN inventory i
ON i.film_id = fc.film_id
INNER JOIN rental r
ON r.inventory_id = i.inventory_id
INNER JOIN payment p
GROUP BY name
LIMIT 5;

-- 8a. In your new role as an executive, you would like to have an easy way of 
-- viewing the top five genres by gross revenue. Use the solution from the 
-- problem above to create a view. If you haven't solved 7h, you can substitute 
-- another query to create a view.

USE Sakila;

CREATE VIEW top_five_grossing_genres AS

SELECT name, SUM(p.amount)
FROM category c
INNER JOIN film_category fc
INNER JOIN inventory i
ON i.film_id = fc.film_id
INNER JOIN rental r
ON r.inventory_id = i.inventory_id
INNER JOIN payment p
GROUP BY name
LIMIT 5;

-- 8b. How would you display the view that you created in 8a?

SELECT * FROM top_five_grossing_genres;

-- 8c. You find that you no longer need the view top_five_genres. 
-- Write a query to delete it.

DROP VIEW top_five_grossing_genres;