-- 
DROP TABLE IF EXISTS flightstats_atsccdelay_cutoffs;
CREATE TABLE flightstats_atsccdelay_cutoffs as
SELECT
	c.dt,
	c.airport_code,
    a.cutoff_hour,
	c.type,
	MAX(capture_time) as max_capture_time,
	CAST(NULL as unsigned integer) as id
FROM 
	flightquest.cutoff_hours as a
	INNER JOIN flightstats_atsccdelay as c
		on in_mins(c.capture_time,c.dt) < a.cutoff_hour
GROUP BY
	c.dt,
	c.airport_code,
        a.cutoff_hour,
	c.type;

CREATE UNIQUE INDEX I ON flightstats_atsccdelay_cutoffs (dt, airport_code, cutoff_hour, type);

UPDATE flightstats_atsccdelay_cutoffs as a
	INNER JOIN flightstats_atsccdelay as b
		ON a.dt = b.dt and a.airport_code = b.airport_code and a.max_capture_time = b.capture_time
SET
	a.id = b.id;

ALTER TABLE flighthistory_cutoffs ADD COLUMN atsccdelay_arrivals_id INTEGER;
ALTER TABLE flighthistory_cutoffs ADD COLUMN atsccdelay_departures_id INTEGER;

UPDATE flighthistory_cutoffs SET atsccdelay_arrivals_id = NULL;
UPDATE flighthistory_cutoffs SET atsccdelay_departures_id = NULL;

UPDATE flighthistory_cutoffs as a
	INNER JOIN flighthistory as b
		ON a.dt = b.dt and a.flight_history_id = b.flight_history_id
	INNER JOIN flightstats_atsccdelay_cutoffs as c
		ON a.dt = c.dt and b.arrival_airport_code = c.airport_code and a.cutoff_hour = c.cutoff_hour
SET
	a.atsccdelay_arrivals_id = CASE WHEN c.type = 'A' THEN c.id ELSE NULL END
   ,a.atsccdelay_departures_id = CASE WHEN c.type = 'D' THEN c.id ELSE NULL END;

-- grounddelay
DROP TABLE IF EXISTS flightstats_atsccgrounddelay_cutoffs;
CREATE TABLE flightstats_atsccgrounddelay_cutoffs as
SELECT
	c.dt,
	c.airport_code,
    a.cutoff_hour,
	MAX(signature_time) as max_signature_time,
	CAST(NULL as unsigned integer) as id
FROM 
	flightquest.cutoff_hours as a
	INNER JOIN flightstats_atsccgrounddelay as c
		on in_mins(c.signature_time,c.dt) < a.cutoff_hour
GROUP BY
	c.dt,
	c.airport_code,
    a.cutoff_hour;

CREATE UNIQUE INDEX I ON flightstats_atsccgrounddelay_cutoffs (dt, airport_code, cutoff_hour);

UPDATE flightstats_atsccgrounddelay_cutoffs as a
	INNER JOIN flightstats_atsccgrounddelay as b
		ON a.dt = b.dt and a.airport_code = b.airport_code and a.max_signature_time = b.signature_time
SET
	a.id = b.id;

ALTER TABLE flighthistory_cutoffs ADD COLUMN atsccgrounddelay_id INTEGER;
UPDATE flighthistory_cutoffs SET atsccgrounddelay_id = NULL;

UPDATE flighthistory_cutoffs as a
	INNER JOIN flighthistory as b
		ON a.dt = b.dt and a.flight_history_id = b.flight_history_id
	INNER JOIN flightstats_atsccgrounddelay_cutoffs as c
		ON a.dt = c.dt and b.arrival_airport_code = c.airport_code and a.cutoff_hour = c.cutoff_hour
SET
	a.atsccgrounddelay_id = c.id;

-- grounddelay - radius
DROP TABLE IF EXISTS atsccgrounddelay_radius_airports;
CREATE TEMPORARY TABLE atsccgrounddelay_radius_airports
as
SELECT DISTINCT
	 c.id
	,airports_in_radius.airport_code
	,GeoDistMiles(airport_center.latitude, airport_center.longitude,
						airports_in_radius.latitude, airports_in_radius.longitude) as distance
