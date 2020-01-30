/*
DROP PROCEDURE IF EXISTS dummy;
delimiter //
create procedure dummy() 
begin
*/

-- creates last era, ega times
-- IF column_exists('flightquest','flighthistoryevents_transformed','date_time_recorded_mins') THEN
--     ALTER TABLE flighthistoryevents_transformed DROP COLUMN date_time_recorded_mins;
-- END IF;
ALTER TABLE flighthistoryevents_transformed ADD COLUMN date_time_recorded_mins int;
UPDATE flighthistoryevents_transformed SET date_time_recorded_mins = in_mins(date_time_recorded_utc, dt);


-- check what is the time of reported air status
-- there are situations that the flight was reported with a delay in the events and the estimations are 
-- really taken before the ARD
DROP TABLE IF EXISTS events_reported_takeoff;
CREATE TEMPORARY TABLE events_reported_takeoff
as 
SELECT
	a.dt
	,a.flight_history_id
	,min(a.date_time_recorded_utc) as takeoff_recorded_time
FROM
	flighthistoryevents_transformed as a
WHERE
	event_type = 'STATUS' and new = 'A'
GROUP BY
	a.dt
	,a.flight_history_id;
CREATE UNIQUE INDEX I ON events_reported_takeoff (dt, flight_history_id);


/* 
-- how many flights have no status in the air - about 329 - so it can be worth excluding
SELECT COUNT(DISTINCT a.flight_history_id)
FROM flighthistoryevents_transformed as a
	 INNER JOIN flighthistory as c 
		ON c.dt = a.dt and c.flight_history_id = a.flight_history_id
	 LEFT JOIN events_reported_takeoff as b
		ON a.dt = b.dt and a.flight_history_id = b.flight_history_id
	 LEFT JOIN var_redirected_flights as d
		ON d.dt = a.dt and d.flight_history_id = a.flight_history_id
WHERE
	b.dt IS NULL and b.flight_history_id IS NULL and a.dt <= '2012-11-25'
	AND
	c.actual_gate_departure <> '0000-00-00 00:00:00'
	AND
	d.DT IS NULL and d.flight_history_id IS NULL
	AND
	c.actual_gate_arrival > c.actual_runway_arrival;
*/

-- 10 mins
-- creating the last estimation at given cutoff times
-- changed: but after the take off!!!
DROP TABLE IF EXISTS map_last_estimations;
CREATE TEMPORARY TABLE map_last_estimations as
SELECT
	a.id,
	a.dt,
	a.flight_history_id,
    a.cutoff_hour,
	b.event_type,
	MAX(b.date_time_recorded_utc) as last_record_time
FROM 
	flighthistory_cutoffs as a
	INNER JOIN flighthistory as c
		on a.dt = c.dt and
		   a.flight_history_id = c.flight_history_id
	INNER JOIN flighthistoryevents_transformed as b
		on a.dt = b.dt and 
		   a.flight_history_id = b.flight_history_id and 
		   b.date_time_recorded_mins <= a.cutoff_hour
	INNER JOIN events_reported_takeoff as d
		ON a.dt = d.dt and
		   a.flight_history_id = d.flight_history_id
WHERE
	event_type in ('ERA','EGA','AGATE','ATERM')
	AND
	(b.date_time_recorded_utc > c.actual_runway_departure OR event_type IN ('AGATE','ATERM')) # after the take off !!!!!!
	AND
	# take the estimation that is after the reported takeoff 
	(b.date_time_recorded_utc >= d.takeoff_recorded_time OR event_type IN ('AGATE','ATERM'))# and after the reported takeoff !!!!!!!!!!!
	AND
	(old_dt_utc IS NULL OR abs(in_mins(b.old_dt_utc,b.new_dt_utc)) < 60 OR event_type IN ('AGATE','ATERM'))
	AND
	# there are situations where the new / old dates are before the recorded time
	# both new / old must be after the date time recorded
	CASE WHEN event_type IN ('ERA','EGA') THEN b.old_dt_utc > b.date_time_recorded_utc and b.new_dt_utc > b.date_time_recorded_utc ELSE 1=1 END
