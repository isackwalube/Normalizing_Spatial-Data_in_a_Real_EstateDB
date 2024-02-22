

# **Normalizing Spatial Data in a Real Estate Database**

## *Part 1: Introduction*
  Database Normalization is a process in which data can be structured to minimize redundancy and dependency, 
  improve data integrity, and ensure efficient data management. 
  This assignment focuses on 3NF and 4NF.

  The initial table(PropertyDetails) created was non-normalized since the utilities column did not contain atomic values in 1NF.
  To normalize the table to 1NF, a separate table containing Property utilities was created, and the column
  deleted from the first table(PropertyDetails).
  The PropertyDetails table then remained with atomic values in all columns, therefore attaining 2NF status already. 

## *Overall significance of 3NF and 4NF*

  Third Normal Form (3NF) and Fourth Normal Form (4NF) are important concepts in database normalization, a process used 
  to design and organize relational databases efficiently while minimizing redundancy and dependency issues. 

*Third Normal Form (3NF)*
 3NF builds upon both the concepts of First Normal Form (1NF) and Second Normal Form (2NF) by further
 reducing redundancy and eliminating transitive dependencies. For instance, the first table created had 
 a **non-primary key attribute**(City)  acting as a primary key for other **non-primary key attributes**
 (city population, country, State).
 to eliminate such a transitive dependency from our database table, we created a new table(**CityDemographics), populated it, 
 and deleted the columns from the main table ensuring that every non-primary key attribute is directly dependent on the 
 primary key hence reducing redundancy, minimizing anomalies, and promoting data integrity.
   

*Fourth Normal Form (4NF)*
4NF extends the normalization process by addressing multi-valued dependencies, which occur when a non-key attribute is functionally
dependent on part of the primary key rather than the whole key. It aims to further improve data integrity and reduce redundancy.
For instance, in the PropertyDetails table, a **non-key attribute(ZoningType) was partially dependent on the primary key(PropertyID), 
therefore to ensure that our table is in 4NF, we created a separate table (PropertyZoning), and inserted data(PropertyID and ZoningType)
from the PropertyDetails table, and deleted the 2 columns from the main table(PropertyDetails) hence ensuring that the table contains 
no multi-valued dependencies thus educing redundancy and promoting data integrity.
   
## *Part 2: Code Block* 
Create a new database

`CREATE DATABASE "RealEstateDB";`


1. Enable PostGIS

`CREATE EXTENSION IF NOT EXISTS postgis;`


2. Create a non-normalized table

`CREATE TABLE PropertyDetails (
    PropertyID SERIAL PRIMARY KEY, --means that the ID column will auto-generate an integer for every new row.
    Address VARCHAR(255),		-- a variable character with a maximum length of 255 characters
    City VARCHAR(100),
    State VARCHAR(50),
    Country VARCHAR(50),
    ZoningType VARCHAR(100),
    Utility VARCHAR(100),
    GeoLocation GEOMETRY(Point, 4326), -- Spatial data type
    CityPopulation INT
);`


3. Insert values in the columns

`INSERT INTO PropertyDetails (Address, City, State, Country, ZoningType, Utility, GeoLocation, CityPopulation ) VALUES
('18 Clifton St', 'Worcester', 'MA', 'USA', 'Residential', 'ELectricity, Gas, Water, Sewage', 
 ST_GeomFromText('POINT(42.25511847420607 -71.82112851755157)', 4326), '205918' ),
('912 Main St', 'Leominster', 'MA', 'USA', 'Commercial', 'ELectricity, Gas, Water, Trash and Recycling', 
 ST_GeomFromText('POINT(42.251402479624915 -71.82033378143664)', 4326), '340918' ),
('2805 Deer Ridge Dr', 'Washington', 'MD', 'USA', 'Residential', 'ELectricity, Internet, Water, Sewage', 
 ST_GeomFromText('POINT(39.06599005325318 -76.951127790751)', 4326), '712816' ),
('330 Oregon Ave', 'Philadelphia', 'PA', 'USA', 'Commercial', 'ELectricity, Gas', 
 ST_GeomFromText('POINT(39.91337888826672 -75.15454622509978)', 4326), '1100898' ),
('23 Hawley St', 'Newton', 'MA', 'USA', 'Residential', 'ELectricity, Gas, Water, Sewage, Internet', 
 ST_GeomFromText('POINT(42.26229675356975 -71.81168804638733)', 4326), '175918' );`

