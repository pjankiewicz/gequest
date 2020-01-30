# file:  ASDI / asdiairway.csv 
/*
DROP TABLE IF EXISTS asdiairway ;
CREATE TABLE  asdiairway 
(
	 dt date,
	 asdiflightplanid  mediumint unsigned,
	 ordinal  tinyint unsigned,
	 airway  varchar (6)
) Engine=MyISAM;
*/

# file:  ASDI / asdiflightplan.csv 
DROP TABLE IF EXISTS asdiflightplan ;
CREATE TABLE  asdiflightplan 
(
	 dt date,
	 asdiflightplanid  mediumint unsigned,
	 updatetimeutc  datetime,
	 flighthistoryid  int unsigned,
	 departureairport  varchar (4),
	 arrivalairport  varchar (4),
	 aircraftid  varchar (7),
	 legacyroute  varchar (154),
	 originaldepartureutc  datetime,
	 estimateddepartureutc  datetime,
	 originalarrivalutc  datetime,
	 estimatedarrivalutc  datetime
) Engine=MyISAM;

# file:  ASDI / asdifpcenter.csv 
DROP TABLE IF EXISTS asdifpcenter ;
CREATE TABLE  asdifpcenter 
(
	 dt date,
	 asdiflightplanid  mediumint unsigned,
	 ordinal  tinyint unsigned,
	 center  varchar (3)
) Engine=MyISAM;

# file:  ASDI / asdifpfix.csv 
DROP TABLE IF EXISTS asdifpfix ;
CREATE TABLE  asdifpfix 
(
	 dt date,
	 asdiflightplanid  mediumint unsigned,
	 ordinal  tinyint unsigned,
	 fix  varchar (5)
) Engine=MyISAM;

# file:  ASDI / asdifpsector.csv 
DROP TABLE IF EXISTS asdifpsector ;
CREATE TABLE  asdifpsector 
(
	 dt date,
	 asdiflightplanid  mediumint unsigned,
	 ordinal  tinyint unsigned,
	 sector  varchar (6)
) Engine=MyISAM;

# file:  ASDI / asdifpwaypoint.csv 
DROP TABLE IF EXISTS asdifpwaypoint ;
CREATE TABLE  asdifpwaypoint 
(
	 dt date,
	 asdiflightplanid  mediumint unsigned,
	 ordinal  tinyint unsigned,
	 latitude  float,
	 longitude  float
) Engine=MyISAM;

# file:  ASDI / asdiposition.csv 
DROP TABLE IF EXISTS asdiposition ;
CREATE TABLE  asdiposition 
(
	 dt date,
	 received  datetime,
	 callsign  varchar (7),
	 altitude  mediumint unsigned,
	 groundspeed  smallint unsigned,
	 latitudedegrees  float,
	 longitudedegrees  float,
	 flighthistoryid  int unsigned
) Engine=MyISAM;

# file:  ATSCC / flightstats_atsccadvisories.csv 
DROP TABLE IF EXISTS flightstats_atsccadvisories ;
CREATE TABLE  flightstats_atsccadvisories 
(
	 dt date,
	 advisory_message_id  mediumint unsigned,
	 capture_time  datetime,
	 title  varchar (63),
	 number  tinyint unsigned,
	 signature_time  datetime,
	 data  varchar (3209),
	 raw_html  varchar (4739)
) Engine=MyISAM;

# file:  ATSCC / flightstats_atsccdelay.csv 
DROP TABLE IF EXISTS flightstats_atsccdelay ;
CREATE TABLE  flightstats_atsccdelay 
(
	 dt date,
	 airport_delay_id  mediumint unsigned,
	 capture_time  datetime,
	 start_time  datetime,
	 end_time  datetime,
	 invalidated_time  datetime,
	 airport_code  varchar (3),
	 type  varchar (1),
	 min_time  tinyint unsigned,
	 max_time  tinyint unsigned,
	 trend  varchar (1),
	 reason  varchar (63),
	 original_nas_status_id  mediumint unsigned
) Engine=MyISAM;

# file:  ATSCC / flightstats_atsccgrounddelayairports.csv 
DROP TABLE IF EXISTS flightstats_atsccgrounddelayairports ;
CREATE TABLE  flightstats_atsccgrounddelayairports 
(
	 dt date,
	 ground_delay_program_id  smallint unsigned,
	 airport_code  varchar (3)
) Engine=MyISAM;