GROUP BY
	a.id,
	a.dt,
	a.flight_history_id,
    a.cutoff_hour,
	b.event_type;
CREATE UNIQUE INDEX I ON map_last_estimations (dt, flight_history_id, cutoff_hour, event_type);

/*
LAST ESTIMATED RUNWAY ARRIVAL
*/

/*
UPDATE flighthistory_cutoffs SET last_era = NULL;
UPDATE flighthistory_cutoffs SET last_ega = NULL;
UPDATE flighthistory_cutoffs SET last_agate = NULL;
UPDATE flighthistory_cutoffs SET last_aterm = NULL;
UPDATE flighthistory_cutoffs SET last_asdiflightplan_id = NULL;
*/

-- IF column_exists('flightquest','flighthistoryevents_transformed','last_era') THEN
-- 	ALTER TABLE flighthistory_cutoffs DROP COLUMN last_era;
-- END IF;
ALTER TABLE flighthistory_cutoffs ADD COLUMN last_era int;

UPDATE flighthistory_cutoffs as a
	   INNER JOIN map_last_estimations b
			ON a.id = b.id and b.event_type = 'ERA'
	   INNER JOIN flighthistoryevents_transformed as c 
			ON a.dt = c.dt AND
			   a.flight_history_id = c.flight_history_id AND
			   c.event_type = b.event_type AND
			   b.last_record_time = c.date_time_recorded_utc
SET
	a.last_era = c.id;

/*
LAST ESTIMATED GATE ARRIVAL
*/
-- IF column_exists('flightquest','flighthistoryevents_transformed','last_ega') THEN
-- 	ALTER TABLE flighthistory_cutoffs DROP COLUMN last_ega;
-- END IF;
ALTER TABLE flighthistory_cutoffs ADD COLUMN last_ega int;

UPDATE flighthistory_cutoffs as a
	   INNER JOIN map_last_estimations b
			ON a.id = b.id and b.event_type = 'EGA'
	   INNER JOIN flighthistoryevents_transformed as c 
			ON a.dt = c.dt AND
			   a.flight_history_id = c.flight_history_id AND
			   c.event_type = b.event_type AND
			   b.last_record_time = c.date_time_recorded_utc
SET
	a.last_ega = c.id;

/*
LAST AGATE CHANGE
*/
-- IF column_exists('flightquest','flighthistoryevents_transformed','last_agate') THEN
-- 	ALTER TABLE flighthistory_cutoffs DROP COLUMN last_agate;
-- END IF;
ALTER TABLE flighthistory_cutoffs ADD COLUMN last_agate int;

UPDATE flighthistory_cutoffs as a
	   INNER JOIN map_last_estimations b
			ON a.id = b.id and b.event_type = 'AGATE'
	   INNER JOIN flighthistoryevents_transformed as c 
			ON a.dt = c.dt AND
			   a.flight_history_id = c.flight_history_id AND
			   c.event_type = b.event_type AND
			   b.last_record_time = c.date_time_recorded_utc
SET
	a.last_agate = c.id;

-- IF column_exists('flightquest','flighthistoryevents_transformed','last_aterm') THEN
-- 	ALTER TABLE flighthistory_cutoffs DROP COLUMN last_aterm;
-- END IF;
ALTER TABLE flighthistory_cutoffs ADD COLUMN last_aterm int;

UPDATE flighthistory_cutoffs as a
	   INNER JOIN map_last_estimations b
			ON a.id = b.id and b.event_type = 'ATERM'
	   INNER JOIN flighthistoryevents_transformed as c 
			ON a.dt = c.dt AND
			   a.flight_history_id = c.flight_history_id AND
			   c.event_type = b.event_type AND
			   b.last_record_time = c.date_time_recorded_utc
