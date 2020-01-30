# data split
# day, cutoff_hour, factor

# measures
# 1) avg/var/min/max(scheduled_runway_arrival,actual_runway_arrival)
# 2) avg/var/min/max(actual_gate_arrival,actual_runway_arrival)
# 3) avg/var/min/max(scheduled_gate_arrival,actual_gate_arrival)
# 4) count

# factors
# arrival_airport_code
# departure airport code
# airline_code
# icao_aircraft_type_actual

DROP TABLE IF EXISTS flighthistory_cutoffs_today_arrival_airport_code_measures;
CREATE TABLE flighthistory_cutoffs_today_arrival_airport_code_measures
as
SELECT
	 a.arrival_airport_icao_code
	,a.dt
	,b.cutoff_hour
	
	,count(*) as flight_count

	,avg(in_mins(scheduled_runway_arrival,actual_runway_arrival)) as avg_sra_minus_ara
	,std(in_mins(scheduled_runway_arrival,actual_runway_arrival)) as std_sra_minus_ara
	,min(in_mins(scheduled_runway_arrival,actual_runway_arrival)) as min_sra_minus_ara
	,max(in_mins(scheduled_runway_arrival,actual_runway_arrival)) as max_sra_minus_ara

	,avg(in_mins(actual_gate_arrival,actual_runway_arrival)) as avg_aga_minus_ara
	,std(in_mins(actual_gate_arrival,actual_runway_arrival)) as std_aga_minus_ara
	,min(in_mins(actual_gate_arrival,actual_runway_arrival)) as min_aga_minus_ara
	,max(in_mins(actual_gate_arrival,actual_runway_arrival)) as max_aga_minus_ara

	,avg(in_mins(scheduled_gate_arrival,actual_gate_arrival)) as avg_sga_minus_aga
	,std(in_mins(scheduled_gate_arrival,actual_gate_arrival)) as std_sga_minus_aga
	,min(in_mins(scheduled_gate_arrival,actual_gate_arrival)) as min_sga_minus_aga
	,max(in_mins(scheduled_gate_arrival,actual_gate_arrival)) as max_sga_minus_aga
FROM
	flighthistory as a, cutoff_hours as b
WHERE
	 '0000-00-00 00:00:00' NOT IN (a.actual_gate_arrival, a.scheduled_runway_arrival, a.actual_runway_arrival, a.scheduled_gate_arrival)
	AND
	in_mins(a.actual_gate_arrival,dt) < b.cutoff_hour
	AND
	actual_runway_arrival < actual_gate_arrival
GROUP BY
	 a.arrival_airport_code
	,a.dt
	,b.cutoff_hour;

CREATE UNIQUE INDEX I ON flighthistory_cutoffs_today_arrival_airport_code_measures (arrival_airport_icao_code, dt, cutoff_hour);


DROP TABLE IF EXISTS flighthistory_cutoffs_today_aircraft_type;
CREATE TABLE flighthistory_cutoffs_today_aircraft_type
as
SELECT
	 a.icao_aircraft_type_actual
	,a.dt
	,b.cutoff_hour
	,count(*) as flight_count
	,avg(in_mins(scheduled_runway_arrival,actual_runway_arrival)) as avg_sra_minus_ara
	,avg(in_mins(actual_gate_arrival,actual_runway_arrival)) as avg_aga_minus_ara
	,avg(in_mins(scheduled_gate_arrival,actual_gate_arrival)) as avg_sga_minus_aga
FROM
	flighthistory as a, cutoff_hours as b
WHERE
	 '0000-00-00 00:00:00' NOT IN (a.actual_gate_arrival, a.scheduled_runway_arrival, a.actual_runway_arrival, a.scheduled_gate_arrival)
	AND
	in_mins(a.actual_gate_arrival,dt) < b.cutoff_hour
	AND
	actual_runway_arrival < actual_gate_arrival
GROUP BY
	 a.icao_aircraft_type_actual
	,a.dt
	,b.cutoff_hour;
