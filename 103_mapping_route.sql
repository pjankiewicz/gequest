-- CREATE FUNCTION calc_distance_udf RETURNS REAL SONAME "calc_distance_udf.so";

DROP TABLE IF EXISTS mapping_route;
CREATE TABLE mapping_route
as
SELECT DISTINCT
	 departure_airport_icao_code
	,arrival_airport_icao_code
	,CAST(NULL as unsigned integer) as distance
	,CAST(NULL as decimal(8,4)) as bearing
FROM
	flighthistory;

UPDATE mapping_route as a
	INNER JOIN mapping_airports as arrival
		ON a.arrival_airport_icao_code = arrival.airport_code	
	INNER JOIN mapping_airports as departure
		ON a.departure_airport_icao_code = departure.airport_code	
SET
	a.distance = calc_distance_udf(arrival.latitude, arrival.longitude,
								   departure.latitude, departure.longitude),
	a.bearing = GeoBearing(arrival.latitude, arrival.longitude,
								   departure.latitude, departure.longitude)
WHERE
	arrival.latitude IS NOT NULL and
	arrival.longitude IS NOT NULL and
	departure.latitude IS NOT NULL and
	departure.longitude IS NOT NULL;

CREATE UNIQUE INDEX I ON mapping_route (departure_airport_icao_code, arrival_airport_icao_code);