SET
	a.last_aterm = c.id;

-- flighthistory_cutoffs
-- IF column_exists('flightquest','asdiflightplan','date_time_recorded_mins') THEN
-- 	ALTER TABLE asdiflightplan DROP COLUMN date_time_recorded_mins;
-- END IF;
ALTER TABLE asdiflightplan ADD COLUMN date_time_recorded_mins int;
UPDATE asdiflightplan SET date_time_recorded_mins = in_mins(updatetimeutc, dt);

-- map asdiflightplan
-- IF column_exists('flightquest','flighthistory_cutoffs','last_asdiflightplan_id') THEN
--	ALTER TABLE flighthistory_cutoffs DROP COLUMN last_asdiflightplan_id;
-- END IF;
ALTER TABLE flighthistory_cutoffs ADD COLUMN last_asdiflightplan_id int;
UPDATE flighthistory_cutoffs SET last_asdiflightplan_id = NULL;

DROP TABLE IF EXISTS asdi_last_estimations;
CREATE TEMPORARY TABLE asdi_last_estimations as
SELECT
	a.id,
	a.dt,
	a.flight_history_id,
    a.cutoff_hour,
	MAX(b.updatetimeutc) as last_record_time
FROM 
	flighthistory_cutoffs as a
	INNER JOIN asdiflightplan as b
		on a.dt = b.dt and 
		   a.flight_history_id = b.flighthistoryid and 
		   b.date_time_recorded_mins <= a.cutoff_hour
	INNER JOIN flighthistory as c
		on a.dt = c.dt and
		   a.flight_history_id = c.flight_history_id
#WHERE
#	b.updatetimeutc >= CASE WHEN c.actual_gate_departure = '0000-00-00 00:00:00' THEN b.estimateddepartureutc ELSE c.actual_gate_departure END
#	AND
#	# because the asdi sometimes makes mistake but assuming a wrong estimateddepartureutc
#	# and since we know departure time for each flight we can limit the error
#	abs(in_mins(b.estimateddepartureutc,c.actual_runway_departure)) < 10
#	AND
#	# sometimes the estimatedarrival is bad
#	(scheduled_air_time < 10 OR (abs(in_mins(b.estimatedarrivalutc,b.estimateddepartureutc)) - scheduled_air_time) < 60)
GROUP BY
	a.id,
	a.dt,
	a.flight_history_id,
    a.cutoff_hour;
CREATE UNIQUE INDEX I ON asdi_last_estimations (dt, flight_history_id, cutoff_hour);

/*
UPDATE flighthistory_cutoffs SET last_asdiflightplan_id = NULL
*/

UPDATE flighthistory_cutoffs as a
	   INNER JOIN asdi_last_estimations b
			ON a.id = b.id
	   INNER JOIN asdiflightplan as c 
			ON a.dt = c.dt AND
			   a.flight_history_id = c.flighthistoryid AND
			   b.last_record_time = c.updatetimeutc
SET
	a.last_asdiflightplan_id = c.id;

-- map asdiposition
-- IF column_exists('flightquest','flighthistory_cutoffs','last_asdiposition_id') THEN
-- 	ALTER TABLE flighthistory_cutoffs DROP COLUMN last_asdiposition_id;
-- END IF;
ALTER TABLE flighthistory_cutoffs ADD COLUMN last_asdiposition_id int;

-- IF column_exists('flightquest','asdiflightplan','date_time_recorded_mins') THEN
-- 	ALTER TABLE asdiposition_clean DROP COLUMN received_utc_mins;
-- END IF;
ALTER TABLE asdiposition_clean ADD COLUMN received_utc_mins float;
UPDATE asdiposition_clean SET received_utc_mins = in_mins(received_utc, dt);

DROP TABLE IF EXISTS asdi_last_estimations;
CREATE TEMPORARY TABLE asdi_last_estimations as
SELECT
	a.id,
	a.dt,
	a.flight_history_id,
        a.cutoff_hour,
	MAX(b.received_utc) as last_record_time