FROM
	flightstats_atsccgrounddelay as c
	INNER JOIN mapping_airports as airport_center
		ON c.airport_code = RIGHT(airport_center.airport_code,3)
	INNER JOIN mapping_airports as airports_in_radius
		ON GeoDistMiles(airport_center.latitude, airport_center.longitude,
						airports_in_radius.latitude, airports_in_radius.longitude) <= c.radius_of_airports_included
		   OR airport_center.airport_code = airports_in_radius.airport_code;

CREATE UNIQUE INDEX I ON atsccgrounddelay_radius_airports (id,airport_code,distance);

DROP TABLE IF EXISTS flightstats_atsccgrounddelay_radius_cutoffs;
CREATE TABLE flightstats_atsccgrounddelay_radius_cutoffs as
SELECT
	c.dt,
	d.airport_code,
    a.cutoff_hour,
	MIN(distance) as distance_to_center,
	MAX(signature_time) as max_signature_time,
	CAST(NULL as unsigned integer) as id
FROM 
	flightquest.cutoff_hours as a
	INNER JOIN flightstats_atsccgrounddelay as c
		on in_mins(c.signature_time,c.dt) < a.cutoff_hour
	INNER JOIN atsccgrounddelay_radius_airports as d
		on c.id = d.id
GROUP BY
	c.dt,
	d.airport_code,
    a.cutoff_hour;

CREATE UNIQUE INDEX I ON flightstats_atsccgrounddelay_radius_cutoffs (dt, airport_code, cutoff_hour);

UPDATE flightstats_atsccgrounddelay_radius_cutoffs as a
	INNER JOIN flightstats_atsccgrounddelay as b
		ON a.dt = b.dt and a.max_signature_time = b.signature_time
SET
	a.id = b.id;

ALTER TABLE flighthistory_cutoffs ADD COLUMN atsccgrounddelay_radius_id INTEGER;
UPDATE flighthistory_cutoffs SET atsccgrounddelay_radius_id = NULL;

ALTER TABLE flighthistory_cutoffs ADD COLUMN atsccgrounddelay_radius_distance INTEGER;
UPDATE flighthistory_cutoffs SET atsccgrounddelay_radius_distance = NULL;

UPDATE flighthistory_cutoffs as a
	INNER JOIN flighthistory as b
		ON a.dt = b.dt and a.flight_history_id = b.flight_history_id
	INNER JOIN flightstats_atsccgrounddelay_radius_cutoffs as c
		ON a.dt = c.dt and 
		   b.arrival_airport_icao_code = c.airport_code and 
		   a.cutoff_hour = c.cutoff_hour
SET
	a.atsccgrounddelay_radius_id = c.id, a.atsccgrounddelay_radius_distance = distance_to_center;

