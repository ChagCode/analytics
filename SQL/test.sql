-- найдем самолеты, которые летали только те дни, где из одного аэропорта таких самолетов вылетало более одного
select  departure_airport,
		scheduled_departure,
		count_seats		
from (
	select  f.departure_airport as departure_airport,
			f.scheduled_departure::date as scheduled_departure,
			sum(subquery1.count_seats) as count_seats,
			count(model) as count_model
	from flights f
	join (
			select  a.aircraft_code as aircraft_code,
			a.model as model,
			count(*) as count_seats
			from aircrafts a
			join seats s using(aircraft_code)
			group by aircraft_code, model		
		 ) as subquery1 using(aircraft_code)
	group by departure_airport, scheduled_departure
	order by scheduled_departure) as subquery2
where   count_model > 1;


-- посмотрим на тех кто сделал бронь, но не прошел регистрацию
select  t.ticket_no as ticket_no,
		subquery1.flight_id as flight_id
from tickets t
left join (	select tf.ticket_no as ticket_no, tf.flight_id as flight_id, bp.boarding_no as boarding_no
			from ticket_flights tf
			join boarding_passes bp using(ticket_no, flight_id)
		  ) as subquery1 using(ticket_no)
where flight_id is null;
