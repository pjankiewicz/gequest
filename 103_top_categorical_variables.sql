
DROP TABLE IF EXISTS top_aircraft;
CREATE TABLE top_aircraft
as
SELECT icao_aircraft_type_actual as aircraft_code, AVG(in_mins(actual_runway_arrival,actual_gate_arrival)) as avg_gate_delay, AVG(in_mins(scheduled_runway_arrival,actual_runway_arrival)) as avg_runway_delay, COUNT(*) as flight_count FROM flighthistory 
WHERE dt in (SELECT dt FROM dates_info WHERE obs_type = 'Training') AND 
	  scheduled_gate_arrival <> '0000-00-00 00:00:00' and 
	  scheduled_runway_arrival <> '0000-00-00 00:00:00' and 
	  actual_runway_arrival <> '0000-00-00 00:00:00' and 
	  actual_gate_arrival <> '0000-00-00 00:00:00' and 
	  exclude = 0
GROUP BY icao_aircraft_type_actual
HAVING COUNT(*) >= 100;
CREATE UNIQUE INDEX I ON top_aircraft (aircraft_code);

DROP TABLE IF EXISTS top_airline;
CREATE TABLE top_airline
as
SELECT airline_code, AVG(in_mins(actual_runway_arrival,actual_gate_arrival)) as avg_gate_delay, AVG(in_mins(scheduled_runway_arrival,actual_runway_arrival)) as avg_runway_delay, COUNT(*) as flight_count
FROM flighthistory 
WHERE dt in (SELECT dt FROM dates_info WHERE obs_type = 'Training') AND 
	  scheduled_gate_arrival <> '0000-00-00 00:00:00' and 
	  scheduled_runway_arrival <> '0000-00-00 00:00:00' and 
	  actual_runway_arrival <> '0000-00-00 00:00:00' and 
	  actual_gate_arrival <> '0000-00-00 00:00:00' and 
	  exclude = 0
GROUP BY airline_code
HAVING COUNT(*) >= 100;
CREATE UNIQUE INDEX I ON top_airline (airline_code);

DROP TABLE IF EXISTS top_airport;
CREATE TABLE top_airport
as
SELECT arrival_airport_icao_code as airport_code, AVG(in_mins(actual_runway_arrival,actual_gate_arrival)) as avg_gate_delay, AVG(in_mins(scheduled_runway_arrival,actual_runway_arrival)) as avg_runway_delay, COUNT(*) as flight_count 
FROM flighthistory 
WHERE dt in (SELECT dt FROM dates_info WHERE obs_type = 'Training') AND 
	  scheduled_gate_arrival <> '0000-00-00 00:00:00' and 
	  scheduled_runway_arrival <> '0000-00-00 00:00:00' and 
	  actual_runway_arrival <> '0000-00-00 00:00:00' and 
	  actual_gate_arrival <> '0000-00-00 00:00:00' and 
	  exclude = 0
GROUP BY arrival_airport_icao_code
HAVING COUNT(*) >= 100;
CREATE UNIQUE INDEX I ON top_airport (airport_code);

/*
SELECT concat(departure_airport_code,'_',arrival_airport_code) as route, COUNT(*) as flight_count FROM flighthistory 
WHERE dt <= '2012-12-25'
GROUP BY concat(departure_airport_code,'_',arrival_airport_code)
HAVING COUNT(*) >= 1000;
CREATE UNIQUE INDEX I ON top_airport (airport_code)
*/
