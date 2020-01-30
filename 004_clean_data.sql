-- DROP PROCEDURE IF EXISTS dummy;
-- delimiter //
-- create procedure dummy() 
-- begin

-- adds a flag obs_type
-- IF column_exists('flightquest','flighthistory','obs_type') THEN
-- 	ALTER TABLE flighthistory DROP COLUMN obs_type;
-- END IF;
ALTER TABLE flighthistory ADD COLUMN obs_type varchar(30);

UPDATE flighthistory
SET obs_type = CASE WHEN dt between '2012-11-12' and '2012-11-25' THEN 'Training'
                    WHEN dt between '2012-11-26' and '2012-12-09' THEN 'Training' 
                    WHEN dt between '2012-12-10' and '2013-01-02' THEN 'Training' 
                    WHEN dt between '2013-01-03' and '2013-02-06' THEN 'Training' 
                    WHEN dt between '2013-02-15' and '2013-02-28' THEN 'FinalTest' END;

-- creates a simple table with dates information whether we can use them or not in training
CREATE TABLE dates_info
as 
SELECT DISTINCT dt, obs_type FROM flighthistory;
CREATE UNIQUE INDEX I ON dates_info (dt);

-- adds a flag leaderboard public
-- IF column_exists('flightquest','flighthistory','exclude') THEN
-- 	ALTER TABLE flighthistory DROP COLUMN leaderboard_public;
-- END IF;
ALTER TABLE flighthistory ADD COLUMN leaderboard_public tinyint;

UPDATE flighthistory SET leaderboard_public = 0;

UPDATE flighthistory as a
INNER JOIN test_flights_public as d 
	ON a.flight_history_id = d.flight_history_id
SET
	a.leaderboard_public = 1;

-- column to check if the flight needs to be excluded from the training
-- IF column_exists('flightquest','flighthistory','exclude') THEN
-- 	ALTER TABLE flighthistory DROP COLUMN exclude;
-- END IF;
ALTER TABLE flighthistory ADD COLUMN exclude tinyint;

-- diverted flights
DROP TABLE IF EXISTS var_redirected_flights;
CREATE TABLE var_redirected_flights
as
SELECT DISTINCT dt, flight_history_id FROM flighthistoryevents_transformed
WHERE event IN ('STATUS-Diverted','STATUS-Redirected');
CREATE UNIQUE INDEX I ON var_redirected_flights (dt,flight_history_id);

-- exclusions
UPDATE flighthistory
SET exclude = 0;

UPDATE flighthistory as a
INNER JOIN var_redirected_flights as b
	ON a.dt = b.dt and a.flight_history_id = b.flight_history_id
SET
	exclude = 1
WHERE
	leaderboard_public = 0;

# exclude long flights
UPDATE flighthistory SET EXCLUDE = 1
WHERE in_mins(actual_runway_arrival,actual_runway_departure) > 600;

UPDATE flighthistory SET EXCLUDE = 1
WHERE actual_runway_arrival > actual_gate_arrival;

ALTER TABLE flighthistory ADD COLUMN actual_gate_arrival_mins float;
UPDATE flighthistory SET actual_gate_arrival_mins = in_mins(actual_gate_arrival,dt);
CREATE INDEX L ON flighthistory (dt, actual_gate_arrival_mins) USING BTREE;

-- sometimes there are duplicate entries in this table
DROP TABLE IF EXISTS asdiposition_clean;
CREATE TABLE asdiposition_clean 
as
SELECT 
	dt,
	flighthistoryid,
	received,
	MAX(callsign) as callsign,
	MIN(altitude) as altitude, 
	MIN(groundspeed) as groundspeed, 
	MAX(latitudedegrees) as latitudedegrees,
	MAX(longitudedegrees) as longitudedegrees
FROM
	asdiposition
GROUP BY
	dt,
	flighthistoryid,
	received
ORDER BY
	dt, flighthistoryid, received;
-- DROP TABLE asdiposition;

-- IF column_exists('flightquest','asdiposition_clean','date_time_recorded_mins') THEN
-- 	ALTER TABLE asdiposition_clean DROP COLUMN received_mins;
-- END IF;
ALTER TABLE asdiposition_clean ADD COLUMN received_mins int;

UPDATE asdiposition_clean SET received_mins = in_mins(received, dt);
CREATE INDEX I ON asdiposition_clean (dt, flighthistoryid, received_mins);

ALTER TABLE asdiposition_clean ADD `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY FIRST;
CREATE UNIQUE INDEX J ON asdiposition_clean (dt, id); 

ALTER TABLE asdiflightplan ADD `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY FIRST;
CREATE UNIQUE INDEX J ON asdiflightplan (dt, id); 

-- concatenating weather conditions
DROP TABLE IF EXISTS flightstats_metarpresentconditions_combined_clean;
CREATE TABLE flightstats_metarpresentconditions_combined_clean 
as
SELECT dt, metar_reports_id, GROUP_CONCAT(present_condition) as present_condition
FROM flightstats_metarpresentconditions_combined
GROUP BY dt, metar_reports_id;
CREATE UNIQUE INDEX I ON flightstats_metarpresentconditions_combined_clean (dt, metar_reports_id);

-- creating mapping of asdi <-> flighthistory
DROP TABLE IF EXISTS mapping_asdi_flighthistory;
CREATE TABLE mapping_asdi_flighthistory
as
SELECT DISTINCT dt, flighthistoryid, asdiflightplanid
FROM asdiflightplan;

CREATE UNIQUE INDEX I ON mapping_asdi_flighthistory (dt, asdiflightplanid, flighthistoryid);
CREATE UNIQUE INDEX J ON mapping_asdi_flighthistory (dt, flighthistoryid, asdiflightplanid);

-- adding id to tables
ALTER TABLE flighthistoryevents_transformed ADD `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY FIRST;
CREATE UNIQUE INDEX J ON flighthistoryevents_transformed (dt, id); 

ALTER TABLE flightstats_atsccdelay ADD `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY FIRST;
CREATE UNIQUE INDEX J ON flightstats_atsccdelay (dt, id); 

ALTER TABLE flightstats_atsccgrounddelay ADD `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY FIRST;
CREATE UNIQUE INDEX J ON flightstats_atsccgrounddelay (dt, id);


-- //
-- delimiter ;
-- call dummy();
-- drop procedure dummy;
