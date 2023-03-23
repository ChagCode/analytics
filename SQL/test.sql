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
where count_model > 1;