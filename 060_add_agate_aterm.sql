
/* GET THE FINAL ATERM AGATE FOR THE FLIGHTS */

-- UPDATE flighthistory SET ATERM = NULL
-- UPDATE flighthistory SET AGATE = NULL

DROP TABLE IF EXISTS flight_gates;
CREATE TEMPORARY TABLE flight_gates
as
SELECT dt, flight_history_id, event_type, MAX(date_time_recorded_utc) as max_date_time_recorded_utc
FROM flightquest.flighthistoryevents_transformed
WHERE event_type IN ('ATERM','AGATE')
GROUP BY dt, flight_history_id, event_type;

CREATE UNIQUE INDEX I ON flight_gates (dt, flight_history_id, event_type);

DROP TABLE IF EXISTS flight_gate_aterm;
CREATE TEMPORARY TABLE flight_gate_aterm
as
SELECT 
	a.dt, a.flight_history_id, MAX(b.old) as old, MAX(b.new) as new
FROM 
	flight_gates as a
	INNER JOIN flighthistoryevents_transformed as b
		ON a.dt = b.dt and 
		   a.flight_history_id = b.flight_history_id and
		   a.event_type = b.event_type and
		   a.max_date_time_recorded_utc = b.date_time_recorded_utc
WHERE
	a.event_type = 'ATERM'
GROUP BY
	a.dt, a.flight_history_id;
CREATE UNIQUE INDEX I ON flight_gate_aterm (dt, flight_history_id);

ALTER TABLE flighthistory ADD COLUMN ATERM varchar(30);
UPDATE
	flighthistory as a
	INNER JOIN flight_gate_aterm as b
		ON a.dt = b.dt and a.flight_history_id = b.flight_history_id
SET
	a.ATERM = b.new;
UPDATE flighthistory SET ATERM = COALESCE(ATERM,'XXXXX');

DROP TABLE IF EXISTS flight_gate_agate;
CREATE TEMPORARY TABLE flight_gate_agate
as
SELECT 
	a.dt, a.flight_history_id, MAX(b.old) as old, MAX(b.new) as new
FROM 
	flight_gates as a
	INNER JOIN flighthistoryevents_transformed as b
		ON a.dt = b.dt and 
		   a.flight_history_id = b.flight_history_id and
		   a.event_type = b.event_type and
		   a.max_date_time_recorded_utc = b.date_time_recorded_utc
WHERE
	a.event_type = 'AGATE'
GROUP BY
	a.dt, a.flight_history_id;
CREATE UNIQUE INDEX I ON flight_gate_agate (dt, flight_history_id);

ALTER TABLE flighthistory ADD COLUMN AGATE varchar(30);
UPDATE
	flighthistory as a
	INNER JOIN flight_gate_agate as b
		ON a.dt = b.dt and a.flight_history_id = b.flight_history_id
SET
	a.AGATE = b.new;

UPDATE flighthistory SET AGATE = COALESCE(AGATE,'XXXXX');
