CREATE DATABASE motor_vehicle_thefts

select * from locations
select * from make_details
select * from stolen_vehicles

-- 1.Find the number of vehicles stolen each year

SELECT * FROM stolen_vehicles

SELECT YEAR(date_stolen), COUNT(vehicle_id) AS num_vehicles
FROM stolen_vehicles
GROUP BY YEAR(date_stolen)

-- 2.Find the number of vehicles stolen each month

SELECT YEAR(date_stolen), MONTH(date_stolen), COUNT(vehicle_id) AS num_vehicles
FROM stolen_vehicles
GROUP BY YEAR(date_stolen), MONTH(date_stolen)
ORDER BY YEAR(date_stolen), MONTH(date_stolen)

-- 3.Find the number of vehicles stolen each day of the week

SELECT 
    DATEPART(WEEKDAY, date_stolen) AS dow,
    COUNT(vehicle_id) AS num_vehicles
FROM stolen_vehicles
GROUP BY DATEPART(WEEKDAY, date_stolen)
ORDER BY dow;

-- 4. Replace the numeric day of week values with the full name of each day of the week (Sunday, Monday, Tuesday, etc.)

SELECT 
    DATEPART(WEEKDAY, date_stolen) AS dow,
    CASE 
        WHEN DATEPART(WEEKDAY, date_stolen) = 1 THEN 'Sunday'
        WHEN DATEPART(WEEKDAY, date_stolen) = 2 THEN 'Monday'
        WHEN DATEPART(WEEKDAY, date_stolen) = 3 THEN 'Tuesday'
        WHEN DATEPART(WEEKDAY, date_stolen) = 4 THEN 'Wednesday'
        WHEN DATEPART(WEEKDAY, date_stolen) = 5 THEN 'Thursday'
        WHEN DATEPART(WEEKDAY, date_stolen) = 6 THEN 'Friday'
        ELSE 'Saturday' 
    END AS day_of_week,
    COUNT(vehicle_id) AS num_vehicles
FROM stolen_vehicles
GROUP BY 
    DATEPART(WEEKDAY, date_stolen),
    CASE 
        WHEN DATEPART(WEEKDAY, date_stolen) = 1 THEN 'Sunday'
        WHEN DATEPART(WEEKDAY, date_stolen) = 2 THEN 'Monday'
        WHEN DATEPART(WEEKDAY, date_stolen) = 3 THEN 'Tuesday'
        WHEN DATEPART(WEEKDAY, date_stolen) = 4 THEN 'Wednesday'
        WHEN DATEPART(WEEKDAY, date_stolen) = 5 THEN 'Thursday'
        WHEN DATEPART(WEEKDAY, date_stolen) = 6 THEN 'Friday'
        ELSE 'Saturday' 
    END
ORDER BY dow;

-- 5.Create a bar chart that shows the number of vehicles stolen on each day of the week

-- 6. Find the vehicle types that are most often and least often stolen

SELECT * FROM stolen_vehicles

SELECT TOP 5 vehicle_type, COUNT(vehicle_id) AS num_vehicles
FROM stolen_vehicles
GROUP BY vehicle_type
ORDER BY num_vehicles DESC

SELECT TOP 5 vehicle_type, COUNT(vehicle_id) AS num_vehicles
FROM stolen_vehicles
GROUP BY vehicle_type
ORDER BY num_vehicles ASC

-- 7. For each vehicle type, find the average age of the cars that are stolen

SELECT vehicle_type, AVG(YEAR(date_stolen) - model_year) AS avg_age
FROM stolen_vehicles
GROUP BY vehicle_type
ORDER BY avg_age DESC

-- 8. For each vehicle type, find the percent of vehicles stolen that are luxury versus standard

SELECT * FROM stolen_vehicles
SELECT * FROM make_details

