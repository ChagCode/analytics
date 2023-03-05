--=============== МОДУЛЬ 3. ОСНОВЫ SQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выведите для каждого покупателя его адрес проживания, 
--город и страну проживания.

select concat(cus.last_name , ' ', cus.first_name) as user_name,
        a.address as street,
        city.city as city,
        country.country as country
from customer cus
join address a using(address_id)
join city using(city_id)
join country using(country_id);

--ЗАДАНИЕ №2
--С помощью SQL-запроса посчитайте для каждого магазина количество его покупателей.
select s.store_id as store,
        count(*) as count_user
from store s 
join customer c using(store_id)
group by store;

--Доработайте запрос и выведите только те магазины, 
--у которых количество покупателей больше 300-от.
--Для решения используйте фильтрацию по сгруппированным строкам 
--с использованием функции агрегации.
select s.store_id as store,
        count(customer_id) as count_user
from store s 
join customer c using(store_id)
group by store
having count(customer_id) > 300;

-- Доработайте запрос, добавив в него информацию о городе магазина, 
--а также фамилию и имя продавца, который работает в этом магазине.
select st.store_id as "ID магазина",
                st.count_user "Количество покупателей",
                st.city "Город",
                concat(staff.last_name, ' ', staff.first_name) as "Имя сотрудника"
from staff
join 
        (select s.store_id as store_id,
                        count(customer_id) as count_user,
                        a.address_id as address_id, 
                        c.city as city
         from store s
         join address a using(address_id)
         join city c using(city_id)
         join customer using(store_id)
         group by store_id, a.address_id, city
         having count(customer_id) > 300) as st using(store_id);

--ЗАДАНИЕ №3
--Выведите ТОП-5 покупателей, 
--которые взяли в аренду за всё время наибольшее количество фильмов
select concat(cus.last_name, ' ', cus.first_name) as "Фамилия Имя покупателя",
        rent.rental_count as "Количество фильмов"
from customer cus
join (
        select count(rental_id) as rental_count, customer_id
        from rental
        group by customer_id
     ) as rent using(customer_id)
order by rental_count desc
limit 5;

--ЗАДАНИЕ №4
--Посчитайте для каждого покупателя 4 аналитических показателя:
--  1. количество фильмов, которые он взял в аренду
--  2. общую стоимость платежей за аренду всех фильмов (значение округлите до целого числа)
--  3. минимальное значение платежа за аренду фильма
--  4. максимальное значение платежа за аренду фильма
--  5. от себя добавил средний чек, не ругайтесь сильно. Уж очень он сюда просился)))

select concat(cus.last_name, ' ', cus.first_name) as "Фамилия Имя покупателя",
        rent.rental_count as "Количество фильмов",
        pay.sum_pay as "Общая стоимость платежей",
        pay.min_pay as "Минимальная стоймость платежа",
        pay.max_pay as "Максимальная стоймость платежа",
        pay.avg_pay as "Средний чек"
from customer cus
join (
        select count(rental_id) as rental_count, customer_id
        from rental
        group by customer_id
     ) rent using(customer_id)
join (
        select round(sum(p.amount)) as sum_pay,
                min(p.amount) as min_pay,
                max(p.amount) as max_pay,
                round(avg(p.amount), 2) as avg_pay,
                customer_id
        from payment p
        group by customer_id
     ) as pay using(customer_id);

--ЗАДАНИЕ №5
--Используя данные из таблицы городов составьте одним запросом всевозможные пары городов таким образом,
 --чтобы в результате не было пар с одинаковыми названиями городов. 
 --Для решения необходимо использовать декартово произведение.
select c1.city, c2.city
from city c1
cross join city c2
where c1.city <> c2.city; -- забавное задание))

--ЗАДАНИЕ №6
--Используя данные из таблицы rental о дате выдачи фильма в аренду (поле rental_date)
--и дате возврата фильма (поле return_date), 
--вычислите для каждого покупателя среднее количество дней, за которые покупатель возвращает фильмы.
 select customer_id as "ID покупателя", 
        date_trunc('day', avg(diff_date)) as "Среднее дней на возврат" -- в этом месте ругается на длину названия столбца (мол, оно большое)
from (
        select  date_trunc('day', r.return_date - r.rental_date) as diff_date,
                r.customer_id
        from rental r
     ) as return_day
group by customer_id
order by customer_id;