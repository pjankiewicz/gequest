
# change the path to raw tables 

LOAD DATA LOCAL INFILE '/media/pawel/b32141d8-7ca1-4197-820f-745c5f17b481/kaggle/flight/data/raw/PublicLeaderboardSet/test_flights_combined_t.csv' INTO TABLE test_flights_public FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n'; 

LOAD DATA LOCAL INFILE '/media/pawel/b32141d8-7ca1-4197-820f-745c5f17b481/kaggle/flight/data/combined/flighthistory_c.csv' INTO TABLE flighthistory FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n'; 

LOAD DATA LOCAL INFILE '/media/pawel/b32141d8-7ca1-4197-820f-745c5f17b481/kaggle/flight/data/combined/flighthistoryevents_c_transformed.csv' 
INTO TABLE flighthistoryevents_transformed FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n'; 

LOAD DATA LOCAL INFILE '/media/pawel/b32141d8-7ca1-4197-820f-745c5f17b481/kaggle/flight/data/combined/flightstats_airsigmetarea_c.csv' INTO TABLE flightstats_airsigmetarea FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n'; 

LOAD DATA LOCAL INFILE '/media/pawel/b32141d8-7ca1-4197-820f-745c5f17b481/kaggle/flight/data/combined/flightstats_airsigmet_c.csv' INTO TABLE flightstats_airsigmet FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n'; 

LOAD DATA LOCAL INFILE '/media/pawel/b32141d8-7ca1-4197-820f-745c5f17b481/kaggle/flight/data/combined/flightstats_atsccadvisories_c.csv' INTO TABLE flightstats_atsccadvisories FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n'; 

LOAD DATA LOCAL INFILE '/media/pawel/b32141d8-7ca1-4197-820f-745c5f17b481/kaggle/flight/data/combined/flightstats_atsccdeicing_c.csv' INTO TABLE flightstats_atsccdeicing FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n'; 

LOAD DATA LOCAL INFILE '/media/pawel/b32141d8-7ca1-4197-820f-745c5f17b481/kaggle/flight/data/combined/flightstats_atsccdelay_c.csv' INTO TABLE flightstats_atsccdelay FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n'; 

LOAD DATA LOCAL INFILE '/media/pawel/b32141d8-7ca1-4197-820f-745c5f17b481/kaggle/flight/data/combined/flightstats_atsccgrounddelayairports_c.csv' INTO TABLE flightstats_atsccgrounddelayairports FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n'; 

LOAD DATA LOCAL INFILE '/media/pawel/b32141d8-7ca1-4197-820f-745c5f17b481/kaggle/flight/data/combined/flightstats_atsccgrounddelayartccs_c.csv' INTO TABLE flightstats_atsccgrounddelayartccs FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n'; 

LOAD DATA LOCAL INFILE '/media/pawel/b32141d8-7ca1-4197-820f-745c5f17b481/kaggle/flight/data/combined/flightstats_atsccgrounddelay_c.csv' INTO TABLE flightstats_atsccgrounddelay FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n'; 

LOAD DATA LOCAL INFILE '/media/pawel/b32141d8-7ca1-4197-820f-745c5f17b481/kaggle/flight/data/combined/flightstats_atsccinvalidgs_c.csv' INTO TABLE flightstats_atsccinvalidgs FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n'; 

LOAD DATA LOCAL INFILE '/media/pawel/b32141d8-7ca1-4197-820f-745c5f17b481/kaggle/flight/data/combined/flightstats_atsccnasstatus_c.csv' INTO TABLE flightstats_atsccnasstatus FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n'; 

LOAD DATA LOCAL INFILE '/media/pawel/b32141d8-7ca1-4197-820f-745c5f17b481/kaggle/flight/data/combined/flightstats_fbwindairport_c.csv' INTO TABLE flightstats_fbwindairport FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n'; 

LOAD DATA LOCAL INFILE '/media/pawel/b32141d8-7ca1-4197-820f-745c5f17b481/kaggle/flight/data/combined/flightstats_fbwindaltitude_c.csv' INTO TABLE flightstats_fbwindaltitude FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n'; 

LOAD DATA LOCAL INFILE '/media/pawel/b32141d8-7ca1-4197-820f-745c5f17b481/kaggle/flight/data/combined/flightstats_fbwind_c.csv' INTO TABLE flightstats_fbwind FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n'; 

LOAD DATA LOCAL INFILE '/media/pawel/b32141d8-7ca1-4197-820f-745c5f17b481/kaggle/flight/data/combined/flightstats_fbwindreport_c.csv' INTO TABLE flightstats_fbwindreport FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n'; 

