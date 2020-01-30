# different measures per airport
DROP TABLE IF EXISTS mapping_airports;
CREATE TABLE mapping_airports
as
SELECT
	 allcodes.airport_code as airport_code
	,d.flights_count as departures_count
	,a.flights_count as arrivals_count
	,COALESCE(coord1.latitude,coord2.latitude) as longitude
	,COALESCE(coord1.longitude,coord2.longitude) as latitude
	,coalesce(d.flights_count,0) + coalesce(a.flights_count,0) as all_flights_count
	,coalesce(dgates_count.number_of_gates,1) as `DGATE_COUNT`
	,coalesce(dterm_count.number_of_terminals,1) as `DTERM_COUNT`
	,coalesce(agates_count.number_of_gates,1) as `AGATE_COUNT`
	,coalesce(aterm_count.number_of_terminals,1) as `ATERM_COUNT`
FROM
	-- all airports
	(SELECT DISTINCT departure_airport_icao_code as airport_code FROM flighthistory
	 UNION
	 SELECT DISTINCT arrival_airport_icao_code as airport_code FROM flighthistory) as allcodes

	LEFT JOIN

	-- number of flights as departure
	(SELECT departure_airport_icao_code as airport_code, COUNT(*) as flights_count
	FROM flighthistory
	WHERE dt in (SELECT dt FROM dates_info WHERE obs_type in ('Training')) and departure_airport_icao_code IS NOT NULL AND exclude = 0
	GROUP BY departure_airport_icao_code) as d
		ON allcodes.airport_code = d.airport_code

	LEFT JOIN 
	
	-- number of flights as arrival
	(SELECT arrival_airport_icao_code as airport_code, COUNT(*) as flights_count
	FROM flighthistory
	WHERE dt in (SELECT dt FROM dates_info WHERE obs_type in ('Training')) and arrival_airport_icao_code IS NOT NULL AND exclude = 0
	GROUP BY arrival_airport_icao_code) as a
		ON allcodes.airport_code = a.airport_code
	
	LEFT JOIN 

	-- number of departure gates
	(
	 SELECT b.departure_airport_icao_code as airport_code, count(distinct new) as number_of_gates
	 FROM flighthistoryevents_transformed as a
		  INNER JOIN flighthistory as b
			 ON a.flight_history_id = b.flight_history_id and a.dt = b.dt AND exclude = 0
	 WHERE event_type = 'DGATE' and b.dt in (SELECT dt FROM dates_info WHERE obs_type in ('Training'))
	 GROUP BY b.departure_airport_icao_code
	) as dgates_count
		ON allcodes.airport_code = dgates_count.airport_code

	LEFT JOIN 

	-- number of departure terminals
	(
	 SELECT b.departure_airport_icao_code as airport_code, count(distinct new) as number_of_terminals
	 FROM flighthistoryevents_transformed as a
		  INNER JOIN flighthistory as b
			 ON a.flight_history_id = b.flight_history_id and a.dt = b.dt
	 WHERE event_type = 'DTERM' and b.dt in (SELECT dt FROM dates_info WHERE obs_type in ('Training')) AND exclude = 0
	 GROUP BY b.departure_airport_icao_code
        ) as dterm_count
		ON allcodes.airport_code = dterm_count.airport_code

	LEFT JOIN 

	-- number of arrival gates
	(
	 SELECT b.arrival_airport_icao_code as airport_code, count(distinct new) as number_of_gates
	 FROM flighthistoryevents_transformed as a
		  INNER JOIN flighthistory as b
			 ON a.flight_history_id = b.flight_history_id and a.dt = b.dt AND exclude = 0
	 WHERE event_type = 'AGATE' and b.dt in (SELECT dt FROM dates_info WHERE obs_type in ('Training'))
	 GROUP BY b.arrival_airport_icao_code
	 ) as agates_count
		ON allcodes.airport_code = agates_count.airport_code

	LEFT JOIN 

	-- number of departure terminals
	(
	 SELECT b.arrival_airport_icao_code as airport_code, count(distinct new) as number_of_terminals
	 FROM flighthistoryevents_transformed as a
		  INNER JOIN flighthistory as b
			 ON a.flight_history_id = b.flight_history_id and a.dt = b.dt AND exclude = 0
	 WHERE event_type = 'ATERM' and b.dt in (SELECT dt FROM dates_info WHERE obs_type in ('Training'))
	 GROUP BY b.arrival_airport_icao_code
	) as aterm_count
		ON allcodes.airport_code = aterm_count.airport_code

	LEFT JOIN mapping_airports_coordinates as coord1
		ON allcodes.airport_code = RIGHT(coord1.airport_code,3)

	LEFT JOIN mapping_airports_coordinates as coord2
		ON allcodes.airport_code = coord2.airport_code

WHERE
	allcodes.airport_code IS NOT NULL;
	-- AND
	-- coalesce(d.airport_code,a.airport_code) IS NOT NULL;

CREATE UNIQUE INDEX I ON mapping_airports (airport_code);
