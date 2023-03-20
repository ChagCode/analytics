--ЗАДАНИЕ №1
--Для каждого покупателя посчитайте сколько он брал в аренду фильмов 
--со специальным атрибутом "Behind the Scenes.
                     -- способ 1
with cte1 as (
	select film_id , title , special_features
	from film f
	where  'Behind the Scenes' = ANY(special_features)
)

select customer_id, count(film_id) as count_film
from customer c 
join rental r using(customer_id)
join inventory i using(inventory_id)
join cte1 using(film_id)
group by customer_id
order by customer_id;

                     -- способ 2
select customer_id, count(*) as count_film
from customer c 
join rental r using(customer_id)
join inventory i using(inventory_id)
join (select film_id , title , special_features
	  from film f
	  where  'Behind the Scenes' = ANY(special_features)
	 ) as subquery2 using(film_id)
group by customer_id
order by customer_id;


--ЗАДАНИЕ №2
--Создайте материализованное представление с запросом из предыдущего задания
--и напишите запрос для обновления материализованного представления

create materialized view mtrl_view_film AS 
	select customer_id, count(*) as count_film
	from customer c 
	join rental r using(customer_id)
	join inventory i using(inventory_id)
	join (select film_id , title , special_features
		  from film f
		  where  'Behind the Scenes' = ANY(special_features)
		 ) as subquery1 using(film_id)
	group by customer_id
	order by customer_id
WITH NO DATA;

REFRESH MATERIALIZED VIEW mtrl_view_film;

--ЗАДАНИЕ №3
--С помощью explain analyze проведите анализ скорости выполнения запросов
-- из предыдущих заданий и ответьте на вопросы:
-- ......
--2. какой вариант вычислений работает быстрее: 
--   с использованием CTE или с использованием подзапроса

											ОТВЕТ: с использованием CTE вычисление работает быстрее.
explain analyze 
select customer_id, count(film_id) as count_film
from (
	select film_id , title , special_features
	from film f
	where  'Behind the Scenes' = ANY(special_features)
	) as subquery2
join inventory i using(film_id)
join rental r using(inventory_id)
join customer c using(customer_id)
group by customer_id
order by customer_id;

--Planning Time: 7.645 ms
--Execution Time: 9.542 ms

explain analyze
select customer_id, count(*) as count_film
from customer c 
join rental r using(customer_id)
join inventory i using(inventory_id)
join (select film_id , title , special_features
	  from film f
	  where  'Behind the Scenes' = ANY(special_features)
	 ) as subquery1 using(film_id)
group by customer_id
order by customer_id;

--Planning Time: 0.536 ms
--Execution Time: 9.064 ms

explain analyze
with cte1 as (
	select film_id , title , special_features
	from film f
	where  'Behind the Scenes' = ANY(special_features)
)

select customer_id, count(film_id) as count_film
from customer c 
join rental r using(customer_id)
join inventory i using(inventory_id)
join (select film_id , title , special_features
	  from film f
	  where  'Behind the Scenes' = ANY(special_features)
	 ) as subquery1 using(film_id)
group by customer_id
order by customer_id;

-- Planning Time: 0.516 ms
-- Execution Time: 8.818 ms

--ЗАДАНИЕ №4
--Используя оконную функцию выведите для каждого сотрудника
--сведения о самой первой продаже этого сотрудника.
select  staff_id, film_id, title, amount, payment_date, customer_last_name, customer_first_name
from 
	(select s.staff_id as staff_id, 
			film_info.film_id as film_id, 
			film_info.title as title, 
			cus.amount as amount, 
			cus.payment_date as payment_date, 
			cus.customer_last_name as customer_last_name, 
			cus.customer_first_name as customer_first_name,
			row_number() over(partition by staff_id order by payment_date) as numb_pay
	from staff s 
	join (
			select  p.staff_id as staff_id,
					p.payment_id, 
					p.payment_date, 
					c.last_name as customer_last_name, 
					c.first_name as customer_first_name,
					p.amount
			from payment p
			join customer c USING(customer_id)
		 ) as cus using(staff_id)
	join (
			select *
			from store st
			join (
				 	select film_id, store_id, title
				 	from inventory i 
				 	join film f2 using(film_id)
				 ) as f using(store_id)
		 ) as film_info on s.staff_id = film_info.manager_staff_id) as subquery
where numb_pay = 1;

--ЗАДАНИЕ №5
--Для каждого магазина определите и выведите одним SQL-запросом следующие аналитические показатели:
-- 1. день, в который арендовали больше всего фильмов (день в формате год-месяц-день)
-- 2. количество фильмов взятых в аренду в этот день
-- 3. день, в который продали фильмов на наименьшую сумму (день в формате год-месяц-день)
-- 4. сумму продажи в этот день
									-- ИТОГО!!!

select store_id, top_day, max_nht, bad_day, sale_min
from (
	select store_id, rental_date as bad_day, sale_min
	from( 
		select  store_id, rental_date, sale_min,
				row_number() over(partition by store_id order by sale_min) as sale_weight
		from (
			select store_id, rental_date, min(sum_sale) as sale_min
			from (
				select  store_id,
						rental_date::date as rental_date,
						sum(amount) over(partition by store_id order by rental_date::date) as sum_sale
				from rental r
				join (select store_id, inventory_id
				  	  from inventory i
				  	  join store s using(store_id)) as subquery5 using(inventory_id)
				join payment p using(rental_id)) as subquery6
			group by store_id, rental_date) subquey7) as subquery8
		where sale_weight = 1) as sub1
join (
	select store_id, rental_date as top_day, max_nht
	from (
		select  store_id, rental_date, max_nht, 
				row_number() over(partition by store_id order by max_nht DESC) as weight
		from(
			select store_id, rental_date, max(nht) as max_nht
			from (select  store_id,
					rental_date::date as rental_date,
					row_number() over(partition by store_id, rental_date::date) as nht
				  from rental r
				  join (select store_id, inventory_id
					    from inventory i
					    join store s using(store_id)) as subquery1 using(inventory_id)) as subquery2
			group by store_id, rental_date) as subquery3) as subquery4
	where weight = 1) as sub2 using(store_id);