![PropertyDetails](https://github.com/isackwalube/Normalizing_Spatial-Data_in_a_Real_EstateDB/assets/156945477/72faf878-6935-42c0-99e9-9b415900b745)




  ## *1NF**
4. Create the PropertyUtilities table to ensure that the table is in 1NF

`CREATE TABLE PropertyUtilities (
    PropertyUtilityID SERIAL PRIMARY KEY,
    PropertyID INT REFERENCES PropertyDetails(PropertyID),
    Utility VARCHAR(100)
);`


5. Insert data into the PropertyUtilities table linking the PropertyID with the associated utilities

`INSERT INTO PropertyUtilities (PropertyID, Utility) VALUES
(1, 'ELectricity'),(1, 'Gas'),(1, 'Water'),(1, 'Sewage'),
(2, 'ELectricity'),(2, 'Gas'),(2, 'Water'),(2, 'Trash and Recycling'),
(3, 'ELectricity'),(3, 'Internet'),(3, 'Gas'),(3, 'Sewage'),
(4, 'ELectricity'),(4, 'Gas'),
(5, 'ELectricity'),(5, 'Internet'),(5, 'Water'),(5, 'Sewage'),(5, 'Internet');`


![Propertyutilities](https://github.com/isackwalube/Normalizing_Spatial-Data_in_a_Real_EstateDB/assets/156945477/2f9b3e80-d3b6-4c1e-8135-a55468703741)



6. Modify the PropertyUtilities table by deleting the utility column

`ALTER TABLE PropertyDetails DROP COLUMN Utility;`

![PropertyDetails_1NF](https://github.com/isackwalube/Normalizing_Spatial-Data_in_a_Real_EstateDB/assets/156945477/8616b14d-a3df-43bf-8018-eca95c6ea621)



  ## *3NF**
7. Create a table to remove transitive dependencies

`CREATE TABLE CityDemographics (
    City VARCHAR(100) PRIMARY KEY,
    State VARCHAR(50),
    Country VARCHAR(50),
    CityPopulation INT
);`


8. Insert data into the new table(CityDemographics) by selecting the columns to insert from PropertyDetails table

`INSERT INTO CityDemographics (City, State, Country, CityPopulation )
SELECT City, State, Country, CityPopulation
FROM PropertyDetails;`

![citydemographics](https://github.com/isackwalube/Normalizing_Spatial-Data_in_a_Real_EstateDB/assets/156945477/194d8841-d2e6-4826-b7f4-625319bd35da)




9. Modify the PropertyDetails table by deleting the columns that were inserted in the CityDemographics table

`ALTER TABLE PropertyDetails DROP COLUMN CityPopulation, DROP COLUMN State, DROP COLUMN Country;`


## *4NF*				
			
10. To eliminate the multi-valued dependencies, we create the PropertyZoning table.

`CREATE TABLE PropertyZoning (
    PropertyZoningID SERIAL PRIMARY KEY,
    PropertyID INT REFERENCES PropertyDetails(PropertyID),
    ZoningType VARCHAR(100)
);`


11. Insert data into the table directly from the PropertyDetails table

`INSERT INTO PropertyZoning (PropertyID, ZoningType )
SELECT PropertyID, ZoningType
FROM PropertyDetails;`


![PropertyZoning](https://github.com/isackwalube/Normalizing_Spatial-Data_in_a_Real_EstateDB/assets/156945477/dbb65690-1a5f-4874-81a2-35515bdeb413)



12. Modify the PropertyDetails table by deleting the columns inserted in the new tables

`ALTER TABLE PropertyDetails DROP COLUMN ZoningType, DROP COLUMN Utility;`

![Propertydetails_Final](https://github.com/isackwalube/Normalizing_Spatial-Data_in_a_Real_EstateDB/assets/156945477/6606f830-5277-4864-a6fd-c4b62aba91a3)


13. Check for properties close to the selected property using ST_DWithin

`SELECT Address, City
FROM PropertyDetails
WHERE ST_DWithin(
    GeoLocation,
    ST_GeomFromText('POINT(39.91337888826672 -75.15454622509978)', 4326),
    2 -- 
);`


![ST_DWithin](https://github.com/isackwalube/Normalizing_Spatial-Data_in_a_Real_EstateDB/assets/156945477/a1adc9bb-9a13-4794-a7c9-32da81629fea)

Only 1 property was close to the property at 2805 Deer Ridge Dr.

### Challenges
In this assignment, given that the entire assignment was based on the data we created ourselves, I had a minor challenge in
inserting data into the PropertyUtilities table from the PropertyDetails table matching the values in the PropertyID foreign 
key in both tables.

### Solutions
I inserted the values manually to match the PropertyID and PropertyUtilities in both tables.
 
Conclusion
Overall, both 3NF and 4NF play crucial roles in database design by promoting data integrity, minimizing redundancy, and
reducing data anomalies. 
Complying with these normalization standards ensures that databases are efficient and maintainable in the long run.



 
