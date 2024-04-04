-- B. Transformation function

CREATE OR REPLACE FUNCTION format_rental_duration(duration_hours DOUBLE PRECISION)
RETURNS VARCHAR AS $$
DECLARE
	hours INT;
	minutes INT;
BEGIN
	hours := FLOOR(duration_hours);
	minutes := ROUND((duration_hours - hours)*60);
	RETURN hours || ' hours and ' || minutes || ' minutes';
END;
$$ LANGUAGE plpgsql;


-- Check with hardcoded timestamps
WITH rental_data AS (
    SELECT 
        TIMESTAMP '2024-03-15 10:00:00' AS rental_date,
        TIMESTAMP '2024-03-16 13:30:00' AS return_date
)
SELECT 
    EXTRACT(EPOCH FROM (return_date - rental_date)) / 3600 AS rental_duration,
    format_rental_duration(EXTRACT(EPOCH FROM (return_date - rental_date)) / 3600) AS formatted_rental_duration
FROM 
    rental_data;




-- C. Create Detailed and Summary Tables (rental_duration_tracker and rental_duration_trends)

CREATE TABLE rental_duration_tracker(
	rental_id INTEGER PRIMARY KEY,
	film_id INTEGER,
	film_title VARCHAR(255),
	rental_duration FLOAT,
	rental_date TIMESTAMP,
	return_date TIMESTAMP
);

CREATE TABLE rental_duration_trends(
	film_id INTEGER PRIMARY KEY,
	film_title VARCHAR(255),
	avg_rental_duration VARCHAR,
	total_rentals INTEGER
);

-- Verify that fields are correctly defined
SELECT * FROM rental_duration_tracker;
SELECT * FROM rental_duration_trends;





-- D. Extracting raw data needed into the detailed (rental_duration_tracker) table

INSERT INTO rental_duration_tracker (rental_id, film_id, film_title, rental_duration, rental_date, return_date)
SELECT
	r.rental_id,
	i.film_id,
	f.title AS film_title,
	ROUND(EXTRACT(EPOCH FROM (r.return_date - r.rental_date)) / 3600.0, 2) AS rental_duration,
	r.rental_date,
	r.return_date
FROM
	rental r
JOIN
	inventory i ON r.inventory_id = i.inventory_id
JOIN
	film f ON i.film_id = f.film_id;

-- Check detailed table
SELECT *
FROM rental_duration_tracker
ORDER BY film_id, rental_id;




-- E. Create trigger to update the summary table alongside the detailed table

-- Create Trigger to Update Summary Table
CREATE OR REPLACE FUNCTION update_summary_table()
RETURNS TRIGGER AS $$
BEGIN
    -- Update total_rentals in summary table for the inserted film
    INSERT INTO rental_duration_trends (film_id, film_title, avg_rental_duration, total_rentals)
    VALUES (
        NEW.film_id,
        NEW.film_title,
        (SELECT FORMAT_RENTAL_DURATION(AVG(rental_duration)) FROM rental_duration_tracker WHERE film_id = NEW.film_id),
        1
    )
    ON CONFLICT (film_id)
    DO UPDATE SET
        avg_rental_duration = (SELECT FORMAT_RENTAL_DURATION(AVG(rental_duration)) FROM rental_duration_tracker WHERE film_id = NEW.film_id),
        total_rentals = rental_duration_trends.total_rentals + 1;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create Trigger on Detailed Table
CREATE OR REPLACE TRIGGER update_summary_trigger
AFTER INSERT ON rental_duration_tracker
FOR EACH ROW
EXECUTE FUNCTION update_summary_table();


TRUNCATE TABLE rental_duration_tracker;
TRUNCATE TABLE rental_duration_trends;

-- Insert data into rental_duration_tracker table
INSERT INTO rental_duration_tracker (rental_id, film_id, film_title, rental_duration, rental_date, return_date)
VALUES
    (1, 1, 'Film 1', 2.5, '2024-04-01 12:00:00', '2024-04-03 10:30:00'),
    (2, 1, 'Film 1', 3.0, '2024-04-02 10:00:00', '2024-04-05 14:45:00'),
    (3, 1, 'Film 1', 2.7, '2024-04-03 08:00:00', '2024-04-05 16:20:00'),
    (4, 2, 'Film 2', 4.2, '2024-04-01 14:30:00', '2024-04-04 09:45:00'),
    (5, 2, 'Film 2', 3.5, '2024-04-02 09:00:00', '2024-04-05 11:20:00'),
    (6, 3, 'Film 3', 3.8, '2024-04-02 12:00:00', '2024-04-04 10:30:00');

-- Check if records were updated
SELECT * FROM rental_duration_trends;




-- F. Stored procedure

CREATE OR REPLACE PROCEDURE refresh_data() AS $$
BEGIN
	TRUNCATE TABLE rental_duration_tracker;
	TRUNCATE TABLE rental_duration_trends;
	INSERT INTO rental_duration_tracker (rental_id, film_id, film_title, rental_duration, rental_date, return_date)
	SELECT
		r.rental_id,
		i.film_id,
		f.title AS film_title,
		ROUND(EXTRACT(EPOCH FROM (r.return_date - r.rental_date))/3600, 2) AS rental_duration,
		r.rental_date,
		r.return_date
	FROM
		rental r
	JOIN
		inventory i ON r.inventory_id = i.inventory_id
	JOIN
		film f ON i.film_id = f.film_id;
END;
$$ LANGUAGE plpgsql;

-- Call procedure
CALL refresh_data();

-- Check tables

SELECT * FROM rental_duration_tracker
ORDER BY rental_id, film_id;

SELECT * FROM rental_duration_trends
ORDER BY (SUBSTRING(avg_rental_duration FROM '([0-9]+) hours')::INTEGER * 60 + SUBSTRING(avg_rental_duration FROM '([0-9]+) minutes')::INTEGER) DESC;




--Drop Everything

DROP TRIGGER IF EXISTS update_summary_trigger ON rental_duration_tracker;
DROP FUNCTION IF EXISTS update_summary_table();
DROP TABLE IF EXISTS rental_duration_tracker;
DROP TABLE IF EXISTS rental_duration_trends;
DROP FUNCTION IF EXISTS format_rental_duration;
DROP PROCEDURE IF EXISTS refresh_data;