LOAD DATA LOCAL INFILE '/media/pawel/b32141d8-7ca1-4197-820f-745c5f17b481/kaggle/flight/data/combined/flightstats_metarpresentconditions_combined_c.csv' INTO TABLE flightstats_metarpresentconditions_combined FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n'; 

LOAD DATA LOCAL INFILE '/media/pawel/b32141d8-7ca1-4197-820f-745c5f17b481/kaggle/flight/data/combined/flightstats_metarreports_combined_c.csv' INTO TABLE flightstats_metarreports_combined FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n'; 

LOAD DATA LOCAL INFILE '/media/pawel/b32141d8-7ca1-4197-820f-745c5f17b481/kaggle/flight/data/combined/flightstats_metarrunwaygroups_combined_c.csv' INTO TABLE flightstats_metarrunwaygroups_combined FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n'; 

LOAD DATA LOCAL INFILE '/media/pawel/b32141d8-7ca1-4197-820f-745c5f17b481/kaggle/flight/data/combined/flightstats_metarskyconditions_combined_c.csv' INTO TABLE flightstats_metarskyconditions_combined FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n'; 

LOAD DATA LOCAL INFILE '/media/pawel/b32141d8-7ca1-4197-820f-745c5f17b481/kaggle/flight/data/combined/flightstats_taf_c.csv' INTO TABLE flightstats_taf FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n'; 

LOAD DATA LOCAL INFILE '/media/pawel/b32141d8-7ca1-4197-820f-745c5f17b481/kaggle/flight/data/combined/flightstats_tafforecast_c.csv' INTO TABLE flightstats_tafforecast FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n'; 

LOAD DATA LOCAL INFILE '/media/pawel/b32141d8-7ca1-4197-820f-745c5f17b481/kaggle/flight/data/combined/flightstats_taficing_c.csv' INTO TABLE flightstats_taficing FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n'; 

LOAD DATA LOCAL INFILE '/media/pawel/b32141d8-7ca1-4197-820f-745c5f17b481/kaggle/flight/data/combined/flightstats_tafsky_c.csv' INTO TABLE flightstats_tafsky FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n'; 

LOAD DATA LOCAL INFILE '/media/pawel/b32141d8-7ca1-4197-820f-745c5f17b481/kaggle/flight/data/combined/flightstats_taftemperature_c.csv' INTO TABLE flightstats_taftemperature FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n'; 

LOAD DATA LOCAL INFILE '/media/pawel/b32141d8-7ca1-4197-820f-745c5f17b481/kaggle/flight/data/combined/flightstats_tafturbulence_c.csv' INTO TABLE flightstats_tafturbulence FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n'; 

/*
LOAD DATA LOCAL INFILE '/media/pawel/b32141d8-7ca1-4197-820f-745c5f17b481/kaggle/flight/data/combined/asdiairway_c.csv' INTO TABLE asdiairway FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n'; 
*/

LOAD DATA LOCAL INFILE '/media/pawel/b32141d8-7ca1-4197-820f-745c5f17b481/kaggle/flight/data/combined/asdiflightplan_c.csv' INTO TABLE asdiflightplan FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n'; 

/*
LOAD DATA LOCAL INFILE '/media/pawel/b32141d8-7ca1-4197-820f-745c5f17b481/kaggle/flight/data/combined/asdifpcenter_c.csv' INTO TABLE asdifpcenter FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n'; 

LOAD DATA LOCAL INFILE '/media/pawel/b32141d8-7ca1-4197-820f-745c5f17b481/kaggle/flight/data/combined/asdifpfix_c.csv' INTO TABLE asdifpfix FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n'; 

LOAD DATA LOCAL INFILE '/media/pawel/b32141d8-7ca1-4197-820f-745c5f17b481/kaggle/flight/data/combined/asdifpsector_c.csv' INTO TABLE asdifpsector FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n'; 

LOAD DATA LOCAL INFILE '/media/pawel/b32141d8-7ca1-4197-820f-745c5f17b481/kaggle/flight/data/combined/asdifpwaypoint_c.csv' INTO TABLE asdifpwaypoint FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n'; 
*/

LOAD DATA LOCAL INFILE '/media/pawel/b32141d8-7ca1-4197-820f-745c5f17b481/kaggle/flight/data/combined/asdiposition_c.csv' INTO TABLE asdiposition FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n';

LOAD DATA LOCAL INFILE '/home/pawel/Dropbox/Flight_Quest/data_preparation/airport_coordinates.csv' INTO TABLE mapping_airports_coordinates FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n';  
