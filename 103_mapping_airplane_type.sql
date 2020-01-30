DROP TABLE IF EXISTS mapping_airplane_type_speeds;
CREATE TEMPORARY TABLE mapping_airplane_type_speeds
as
SELECT 
	icao_aircraft_type_actual, 
	round(groundspeed/10.0,0)*10 as speed, 
	count(*) obs_count
FROM flightquest.asdiposition_clean as a
	 INNER JOIN flighthistory as b
		ON a.dt = b.dt and a.flighthistoryid = b.flight_history_id
WHERE a.dt in (SELECT dt FROM dates_info WHERE obs_type in ('Training')) 
GROUP BY 
	icao_aircraft_type_actual,
	round(groundspeed/10.0,0)*10;

DROP TABLE IF EXISTS mapping_airplane_type_altitude;
CREATE TEMPORARY TABLE mapping_airplane_type_altitude
as
SELECT 
	icao_aircraft_type_actual, 
	round(altitude/100.0,0)*100 as altitude, 
	count(*) obs_count
FROM flightquest.asdiposition_clean as a
	 INNER JOIN flighthistory as b
		ON a.dt = b.dt and a.flighthistoryid = b.flight_history_id
WHERE a.dt in (SELECT dt FROM dates_info WHERE obs_type in ('Training')) 
GROUP BY 
	icao_aircraft_type_actual,
	round(altitude/100.0,0)*100;

DROP TABLE IF EXISTS mapping_airplane_type_speeds2;
CREATE TEMPORARY TABLE mapping_airplane_type_speeds2 as SELECT * FROM mapping_airplane_type_speeds;

DROP TABLE IF EXISTS mapping_airplane_type_altitude2;
CREATE TEMPORARY TABLE mapping_airplane_type_altitude2 as SELECT * FROM mapping_airplane_type_altitude;

DROP TABLE IF EXISTS mapping_airplane_type;
CREATE TABLE mapping_airplane_type
as 
SELECT 
	 x.icao_aircraft_type_actual
	,COALESCE(speed_a.max_speed, speed_b.max_speed) as max_speed
	,COALESCE(altitude_a.max_altitude, altitude_b.max_altitude) as max_altitude
FROM 
	(SELECT DISTINCT icao_aircraft_type_actual FROM flighthistory) as x
	LEFT JOIN 
	(
		SELECT icao_aircraft_type_actual, max(speed) as max_speed
		FROM mapping_airplane_type_speeds
		WHERE length(icao_aircraft_type_actual) > 1 and obs_count > 100
		GROUP BY icao_aircraft_type_actual
	) as speed_a
		ON speed_a.icao_aircraft_type_actual = x.icao_aircraft_type_actual
	LEFT JOIN 
	(
		SELECT icao_aircraft_type_actual, max(altitude) as max_altitude
		FROM mapping_airplane_type_altitude
		WHERE length(icao_aircraft_type_actual) > 1 and obs_count > 100
		GROUP BY icao_aircraft_type_actual
	) as altitude_a
		ON altitude_a.icao_aircraft_type_actual = x.icao_aircraft_type_actual
	LEFT JOIN 
	(
		SELECT icao_aircraft_type_actual, max(speed) as max_speed
		FROM mapping_airplane_type_speeds2
		WHERE length(icao_aircraft_type_actual) > 1 and obs_count > 10
		GROUP BY icao_aircraft_type_actual
	) as speed_b
		ON speed_b.icao_aircraft_type_actual = x.icao_aircraft_type_actual
	LEFT JOIN 
	(
		SELECT icao_aircraft_type_actual, max(altitude) as max_altitude
		FROM mapping_airplane_type_altitude2
		WHERE length(icao_aircraft_type_actual) > 1 and obs_count > 10
		GROUP BY icao_aircraft_type_actual
	) as altitude_b
		ON altitude_b.icao_aircraft_type_actual = x.icao_aircraft_type_actual
WHERE
	length(x.icao_aircraft_type_actual) > 1;

CREATE UNIQUE INDEX I ON mapping_airplane_type (icao_aircraft_type_actual);