WITH lux_standard AS
(
    SELECT 
        vehicle_type, 
        CASE WHEN make_type = 'Luxury' THEN 1 ELSE 0 END AS luxury, 
        1 AS all_cars
    FROM stolen_vehicles sv
    LEFT JOIN make_details md ON md.make_id = sv.make_id
)
SELECT 
    vehicle_type, 
    ROUND(SUM(luxury) * 1.0 / SUM(all_cars) * 100, 2) AS pct_lux
FROM lux_standard
GROUP BY vehicle_type
ORDER BY pct_lux DESC;


-- 9. Create a table where the rows represent the top 10 vehicle types, 
--   the columns represent the top 7 vehicle colors (plus 1 column for all other colors) and the values are the number of vehicles stolen

SELECT * FROM stolen_vehicles

SELECT color, COUNT(vehicle_id) AS num_vehicles
FROM stolen_vehicles
GROUP BY color
ORDER BY num_vehicles DESC

SELECT TOP 10 vehicle_type, COUNT(vehicle_id) AS num_vehicles,
	SUM(CASE WHEN color = 'Silver' THEN 1 ELSE 0 END) AS silver,
	SUM(CASE WHEN color = 'White' THEN 1 ELSE 0 END) AS white,
	SUM(CASE WHEN color = 'Black' THEN 1 ELSE 0 END) AS black,
	SUM(CASE WHEN color = 'Blue' THEN 1 ELSE 0 END) AS blue,
	SUM(CASE WHEN color = 'Red' THEN 1 ELSE 0 END) AS red,
	SUM(CASE WHEN color = 'Grey' THEN 1 ELSE 0 END) AS grey,
	SUM(CASE WHEN color = 'Green' THEN 1 ELSE 0 END) AS green,
	SUM(CASE WHEN color IN ('Gold', 'Brown', 'Yellow', 'Orange', 'Purple', 'Cream', 'Pink') THEN 1 ELSE 0 END) AS other
FROM stolen_vehicles
GROUP BY vehicle_type
ORDER BY num_vehicles DESC

-- 10. Find the number of vehicles that were stolen in each region

SELECT * FROM stolen_vehicles
SELECT * FROM locations

SELECT region, COUNT(vehicle_id) AS num_vehicles
FROM stolen_vehicles sv
LEFT JOIN locations l on l.location_id = sv.location_id
GROUP BY region

-- 11. Combine the previous output with the population and density statistics for each region

SELECT l.region, COUNT(sv.vehicle_id) AS num_vehicles,
	l.population, l.density
FROM stolen_vehicles sv
LEFT JOIN locations l on l.location_id = sv.location_id
GROUP BY l.region, l.population, l.density
ORDER BY num_vehicles DESC

-- 12. Do the types of vehicles stolen in the three most dense regions differ from the three least dense regions?

SELECT l.region, COUNT(sv.vehicle_id) AS num_vehicles,
	l.population, l.density
FROM stolen_vehicles sv
LEFT JOIN locations l on l.location_id = sv.location_id
GROUP BY l.region, l.population, l.density
ORDER BY l.density DESC

(SELECT TOP 5 'High Density', sv.vehicle_type, COUNT(sv.vehicle_id) AS num_vehicles
FROM stolen_vehicles sv
LEFT JOIN locations l on l.location_id = sv.location_id
WHERE l.region IN ('Auckland', 'Nelson', 'Wellington')
GROUP BY sv.vehicle_type
)

UNION ALL

(SELECT TOP 5 'Low Density', sv.vehicle_type, COUNT(sv.vehicle_id) AS num_vehicles
FROM stolen_vehicles sv
LEFT JOIN locations l on l.location_id = sv.location_id
WHERE l.region IN ('Otago', 'Gisborne', 'Southland')
GROUP BY sv.vehicle_type
)

ORDER BY num_vehicles DESC

SELECT TOP 1
    l.region,
    COUNT(sv.vehicle_id) AS total_vehicles
FROM stolen_vehicles sv
LEFT JOIN locations l ON l.location_id = sv.location_id
GROUP BY l.region
ORDER BY total_vehicles DESC;