FROM 
	flighthistory_cutoffs as a
	INNER JOIN asdiposition_clean as b
		on a.dt = b.dt and 
		   a.flight_history_id = b.flighthistoryid and 
		   b.received_utc_mins <= a.cutoff_hour
--	INNER JOIN flighthistory as c
--		ON a.dt = c.dt and a.flight_history_id = c.flight_history_id
GROUP BY
	a.id,
	a.dt,
	a.flight_history_id,
        a.cutoff_hour;
CREATE UNIQUE INDEX I ON asdi_last_estimations (dt, flight_history_id, cutoff_hour);

UPDATE flighthistory_cutoffs SET last_asdiposition_id = NULL;
UPDATE flighthistory_cutoffs as a
	   INNER JOIN asdi_last_estimations b
			ON a.id = b.id
	   INNER JOIN asdiposition_clean as c 
			ON a.dt = c.dt AND
			   a.flight_history_id = c.flighthistoryid AND
			   b.last_record_time = c.received_utc
SET
	a.last_asdiposition_id = c.id;

-- era before take off
DROP TABLE IF EXISTS map_last_estimations_before_takeoff;
CREATE TEMPORARY TABLE map_last_estimations_before_takeoff as
SELECT
	a.id,
	a.dt,
	a.flight_history_id,
        a.cutoff_hour,
	b.event_type,
	MAX(b.date_time_recorded_utc) as last_record_time
FROM 
	flighthistory_cutoffs as a
	INNER JOIN flighthistory as c
		on a.dt = c.dt and
		   a.flight_history_id = c.flight_history_id
	INNER JOIN flighthistoryevents_transformed as b
		on a.dt = b.dt and 
		   a.flight_history_id = b.flight_history_id and 
		   b.date_time_recorded_mins <= a.cutoff_hour
WHERE
	event_type in ('ERA','EGA')
	AND
	b.date_time_recorded_utc < c.actual_runway_departure # before the take off !!!!!!
GROUP BY
	a.id,
	a.dt,
	a.flight_history_id,
    a.cutoff_hour,
	b.event_type;
CREATE UNIQUE INDEX I ON map_last_estimations_before_takeoff (dt, flight_history_id, cutoff_hour, event_type);

-- IF column_exists('flightquest','flighthistoryevents_transformed','last_aterm') THEN
-- 	ALTER TABLE flighthistory_cutoffs DROP COLUMN last_era_before_ard;
-- END IF;
ALTER TABLE flighthistory_cutoffs ADD COLUMN last_era_before_ard int;

UPDATE flighthistory_cutoffs as a
	   INNER JOIN map_last_estimations_before_takeoff as b
			ON a.id = b.id and b.event_type = 'ERA'
	   INNER JOIN flighthistoryevents_transformed as c 
			ON a.dt = c.dt AND
			   a.flight_history_id = c.flight_history_id AND
			   c.event_type = b.event_type AND
			   b.last_record_time = c.date_time_recorded_utc
SET
	a.last_era_before_ard = c.id;

-- end;
ALTER TABLE flighthistory_cutoffs ADD COLUMN AGATE varchar(30);
UPDATE flighthistory_cutoffs as a
	   LEFT JOIN flighthistoryevents_transformed as b	
			on a.dt = b.dt and a.last_agate = b.id
SET AGATE = COALESCE(b.new,'XXXXX');
			
ALTER TABLE flighthistory_cutoffs ADD COLUMN ATERM varchar(30);
UPDATE flighthistory_cutoffs as a
	   LEFT JOIN flighthistoryevents_transformed as b	
			on a.dt = b.dt and a.last_aterm = b.id
SET ATERM = COALESCE(b.new,'XXXXX');

/*
//
delimiter ;
call dummy();
drop procedure dummy;
*/