CREATE UNIQUE INDEX I ON flighthistory_cutoffs_today_aircraft_type (icao_aircraft_type_actual, dt, cutoff_hour);

DROP TABLE IF EXISTS flighthistory_cutoffs_today_airline;
CREATE TABLE flighthistory_cutoffs_today_airline
as
SELECT
	 a.airline_icao_code
	,a.dt
	,b.cutoff_hour
	,count(*) as flight_count
	,avg(in_mins(scheduled_runway_arrival,actual_runway_arrival)) as avg_sra_minus_ara
	,avg(in_mins(actual_gate_arrival,actual_runway_arrival)) as avg_aga_minus_ara
	,avg(in_mins(scheduled_gate_arrival,actual_gate_arrival)) as avg_sga_minus_aga
FROM
	flighthistory as a, cutoff_hours as b
WHERE
	 '0000-00-00 00:00:00' NOT IN (a.actual_gate_arrival, a.scheduled_runway_arrival, a.actual_runway_arrival, a.scheduled_gate_arrival)
	AND
	in_mins(a.actual_gate_arrival,dt) < b.cutoff_hour
	AND
	actual_runway_arrival < actual_gate_arrival
GROUP BY
	 a.airline_icao_code
	,a.dt
	,b.cutoff_hour;

CREATE UNIQUE INDEX I ON flighthistory_cutoffs_today_airline (airline_icao_code, dt, cutoff_hour);

-- last 60 minutes
DROP TABLE IF EXISTS flighthistory_cutoffs_today_arrival_airport_code_last_60_mins;
CREATE TABLE flighthistory_cutoffs_today_arrival_airport_code_last_60_mins
as
SELECT 
	 a.arrival_airport_icao_code,a.dt,b.cutoff_hour,count(*) as flight_count
	,avg(in_mins(scheduled_runway_arrival,actual_runway_arrival)) as avg_sra_minus_ara
	,avg(in_mins(actual_gate_arrival,actual_runway_arrival)) as avg_aga_minus_ara
	,avg(in_mins(scheduled_gate_arrival,actual_gate_arrival)) as avg_sga_minus_aga
FROM
	flighthistory as a, cutoff_hours as b
WHERE
	 '0000-00-00 00:00:00' NOT IN (a.actual_gate_arrival, a.scheduled_runway_arrival, a.actual_runway_arrival, a.scheduled_gate_arrival)
	AND
	in_mins(a.actual_gate_arrival,dt) between b.cutoff_hour - 60 and b.cutoff_hour
	AND
	actual_runway_arrival < actual_gate_arrival
GROUP BY
	 a.arrival_airport_code
	,a.dt
	,b.cutoff_hour;

CREATE UNIQUE INDEX I ON flighthistory_cutoffs_today_arrival_airport_code_last_60_mins (arrival_airport_icao_code, dt, cutoff_hour);

DROP TABLE flighthistory_cutoffs_today_route;
CREATE TABLE flighthistory_cutoffs_today_route
as
SELECT 
	 a.arrival_airport_icao_code
	,a.departure_airport_icao_code
	,a.dt,b.cutoff_hour,count(*) as flight_count
	,avg(in_mins(actual_runway_arrival,actual_runway_departure)) as avg_airtime
FROM
	flighthistory as a, cutoff_hours as b
WHERE
	 '0000-00-00 00:00:00' NOT IN (a.actual_gate_arrival, a.scheduled_runway_arrival, a.actual_runway_arrival, a.scheduled_gate_arrival)
	AND
	in_mins(a.actual_gate_arrival,dt) < b.cutoff_hour
	AND
	actual_runway_arrival < actual_gate_arrival
GROUP BY
	 a.arrival_airport_icao_code
	,a.departure_airport_icao_code
	,a.dt
	,b.cutoff_hour;

CREATE UNIQUE INDEX I ON flighthistory_cutoffs_today_route (arrival_airport_icao_code, departure_airport_icao_code, dt, cutoff_hour);
