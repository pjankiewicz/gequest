
CREATE UNIQUE INDEX I ON flightstats_taf (tafid);
CREATE INDEX J ON flightstats_taf (airport);
CREATE INDEX I ON flightstats_tafforecast (tafid);
#CREATE INDEX J ON flightstats_tafforecast (tafforecastid);
CREATE UNIQUE INDEX K ON flightstats_tafforecast (tafforecastid);

-- cleaning the tables
DROP TABLE IF EXISTS flightstats_taficing_clean;
CREATE TABLE flightstats_taficing_clean
as
SELECT 
	dt,tafforecastid
	,avg(intensity) as intensity 
	,min(minimumaltitudefeet) as minimumaltitudefeet
	,max(maximumaltitudefeet) as maximumaltitudefeet
FROM 
	flightstats_taficing
GROUP BY
	dt,tafforecastid;
CREATE UNIQUE INDEX K ON flightstats_taficing_clean (tafforecastid);

DROP TABLE IF EXISTS flightstats_taftemperature_clean;
CREATE TABLE flightstats_taftemperature_clean
as
SELECT 
	dt,tafforecastid
	,max(CASE WHEN mintemperaturecelcius = 0 THEN NULL ELSE mintemperaturecelcius END) as mintemperaturecelcius
	,max(CASE WHEN maxtemperaturecelcius = 0 THEN NULL ELSE maxtemperaturecelcius END) as maxtemperaturecelcius
	,max(CASE WHEN surfacetemperaturecelcius = 0 THEN NULL ELSE surfacetemperaturecelcius END) as surfacetemperaturecelcius
FROM 
	flightstats_taftemperature
GROUP BY
	dt,tafforecastid;
CREATE UNIQUE INDEX K ON flightstats_taftemperature_clean (tafforecastid);

DROP TABLE IF EXISTS flightstats_tafturbulence_clean;
CREATE TABLE flightstats_tafturbulence_clean
as
SELECT 
	dt,tafforecastid
	,avg(intensity) as intensity 
	,min(minimumaltitudefeet) as minimumaltitudefeet
	,max(maximumaltitudefeet) as maximumaltitudefeet
FROM 
	flightstats_taficing
GROUP BY
	dt,tafforecastid;
CREATE UNIQUE INDEX K ON flightstats_tafturbulence_clean (tafforecastid);

DROP TABLE IF EXISTS station;
CREATE TEMPORARY TABLE station as 
SELECT DISTINCT right(airport,3) as airport FROM flightstats_taf;
CREATE UNIQUE INDEX I ON station (airport);

ALTER TABLE flightstats_taf ADD COLUMN bulletintimeutc_mins float;
UPDATE flightstats_taf SET bulletintimeutc_mins = in_mins(bulletintimeutc,dt);
CREATE INDEX L ON flightstats_taf  (dt,bulletintimeutc_mins) USING BTREE;

DROP TABLE IF EXISTS TAF_FORECAST;
CREATE TEMPORARY TABLE TAF_FORECAST
as
SELECT
	a.dt, CONCAT('K',station.airport) as arrival_airport_code, cutoff_hours.cutoff_hour,
	MAX(tafforecastid) as tafforecastid
FROM
	cutoff_hours
	INNER JOIN station
		ON 1 = 1
	INNER JOIN flightstats_taf as a
		ON station.airport = a.airport and bulletintimeutc_mins < cutoff_hour
	INNER JOIN flightstats_tafforecast as b
		ON a.tafid = b.tafid and a.dt = b.dt
GROUP BY
	a.dt, station.airport, cutoff_hours.cutoff_hour;
CREATE UNIQUE INDEX I ON TAF_FORECAST (dt, arrival_airport_code, cutoff_hour);

ALTER TABLE flighthistory_cutoffs ADD COLUMN tafforecastid int;
UPDATE flighthistory_cutoffs as a
	   INNER JOIN TAF_FORECAST as b
			on a.dt = b.dt and a.cutoff_hour = b.cutoff_hour and a.arrival_airport_icao_code = b.arrival_airport_code
SET a.tafforecastid = b.tafforecastid;

DROP TABLE TAF_FORECAST;
