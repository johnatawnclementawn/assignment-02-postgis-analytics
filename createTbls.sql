-- CREATE EXTENSION postgis; --

-- PHL Bus stops --
DROP TABLE IF EXISTS septa_bus_stops;
CREATE TABLE septa_bus_stops (
    stop_id				NUMERIC(7) PRIMARY KEY NOT NULL,
    stop_name			VARCHAR(65) NOT NULL, 
	stop_lat			FLOAT NOT NULL,
    stop_lon			FLOAT NOT NULL,
    location_type		NUMERIC(3),
	parent_station		NUMERIC(7),
	zone_id				NUMERIC(3),
	wheelchair_boarding	NUMERIC(3)
);

-- Import data into bus stop table --
COPY septa_bus_stops(stop_id, stop_name, stop_lat, stop_lon, location_type, parent_station, zone_id, wheelchair_boarding) 
FROM 'C:\Users\Public\CloudComputing_data\google_bus\stops.csv' 
DELIMITER ',' 
CSV HEADER;

-- Add geometry field to bus stop data --
ALTER TABLE septa_bus_stops ADD COLUMN the_geom geometry(Point, 4326);
UPDATE septa_bus_stops SET the_geom = ST_SetSRID(ST_MakePoint(stop_lon, stop_lat),4326);


-- PHL Bus Stop times --
DROP TABLE IF EXISTS septa_bus_stopTimes;
CREATE TABLE septa_bus_stopTimes (
	trip_id 			NUMERIC,
	-- USE VARCHAR for times here b/c there are values >24:00:00, and idk how to ignore/fix those --
	arrival_time		VARCHAR,
	departure_time		VARCHAR,
	stop_id				NUMERIC,
	stop_sequence		NUMERIC
);

-- Import data into bus trips table --
COPY septa_bus_stopTimes 
FROM 'C:\Users\Public\CloudComputing_data\google_bus\stop_times.txt' 
DELIMITER ','
CSV HEADER;


-- PHL Bus Trips --
DROP TABLE IF EXISTS septa_bus_trips;
CREATE TABLE septa_bus_trips (
    route_id			NUMERIC,
    service_id			NUMERIC,
	trip_id				NUMERIC PRIMARY KEY NOT NULL,   
	trip_headsign		VARCHAR(65) NOT NULL, 
	block_id			NUMERIC,
	direction_id		NUMERIC,
	shape_id			NUMERIC
);

-- Import data into bus trips table --
COPY septa_bus_trips 
FROM 'C:\Users\Public\CloudComputing_data\google_bus\trips.csv' 
DELIMITER ',' 
CSV HEADER;


-- PHL Bus Routes --
DROP TABLE IF EXISTS septa_bus_routes;
CREATE TABLE septa_bus_routes (
    route_id			VARCHAR,
    route_short_name	VARCHAR, 
	route_long_name		VARCHAR, 
	route_type			NUMERIC,
	route_color			VARCHAR,
	route_text_color	VARCHAR,
	route_url			VARCHAR
);

-- Import data into bus routes table --
COPY septa_bus_routes 
FROM 'C:\Users\Public\CloudComputing_data\google_bus\routes.csv' 
DELIMITER ',' 
CSV HEADER;



-- Septa Bus shapes --
DROP TABLE IF EXISTS septa_bus_shapes;
CREATE TABLE septa_bus_shapes (
    shape_id			NUMERIC(7) NOT NULL,
	shape_pt_lat		FLOAT NOT NULL,
    shape_pt_lon		FLOAT NOT NULL,
    shape_pt_sequence	NUMERIC(5)
);

COPY septa_bus_shapes(shape_id, shape_pt_lat, shape_pt_lon,shape_pt_sequence) 
FROM 'C:\Users\Public\CloudComputing_data\google_bus\shapes.csv' 
DELIMITER ',' 
CSV HEADER;

-- Add geometry field to bus routes data --
ALTER TABLE septa_bus_shapes ADD COLUMN the_geom geometry(Point, 4326);
UPDATE septa_bus_shapes SET the_geom = ST_SetSRID(ST_MakePoint(shape_pt_lon, shape_pt_lat),4326);



-- SEPTA rail stops --
DROP TABLE IF EXISTS septa_rail_stops;
CREATE TABLE septa_rail_stops(
    stop_id 	numeric,
    stop_name 	text,
    stop_desc 	text,
    stop_lat 	numeric,
    stop_lon 	numeric,
    zone_id 	text,
    stop_url 	text
);

COPY septa_rail_stops 
FROM 'C:\Users\Public\CloudComputing_data\google_rail\stops.csv' 
DELIMITER ',' 
CSV HEADER;

-- Add geometry field to bus routes data --
ALTER TABLE septa_rail_stops ADD COLUMN the_geom geometry(Point, 4326);
UPDATE septa_rail_stops SET the_geom = ST_SetSRID(ST_MakePoint(stop_lon, stop_lat),4326);



-- PHL Census Block Group Population join w/ census_block_groups_2010 --
DROP TABLE IF EXISTS population;
CREATE TABLE population (
    id		VARCHAR(23) PRIMARY KEY NOT NULL,
    name	VARCHAR(75) NOT NULL, 
	total	NUMERIC(7) NOT NULL
);

COPY population(id, name, total) 
FROM 'C:\Users\Public\CloudComputing_data\PHL_2010_blockGroupPopulation\phl_2010_blockGroup_population.csv' 
DELIMITER ',' 
CSV HEADER;


-- Edit block group shp geom column name & set its crs --
-- ALTER TABLE census_block_groups RENAME COLUMN geom TO the_geom;
--UPDATE census_block_groups SET the_geom = ST_Transform(ST_SetSRID(the_geom, 4326),32129);

-- Edit parcels shp geom column name & set its crs --
-- ALTER TABLE pwd_parcels RENAME COLUMN geom TO the_geom;
-- UPDATE pwd_parcels SET the_geom = ST_Transform(ST_SetSRID(the_geom, 4326),32129);


--ALTER TABLE neighborhoods_philadelphia RENAME COLUMN geom to the_geom;
--UPDATE neighborhoods_philadelphia SET the_geom = ST_Transform(ST_SetSRID(the_geom, 2272),32129);




-- Create spatial indices --
-- DROP INDEX IF EXISTS septa_bus_stops_the_geom_idx;
-- create index septa_bus_stops_the_geom_idx
--     on septa_bus_stops
--     using GiST(st_transform(the_geom, 32129));
	
-- DROP INDEX IF EXISTS pwd_parcels_the_geom_idx;
-- CREATE index pwd_parcels_the_geom_idx
-- 	on pwd_parcels
-- 	using GiST(the_geom);