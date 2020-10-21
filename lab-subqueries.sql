
## Lab | SQL Subqueries

use sakila;

# 1. How many copies of the film Hunchback Impossible exist in the inventory system?

SELECT a.film_id AS Film_ID, a.title AS Title, COUNT(b.inventory_id) AS Inventory
FROM sakila.inventory AS b 
JOIN (SELECT film_id, title FROM sakila.film
WHERE title = 'Hunchback Impossible') AS a ON a.film_id = b.film_id;

# 2. List all films longer than the average.

select*from(
select film_id, title, length
from sakila.film 
group by film_id) as L1
where length> (select round(avg(length),2) as Average_Length 
from (select film_id, title, length
from sakila.film 
group by film_id) as L2)
 order by length desc;
 
 # 3. Use subqueries to display all actors who appear in the film Alone Trip.

select a.actor_id, a.first_name, a.last_name, c.film_id, c.title from sakila.actor as a 
join (select actor_id, film_id 
from sakila.film_actor) as b
on b.actor_id=a.actor_id
join (SELECT film_id, title 
FROM sakila.film
WHERE title = 'Alone Trip') as c 
on c.film_id = b.film_id;

# 4. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
# Identify all movies categorized as family films.

select c.category_id, c.name, a.film_id, a.title from sakila.film as a 
join (select film_id, category_id from sakila.film_category) as b
on b.film_id = a.film_id
join (select category_id, name from sakila.category where name = 'family') as c
on c.category_id = b.category_id;

# 5 Get name and email from customers from Canada using subqueries. Do the same with joins.

select d.country_id, d.country, a.customer_id, concat(a.first_name,' ',a.last_name) as 'Full name', a.email 
from sakila.customer as a 
join (select address_id, city_id 
from sakila.address) as b
on b.address_id = a.address_id
join (select city_id, country_id 
from sakila.city) as c
on c.city_id = b.city_id
join (select country_id, country 
from sakila.country where country = 'Canada') as d
on d.country_id = c.country_id;

# 6 Which are films starred by the most prolific actor?

select title from film where film_id in
(select film_id from film_actor where actor_id =
(select actor_id from
(select actor_id, count(*) as mycount 
from film_actor group by actor_id order by mycount desc limit 1) as c)
);

# 7 Films rented by most profitable customer.

select e.film_id, e.title, b.customer_id, concat(first_name,' ',last_name) as 'Full name'
from sakila.customer as a
join (select payment_id, customer_id, rental_id, sum(amount) as 'Amount_spent' 
from sakila.payment group by customer_id order by Amount_spent desc limit 1) as b
on b.customer_id = a.customer_id 
join sakila.rental as c
on c.customer_id = b.customer_id
join sakila.inventory as d
on d.inventory_id = c.inventory_id
join sakila.film as e
on e.film_id = d.film_id
group by e.film_id;

### too many variables inside of the subquerie###
#select *
#from sakila.customer as a
#join (select payment_id, customer_id, rental_id, sum(amount) as 'Amount_spent' 
#from sakila.payment group by customer_id order by Amount_spent desc limit 1) as b
#on b.customer_id = a.customer_id 
#join (select rental_id, customer_id, inventory_id 
#from sakila.rental) as c
#on c.customer_id = b.customer_id
#join (select inventory_id, film_id 
#from sakila.inventory) as d
#on d.inventory_id = c.inventory_id
#join (select film_id, title 
#from sakila.film) as e
#on e.film_id = d.film_id;

# 8 Customers who spent more than the average.

SET sql_mode=(SELECT REPLACE(@@sql_mode, 'ONLY_FULL_GROUP_BY', ''));

select concat(customer.first_name,' ',customer.last_name) as customer_name, round(sum(amount),2) as amount_spent from sakila.customer
join sakila.payment on payment.customer_id = customer.customer_id
group by customer_name
having amount_spent > (select avg(amount_spent) 
from (select concat(customer.first_name,' ',customer.last_name) as customer_name, round(sum(amount),2) as amount_spent 
from sakila.customer
join sakila.payment on payment.customer_id= customer.customer_id
group by customer_name) as sub1) order by amount_spent;