# file:  ATSCC / flightstats_atsccgrounddelayartccs.csv 
DROP TABLE IF EXISTS flightstats_atsccgrounddelayartccs ;
CREATE TABLE  flightstats_atsccgrounddelayartccs 
(
	 dt date,
	 ground_delay_program_id  varchar (30),
	 artcc_code  varchar (30)
) Engine=MyISAM;

# file:  ATSCC / flightstats_atsccgrounddelay.csv 
DROP TABLE IF EXISTS flightstats_atsccgrounddelay ;
CREATE TABLE  flightstats_atsccgrounddelay 
(
	 dt date,
	 ground_delay_program_id  smallint unsigned,
	 signature_time  datetime,
	 effective_start_time  datetime,
	 effective_end_time  datetime,
	 invalidated_time  datetime,
	 cancelled_time  varchar (7),
	 is_proposed  varchar (30),
	 airport_code  varchar (3),
	 delay_assignment_mode  varchar (3),
	 adl_time  datetime,
	 arrivals_estimated_for_start_time  datetime,
	 arrivals_estimated_for_end_time  datetime,
	 program_rates  varchar (20),
	 flights_included  varchar (21),
	 radius_of_airports_included  double,
	 delay_assignment_table_applies_to  varchar (3),
	 delay_limit  varchar (30),
	 maximum_delay  smallint unsigned,
	 average_delay  tinyint unsigned,
	 reason  varchar (30),
	 remarks  varchar (30),
	 original_advisory_message_id  mediumint unsigned,
	 impacting_condition  varchar (22),
	 comments  varchar (38)
) Engine=MyISAM;

# file:  ATSCC / flightstats_atsccinvalidgs.csv 
DROP TABLE IF EXISTS flightstats_atsccinvalidgs ;
CREATE TABLE  flightstats_atsccinvalidgs 
(
	 dt date,
	 advisory_message_id  mediumint unsigned,
	 capture_time  datetime,
	 title  varchar (45),
	 number  tinyint unsigned,
	 signature_time  datetime,
	 data  varchar (473),
	 raw_html  varchar (1969),
	 invalid_reason  varchar (39)
) Engine=MyISAM;

# file:  ATSCC / flightstats_atsccnasstatus.csv 
DROP TABLE IF EXISTS flightstats_atsccnasstatus ;
CREATE TABLE  flightstats_atsccnasstatus 
(
	 dt date,
	 nas_status_id  mediumint unsigned,
	 capture_time  datetime,
	 raw_html  varchar (5638)
) Engine=MyISAM;

DROP TABLE IF EXISTS flightstats_atsccdeicing ;
CREATE TABLE  flightstats_atsccdeicing 
(
	 dt date,
	 airport_deicing_id  mediumint,
	 capture_time  datetime,
	 start_time  datetime,
	 end_time  datetime,
	 invalidated_time  datetime,
	 airport_code varchar(255),
	 acceptance_rate varchar(255),
	 departure_rate varchar(255),
	 original_nas_status_id varchar(255)
) Engine=MyISAM;

# file:  FlightHistory / flighthistory.csv 
DROP TABLE IF EXISTS flighthistory ;
CREATE TABLE  flighthistory 
(
	 dt date,
	 flight_history_id  int unsigned,
	 airline_code  varchar (3),
	 airline_icao_code  varchar (3),
	 flight_number  smallint unsigned,
	 departure_airport_code  varchar (4),
	 departure_airport_icao_code  varchar (4),
	 arrival_airport_code  varchar (4),
	 arrival_airport_icao_code  varchar (4),
	 published_departure  datetime,
	 published_arrival  datetime,
	 scheduled_gate_departure  datetime,
	 actual_gate_departure  datetime,
	 scheduled_gate_arrival  datetime,
	 actual_gate_arrival  datetime,
	 scheduled_runway_departure  datetime,
	 actual_runway_departure  datetime,
	 scheduled_runway_arrival  datetime,
	 actual_runway_arrival  datetime,
	 creator_code  varchar (1),
	 scheduled_air_time  smallint,
	 scheduled_block_time  smallint unsigned,
	 departure_airport_timezone_offset  tinyint,
	 arrival_airport_timezone_offset  tinyint,
	 scheduled_aircraft_type  varchar (3),
	 actual_aircraft_type  varchar (30),
	 icao_aircraft_type_actual  varchar (4)
) Engine=MyISAM;

# file:  FlightHistory / flighthistoryevents.csv 
DROP TABLE IF EXISTS flighthistoryevents ;
CREATE TABLE  flighthistoryevents 
(
	 dt date,
	 flight_history_id  int unsigned,
	 date_time_recorded  datetime,
	 event  varchar (24),
	 data_updated  varchar (216)
) Engine=MyISAM;

