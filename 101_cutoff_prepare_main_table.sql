# creates a table with cutoff_hours
DROP TABLE IF EXISTS cutoff_hours;
CREATE TABLE cutoff_hours (
   cutoff_hour double unsigned PRIMARY KEY
);

INSERT INTO cutoff_hours VALUES (1); INSERT INTO cutoff_hours VALUES (2);
INSERT INTO cutoff_hours VALUES (3); INSERT INTO cutoff_hours VALUES (4);
INSERT INTO cutoff_hours VALUES (5); INSERT INTO cutoff_hours VALUES (6);
INSERT INTO cutoff_hours VALUES (7); INSERT INTO cutoff_hours VALUES (8);
INSERT INTO cutoff_hours VALUES (9); INSERT INTO cutoff_hours VALUES (10);
INSERT INTO cutoff_hours VALUES (11); INSERT INTO cutoff_hours VALUES (12);
INSERT INTO cutoff_hours VALUES (13); INSERT INTO cutoff_hours VALUES (14);
INSERT INTO cutoff_hours VALUES (15); INSERT INTO cutoff_hours VALUES (16);
INSERT INTO cutoff_hours VALUES (17); INSERT INTO cutoff_hours VALUES (18);
INSERT INTO cutoff_hours VALUES (19); INSERT INTO cutoff_hours VALUES (20);
INSERT INTO cutoff_hours VALUES (21); INSERT INTO cutoff_hours VALUES (22); 
INSERT INTO cutoff_hours VALUES (23);

/*
INSERT INTO cutoff_hours 
SELECT cutoff_hour + 0.1 FROM cutoff_hours UNION ALL
SELECT cutoff_hour + 0.2 FROM cutoff_hours UNION ALL
SELECT cutoff_hour + 0.3 FROM cutoff_hours UNION ALL
SELECT cutoff_hour + 0.4 FROM cutoff_hours UNION ALL
SELECT cutoff_hour + 0.5 FROM cutoff_hours UNION ALL
SELECT cutoff_hour + 0.6 FROM cutoff_hours UNION ALL
SELECT cutoff_hour + 0.7 FROM cutoff_hours UNION ALL
SELECT cutoff_hour + 0.8 FROM cutoff_hours UNION ALL
SELECT cutoff_hour + 0.9 FROM cutoff_hours;
*/

-- for testing purposes
INSERT INTO cutoff_hours 
SELECT cutoff_hour + 0.25 FROM cutoff_hours UNION ALL
SELECT cutoff_hour + 0.5 FROM cutoff_hours UNION ALL
SELECT cutoff_hour + 0.75 FROM cutoff_hours;
	
DELETE FROM cutoff_hours WHERE cutoff_hour > 24;
UPDATE cutoff_hours SET cutoff_hour = cutoff_hour * 60; -- convert to minutes

CREATE UNIQUE INDEX I ON cutoff_hours (cutoff_hour) USING BTREE;

# creates a table with testing cutoff times
# for testset the cutoffs used 
DROP TABLE IF EXISTS test_cutoffs;
CREATE TABLE test_cutoffs as
SELECT dt, in_mins(max(date_time_recorded_utc), dt) as cutoff 
FROM flighthistoryevents_transformed 
WHERE dt in (SELECT dt FROM dates_info WHERE obs_type in ('PublicLeaderboard','FinalTest'))
GROUP BY dt;
CREATE UNIQUE INDEX I ON test_cutoffs (dt);

INSERT INTO cutoff_hours SELECT cutoff FROM test_cutoffs;

# creates a table with flight in air in each cutoff hour or flights in testing data
# this is a main training data table
DROP TABLE IF EXISTS flighthistory_cutoffs;
CREATE TABLE flighthistory_cutoffs (
	id INT NOT NULL AUTO_INCREMENT,
	dt date,
	flight_history_id int unsigned,
	cutoff_hour double,
	obs_type varchar(20),
	leaderboard_public tinyint unsigned,
	leaderboard_private tinyint unsigned,
	PRIMARY KEY (id)
);

# creates dates of creation
DROP TABLE IF EXISTS flights_recordcreation;
CREATE TEMPORARY TABLE flights_recordcreation as
SELECT dt, flight_history_id, max(date_time_recorded_utc) as recordcreated
FROM flighthistoryevents_transformed 
GROUP BY dt, flight_history_id;
CREATE UNIQUE INDEX I ON flights_recordcreation (dt, flight_history_id);

INSERT INTO flighthistory_cutoffs (dt, flight_history_id, cutoff_hour, obs_type, leaderboard_public)
SELECT
	a.dt, 
	a.flight_history_id, 
	cutoff_hour,
	dates_info.obs_type,
	CASE WHEN d.flight_history_id IS NOT NULL and cutoff_hour = c.cutoff THEN 1 ELSE 0 END as leaderboard_public
FROM
	flighthistory as a
	INNER JOIN cutoff_hours as b ON 1 = 1
	INNER JOIN dates_info ON a.dt = dates_info.dt
	LEFT JOIN test_cutoffs as c ON a.dt = c.dt 
	LEFT JOIN test_flights_public as d ON a.flight_history_id = d.flight_history_id
WHERE
    (
		a.dt in (SELECT dt FROM dates_info WHERE obs_type in ('Training'))
		and
		cutoff_hour between in_mins(actual_runway_departure, a.dt) and in_mins(actual_runway_arrival, a.dt)
    )
    or
    (
		a.dt in (SELECT dt FROM dates_info WHERE obs_type <> ('Training'))
		and 
		cutoff_hour <= c.cutoff
		and
		cutoff_hour between in_mins(actual_runway_departure, a.dt) and in_mins(actual_runway_arrival, a.dt)
	)
	or 
	d.flight_history_id IS NOT NULL and cutoff_hour = c.cutoff
ORDER BY                                   
	a.dt, flight_history_id, cutoff_hour;
CREATE UNIQUE INDEX I ON flighthistory_cutoffs (dt, flight_history_id, cutoff_hour);

-- add some cached information
ALTER TABLE flighthistory_cutoffs ADD COLUMN arrival_airport_icao_code varchar(4);
ALTER TABLE flighthistory_cutoffs ADD COLUMN airline_icao_code varchar(4);
ALTER TABLE flighthistory_cutoffs ADD COLUMN icao_aircraft_type_actual varchar(4);

UPDATE flighthistory_cutoffs as a INNER JOIN flighthistory as b
	ON a.flight_history_id = b.flight_history_id and a.dt = b.dt
SET a.arrival_airport_icao_code = b.arrival_airport_icao_code
	,a.airline_icao_code = b.airline_icao_code
	,a.icao_aircraft_type_actual = b.icao_aircraft_type_actual;