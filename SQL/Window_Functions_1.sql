--ЗАДАНИЕ
--Сделайте запрос к таблице payment и с помощью оконных функций добавьте вычисляемые колонки согласно условиям:
--Пронумеруйте все платежи от 1 до N по дате
--Пронумеруйте платежи для каждого покупателя, сортировка платежей должна быть по дате
--Посчитайте нарастающим итогом сумму всех платежей для каждого покупателя, сортировка должна 
--быть сперва по дате платежа, а затем по сумме платежа от наименьшей к большей
--Пронумеруйте платежи для каждого покупателя по стоимости платежа от наибольших к меньшим 
--так, чтобы платежи с одинаковым значением имели одинаковое значение номера.
--Можно составить на каждый пункт отдельный SQL-запрос, а можно объединить все колонки в одном запросе.

select customer_id , payment_id , payment_date, amount, nth, rank_cust, sum_cust, 
		dense_rank() over(partition by customer_id order by amount DESC) as rank_amount
from (
		select customer_id , payment_id , payment_date, amount, nth, rank_cust,
		sum(amount) over (partition by customer_id order by payment_date) as sum_cust
		from (
				select customer_id , payment_id , payment_date , amount, nth, 
				row_number () over (partition by customer_id order by payment_date) as rank_cust
				from 
					(
					select payment_id , customer_id , amount , payment_date ,
						row_number () over (order by payment_date) as nth
					from payment p
					) as subquery1
			 ) as subquery2
		order by sum_cust
	) as subquery3;