# file:  FlightHistory / flighthistoryevents_transformed.csv 
DROP TABLE IF EXISTS flighthistoryevents_transformed;
CREATE TABLE  flighthistoryevents_transformed 
(
	 dt date,
	 flight_history_id  int unsigned,
	 date_time_recorded  datetime,
	 event  varchar (24),
	 event_type varchar(24),
	 old varchar(50),
         new varchar(50),
         old_dt datetime,
         new_dt datetime
) Engine=MyISAM;

# file:  Metar / flightstats_metarpresentconditions_combined.csv 
DROP TABLE IF EXISTS flightstats_metarpresentconditions_combined ;
CREATE TABLE  flightstats_metarpresentconditions_combined 
(
	 dt date,
	 id  int unsigned,
	 metar_reports_id  int unsigned,
	 present_condition  varchar (49)
) Engine=MyISAM;

# file:  Metar / flightstats_metarreports_combined.csv 
DROP TABLE IF EXISTS flightstats_metarreports_combined ;
CREATE TABLE  flightstats_metarreports_combined 
(
	 dt date,
	 metar_reports_id  int,
	 weather_station_code  varchar (4),
	 date_time_issued  datetime,
	 report_modifier  varchar (4),
	 is_wind_direction_variable  varchar (30),
	 wind_direction  double,
	 wind_speed  double,
	 wind_gusts  double,
	 variable_wind_direction  varchar (45),
	 is_visibility_less_than  varchar (30),
	 visibility  double,
	 temperature  double,
	 dewpoint  double,
	 altimeter  double,
	 remark  varchar (72),
	 original_report  varchar (222),
	 station_type  varchar (7),
	 sea_level_pressure  double
) Engine=MyISAM;

# file:  Metar / flightstats_metarrunwaygroups_combined.csv 
DROP TABLE IF EXISTS flightstats_metarrunwaygroups_combined ;
CREATE TABLE  flightstats_metarrunwaygroups_combined 
(
	 dt date,
	 approach_direction  varchar (5),
	 id  mediumint unsigned,
	 is_varying  varchar (30),
	 max_prefix  varchar (12),
	 max_visible  smallint unsigned,
	 metar_reports_id  int unsigned,
	 min_prefix  varchar (30),
	 min_visible  double,
	 runway  tinyint unsigned
) Engine=MyISAM;

# file:  Metar / flightstats_metarskyconditions_combined.csv 
DROP TABLE IF EXISTS flightstats_metarskyconditions_combined ;
CREATE TABLE  flightstats_metarskyconditions_combined 
(
	 dt date,
	 id  int unsigned,
	 metar_reports_id  int,
	 sky_condition  varchar (60)
) Engine=MyISAM;

# file:  OtherWeather / flightstats_airsigmetarea.csv 
DROP TABLE IF EXISTS flightstats_airsigmetarea ;
CREATE TABLE  flightstats_airsigmetarea 
(
	 dt date,
	 airsigmetid  smallint unsigned,
	 latitude  double,
	 longitude  double,
	 ordinal  tinyint unsigned
) Engine=MyISAM;

# file:  OtherWeather / flightstats_airsigmet.csv 
DROP TABLE IF EXISTS flightstats_airsigmet ;
CREATE TABLE  flightstats_airsigmet 
(
	 dt date,
	 airsigmetid  smallint unsigned,
	 timevalidfromutc  datetime,
	 timevalidtoutc  datetime,
	 movementdirdegrees  double,
	 movementspeedknots  double,
	 hazardtype  varchar (10),
	 hazardseverity  varchar (6),
	 airsigmettype  varchar (7),
	 altitudeminft  double,
	 altitudemaxft  double,
	 rawtext  varchar (1034)
) Engine=MyISAM;

# file:  OtherWeather / flightstats_fbwindairport.csv 
DROP TABLE IF EXISTS flightstats_fbwindairport ;
CREATE TABLE  flightstats_fbwindairport 
(
	 dt date,
	 fbwindairportid  smallint unsigned,
	 fbwindreportid  smallint unsigned,
	 airportcode  varchar (3)
) Engine=MyISAM;

# file:  OtherWeather / flightstats_fbwindaltitude.csv 
DROP TABLE IF EXISTS flightstats_fbwindaltitude ;
CREATE TABLE  flightstats_fbwindaltitude 
(
	 dt date,
	 fbwindreportid  smallint unsigned,
	 ordinal  tinyint unsigned,
	 altitude  smallint unsigned
) Engine=MyISAM;