/*
SELECT 	
	 a.LAST_ERA_CASCADE_TYPE
	,CASE WHEN b.dt IS NOT NULL 
	 and LAST_ERA_CASCADE >= in_mins(c.start_time,b.dt) - 60
	 and (c.end_time = '0000-00-00 00:00:00' OR LAST_ERA_CASCADE < in_mins(c.end_time,b.dt)+60) THEN 'Y' ELSE 'N' END
	,avg(LAST_ERA_CASCADE - T_ARA)
	,sqrt(avg(power(LAST_ERA_CASCADE - T_ARA,2))) as err
	,COUNT(*) as cnt
FROM
	data_v1 as a
	LEFT JOIN flighthistory_cutoffs as b
		ON a.T_dt = b.dt and a.T_flight_history_id = b.flight_history_id and a.cutoff_hour = b.cutoff_hour
	LEFT JOIN flightstats_atsccdelay as c
		ON b.atsccgrounddelay_radius_id = c.id
WHERE
	T_ARA IS NOT NULL and a.T_dt >= '2012-11-25'
GROUP BY
	a.LAST_ERA_CASCADE_TYPE
	,CASE WHEN b.dt IS NOT NULL 
	 and LAST_ERA_CASCADE >= in_mins(c.start_time,b.dt) - 60
	 and (c.end_time = '0000-00-00 00:00:00' OR LAST_ERA_CASCADE < in_mins(c.end_time,b.dt)+60) THEN 'Y' ELSE 'N' END;


SELECT 	
	 a.LAST_ERA_CASCADE_TYPE
	,CASE WHEN b.dt IS NOT NULL and LAST_ERA_CASCADE >= in_mins(c.start_time,b.dt) THEN 'Y' ELSE 'N' END
	,avg(LAST_ERA_CASCADE - T_ARA)
	,sqrt(avg(power(LAST_ERA_CASCADE - T_ARA,2))) as err
	,COUNT(*) as cnt
FROM
	data_v1 as a
	LEFT JOIN flighthistory_cutoffs as b
		ON a.T_dt = b.dt and a.T_flight_history_id = b.flight_history_id and a.cutoff_hour = b.cutoff_hour
	LEFT JOIN flightstats_atsccdelay as c
		ON b.atsccgrounddelay_radius_id = c.id and b.atsccgrounddelay_radius_distance between 10 and 200
WHERE
	T_ARA IS NOT NULL and a.T_dt >= '2012-11-25' 
GROUP BY
	a.LAST_ERA_CASCADE_TYPE
	,CASE WHEN b.dt IS NOT NULL and LAST_ERA_CASCADE >= in_mins(c.start_time,b.dt) THEN 'Y' ELSE 'N' END;

SELECT 	
	a.LAST_ERA_CASCADE_TYPE,
	CASE WHEN b.dt IS NOT NULL 
	 and LAST_ERA_CASCADE >= in_mins(c.effective_start_time,b.dt)
	 and (c.effective_end_time = '0000-00-00 00:00:00' OR LAST_ERA_CASCADE <= in_mins(c.effective_end_time,b.dt)) THEN 'Y' ELSE 'N' END
	,avg(LAST_ERA_CASCADE - T_ARA)
	,sqrt(avg(power(LAST_ERA_CASCADE - T_ARA,2))) as err
	,COUNT(*) as cnt
FROM
	data_v1 as a
	LEFT JOIN flightstats_atsccgrounddelay_cutoffs as b
		ON a.T_dt = b.dt 
		   and RIGHT(a.T_arrival_airport_icao_code,3) = b.airport_code
		   and a.cutoff_hour = b.cutoff_hour
	LEFT JOIN flightstats_atsccgrounddelay as c
		ON c.dt = b.dt
		   AND c.id = b.id
WHERE
	T_ARA IS NOT NULL and a.T_dt >= '2012-11-25'
GROUP BY
	a.LAST_ERA_CASCADE_TYPE
	,CASE WHEN b.dt IS NOT NULL 
	 and LAST_ERA_CASCADE >= in_mins(c.effective_start_time,b.dt)
	 and (c.effective_end_time = '0000-00-00 00:00:00' OR LAST_ERA_CASCADE <= in_mins(c.effective_end_time,b.dt)) THEN 'Y' ELSE 'N' END;


SELECT 	
	a.LAST_ERA_CASCADE_TYPE
	,CASE WHEN b.dt IS NOT NULL and LAST_ERA_CASCADE between in_mins(c.arrivals_estimated_for_start_time,b.dt) and in_mins(c.arrivals_estimated_for_end_time,b.dt) THEN 'Y' ELSE 'N' END
	,avg(LAST_ERA_CASCADE - T_ARA)
	,sqrt(avg(power(LAST_ERA_CASCADE - T_ARA,2))) as err
	,COUNT(*) as cnt
FROM
	data_v1 as a
	LEFT JOIN flightstats_atsccgrounddelay_cutoffs as b
		ON a.T_dt = b.dt 
		   and RIGHT(a.T_arrival_airport_icao_code,3) = b.airport_code
		   and a.cutoff_hour = b.cutoff_hour
	LEFT JOIN flightstats_atsccgrounddelay as c
		ON c.dt = b.dt
		   AND c.id = b.id
WHERE
	T_ARA IS NOT NULL and a.T_dt >= '2012-11-25'
GROUP BY
	a.LAST_ERA_CASCADE_TYPE
	,CASE WHEN b.dt IS NOT NULL and LAST_ERA_CASCADE between in_mins(c.arrivals_estimated_for_start_time,b.dt) and in_mins(c.arrivals_estimated_for_end_time,b.dt) THEN 'Y' ELSE 'N' END

*/
