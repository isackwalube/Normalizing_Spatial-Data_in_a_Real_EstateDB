--Create a new database
CREATE DATABASE "RealEstateDB";


-- Enable PostGIS
CREATE EXTENSION IF NOT EXISTS postgis;

--Create a non-normalized table
CREATE TABLE PropertyDetails (
    PropertyID SERIAL PRIMARY KEY, --means that the ID column will auto-generate an integer for every new row.
    Address VARCHAR(255),		-- variable character with maximum length of 255 characters
    City VARCHAR(100),
    State VARCHAR(50),
    Country VARCHAR(50),
    ZoningType VARCHAR(100),
    Utility VARCHAR(100),
    GeoLocation GEOMETRY(Point, 4326), -- Spatial data type
    CityPopulation INT
);

--Insert values in the columns
INSERT INTO PropertyDetails (Address, City, State,Country, ZoningType, Utility, GeoLocation, CityPopulation ) VALUES
('18 Clifton St', 'Worcester', 'MA', 'USA', 'Residential', 'ELectricity, Gas, Water, Sewage', 
 ST_GeomFromText('POINT(42.25511847420607 -71.82112851755157)', 4326), '205918' ),
('912 Main St', 'Leominster', 'MA', 'USA', 'Commercial', 'ELectricity, Gas, Water,Trash and Recycling', 
 ST_GeomFromText('POINT(42.251402479624915 -71.82033378143664)', 4326), '340918' ),
('2805 Deer Ridge Dr', 'Washington', 'MD', 'USA', 'Residential', 'ELectricity, Internet, Water, Sewage', 
 ST_GeomFromText('POINT(39.06599005325318 -76.951127790751)', 4326), '712816' ),
('330 Oregon Ave', 'Philadelphia', 'PA', 'USA', 'Commercial', 'ELectricity, Gas', 
 ST_GeomFromText('POINT(39.91337888826672 -75.15454622509978)', 4326), '1100898' ),
('23 Hawley St', 'Newton', 'MA', 'USA', 'Residential', 'ELectricity, Gas, Water, Sewage, Internet', 
 ST_GeomFromText('POINT(42.26229675356975 -71.81168804638733)', 4326), '175918' );

            --1NF--
--Create the PropertyUtilities table
CREATE TABLE PropertyUtilities (
    PropertyUtilityID SERIAL PRIMARY KEY,
    PropertyID INT REFERENCES PropertyDetails(PropertyID),
    Utility VARCHAR(100)
);

--Insert data into PropertyUtilities table linking the PropertyID with the associated utilities
INSERT INTO PropertyUtilities (PropertyID, Utility) VALUES
(1, 'ELectricity'),(1, 'Gas'),(1, 'Water'),(1, 'Sewage'),
(2, 'ELectricity'),(2, 'Gas'),(2, 'Water'),(2, 'Trash and Recycling'),
(3, 'ELectricity'),(3, 'Internet'),(3, 'Gas'),(3, 'Sewage'),
(4, 'ELectricity'),(4, 'Gas'),
(5, 'ELectricity'),(5, 'Internet'),(5, 'Water'),(5, 'Sewage'),(5, 'Internet');

--Modify the PropertyUtilities table by deleting the utility column
ALTER TABLE PropertyDetails DROP COLUMN Utility;

        --3NF--
--Create a table to remove transitive dependencies
CREATE TABLE CityDemographics (
    City VARCHAR(100) PRIMARY KEY,
    State VARCHAR(50),
    Country VARCHAR(50),
    CityPopulation INT
);

--Insert data into the new table(CityDemographics) by selecting the columns to insert from PropertyDetails table
INSERT INTO CityDemographics (City, State,Country, CityPopulation )
SELECT City, State,Country, CityPopulation
FROM PropertyDetails;

--Modify PropertyDetails table by deleteing the columns that were inserted in the CityDemographics table
ALTER TABLE PropertyDetails DROP COLUMN CityPopulation, DROP COLUMN State, DROP COLUMN Country;

				--4NF--
			
--To eliminate the multi-valued dependencies, we create the following tables
--Create the PropertyZoning table 
CREATE TABLE PropertyZoning (
    PropertyZoningID SERIAL PRIMARY KEY,
    PropertyID INT REFERENCES PropertyDetails(PropertyID),
    ZoningType VARCHAR(100)
);


--Insert data into the table directly from the PropertyDetails table
INSERT INTO PropertyZoning (PropertyID, ZoningType )
SELECT PropertyID, ZoningType
FROM PropertyDetails;




--Modify the PropertyDetails table by deleting the columns inserted in the new tables
ALTER TABLE PropertyDetails DROP COLUMN ZoningType, DROP COLUMN Utility;

--Check for proprties close to the selected property using ST_DWithin
SELECT Address, City
FROM PropertyDetails
WHERE ST_DWithin(
    GeoLocation,
    ST_GeomFromText('POINT(39.91337888826672 -75.15454622509978)', 4326),
    2 -- 
);