# file:  OtherWeather / flightstats_fbwind.csv 
DROP TABLE IF EXISTS flightstats_fbwind ;
CREATE TABLE  flightstats_fbwind 
(
	 dt date,
	 fbwindairportid  smallint unsigned,
	 ordinal  tinyint unsigned,
	 bearing  smallint unsigned,
	 knots  tinyint unsigned,
	 temperature  double
) Engine=MyISAM;

# file:  OtherWeather / flightstats_fbwindreport.csv 
DROP TABLE IF EXISTS flightstats_fbwindreport ;
CREATE TABLE  flightstats_fbwindreport 
(
	 dt date,
	 fbwindreportid  smallint unsigned,
	 createdutc  datetime,
	 reporttype1  varchar (6),
	 reporttype2  varchar (4),
	 reporttype3  varchar (6),
	 generated  mediumint unsigned,
	 basedon  varchar (7),
	 valid  varchar (7),
	 forusestart  smallint unsigned,
	 foruseend  smallint unsigned,
	 negativeabove  smallint unsigned,
	 altitudescale  varchar (71),
	 altitudeunits  varchar (2)
) Engine=MyISAM;

# file:  OtherWeather / flightstats_taf.csv 
DROP TABLE IF EXISTS flightstats_taf ;
CREATE TABLE  flightstats_taf 
(
	 dt date,
	 tafid  mediumint unsigned,
	 station  varchar (4),
	 airport  varchar (4),
	 rawtext  varchar (526),
	 latitude  double,
	 longitude  double,
	 elevationmeters  smallint,
	 remarks  varchar (62),
	 bulletintimeutc  datetime,
	 issuetimeutc  datetime,
	 validtimefromutc  datetime,
	 validtimetoutc  datetime
) Engine=MyISAM;

# file:  OtherWeather / flightstats_tafforecast.csv 
DROP TABLE IF EXISTS flightstats_tafforecast ;
CREATE TABLE  flightstats_tafforecast 
(
	 dt date,
	 tafforecastid  mediumint unsigned,
	 tafid  mediumint unsigned,
	 altimiter  double,
	 changeindicator  varchar (5),
	 forecasttimefromutc  datetime,
	 forecasttimetoutc  datetime,
	 probability  double,
	 timebecomingutc  varchar (7),
	 verticalvisibility  double,
	 visibilitystatutemiles  double,
	 windspeedknots  double,
	 winddirectiondegrees  double,
	 windgustspeedknots  double,
	 windsheardirectiondegrees  double,
	 windshearheightfeet  double,
	 windshearspeedknots  double,
	 weatherstring  varchar (13),
	 notdecoded  varchar (32)
) Engine=MyISAM;

# file:  OtherWeather / flightstats_taficing.csv 
DROP TABLE IF EXISTS flightstats_taficing ;
CREATE TABLE  flightstats_taficing 
(
	 dt date,
	 tafforecastid  mediumint unsigned,
	 intensity  double,
	 minimumaltitudefeet  double,
	 maximumaltitudefeet  double
) Engine=MyISAM;

# file:  OtherWeather / flightstats_tafsky.csv 
DROP TABLE IF EXISTS flightstats_tafsky ;
CREATE TABLE  flightstats_tafsky 
(
	 dt date,
	 tafforecastid  mediumint unsigned,
	 cloudbasefeet  double,
	 cloudtype  varchar (3),
	 cloudcover  varchar (3)
) Engine=MyISAM;

# file:  OtherWeather / flightstats_taftemperature.csv 
DROP TABLE IF EXISTS flightstats_taftemperature ;
CREATE TABLE  flightstats_taftemperature 
(
	 dt date,
	 tafforecastid  mediumint unsigned,
	 validtimeutc  datetime,
	 mintemperaturecelcius  double,
	 maxtemperaturecelcius  double,
	 surfacetemperaturecelcius  double
) Engine=MyISAM;

# file:  OtherWeather / flightstats_tafturbulence.csv 
DROP TABLE IF EXISTS flightstats_tafturbulence ;
CREATE TABLE  flightstats_tafturbulence 
(
	 dt date,
	 tafforecastid  mediumint unsigned,
	 intensity  double,
	 minimumaltitudefeet  double,
	 maximumaltitudefeet  double
) Engine=MyISAM;

DROP TABLE IF EXISTS test_flights_public;
CREATE TABLE test_flights_public (
	 flight_history_id  int unsigned
) Engine=MyISAM;


DROP TABLE IF EXISTS mapping_airports_coordinates;
CREATE TABLE mapping_airports_coordinates (
	 airport_code varchar(10),
	 longitude double,
	 latitude double
);
