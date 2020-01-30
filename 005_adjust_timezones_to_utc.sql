/*
FLIGHT HISTORY EVENTS
departure times at timezone departure airport
arrival times at timezone arrival airport
*/

-- update date_time_recorded
-- ALTER TABLE flighthistoryevents_transformed DROP COLUMN date_time_recorded_utc;
ALTER TABLE flighthistoryevents_transformed ADD COLUMN date_time_recorded_utc datetime;
UPDATE flighthistoryevents_transformed 
SET date_time_recorded_utc = date_time_recorded + INTERVAL 8 HOUR;

ALTER TABLE asdiposition_clean ADD COLUMN received_utc datetime;
UPDATE asdiposition_clean
-- there must be a change here (public leaderboard data was corrected)
-- old line: 
-- SET received_utc = received + INTERVAL 8 HOUR;
SET received_utc = CASE WHEN dt <= '2013-02-06' THEN received + INTERVAL 8 HOUR ELSE received END;


-- update old_dt, new_dt
-- ALTER TABLE flighthistoryevents_transformed DROP COLUMN old_dt_utc;
ALTER TABLE flighthistoryevents_transformed ADD COLUMN old_dt_utc datetime;

-- ALTER TABLE flighthistoryevents_transformed DROP COLUMN new_dt_utc;
ALTER TABLE flighthistoryevents_transformed ADD COLUMN new_dt_utc datetime;

UPDATE
	flighthistoryevents_transformed as a
    INNER JOIN flighthistory as b
		ON a.dt = b.dt and a.flight_history_id = b.flight_history_id
SET
	  old_dt_utc = CASE WHEN event_type IN ('ARA','ERA','SRA','EGA','AGA','SGA') THEN old_dt - INTERVAL arrival_airport_timezone_offset HOUR
				        WHEN event_type IN ('ARD','ERD','SRD','EGD','AGD','SGD') THEN old_dt - INTERVAL departure_airport_timezone_offset HOUR END
	 ,new_dt_utc = CASE WHEN event_type IN ('ARA','ERA','SRA','EGA','AGA','SGA') THEN new_dt - INTERVAL arrival_airport_timezone_offset HOUR
				        WHEN event_type IN ('ARD','ERD','SRD','EGD','AGD','SGD') THEN new_dt - INTERVAL departure_airport_timezone_offset HOUR END
WHERE
	event_type IN ('ARA','ERA','SRA','EGA','AGA','SGA','ARD','ERD','SRD','EGD','AGD','SGD');

-- UPDATE flightstats_taf SET bulletintimeutc = bulletintimeutc - INTERVAL 8 HOUR;
