-- 02_quality_checks.sql
-- Data quality checks for the final analysis table.


-- Compare staging and final table row counts
SELECT 'stg_rides' AS table_name, COUNT(*) AS row_count
FROM `exemplary-torch-471018-g9.cyclistic_staging.stg_rides`

UNION ALL

SELECT 'fact_rides' AS table_name, COUNT(*) AS row_count
FROM `exemplary-torch-471018-g9.cyclistic_analytics.fact_rides`;


-- Check for duplicate ride IDs
SELECT
    COUNT(*) AS duplicate_ride_id_groups
FROM (
    SELECT
        ride_id
    FROM `exemplary-torch-471018-g9.cyclistic_analytics.fact_rides`
    GROUP BY ride_id
    HAVING COUNT(*) > 1
);


-- Check key fields for null values
SELECT
    COUNTIF(ride_id IS NULL) AS null_ride_id,
    COUNTIF(started_at IS NULL) AS null_started_at,
    COUNTIF(ended_at IS NULL) AS null_ended_at,
    COUNTIF(start_date IS NULL) AS null_start_date,
    COUNTIF(member_casual IS NULL) AS null_member_casual,
    COUNTIF(ride_length_sec IS NULL) AS null_ride_length_sec
FROM `exemplary-torch-471018-g9.cyclistic_analytics.fact_rides`;


-- Check ride duration range
SELECT
    MIN(ride_length_sec) AS min_ride_length_sec,
    MAX(ride_length_sec) AS max_ride_length_sec,
    AVG(ride_length_sec) AS avg_ride_length_sec
FROM `exemplary-torch-471018-g9.cyclistic_analytics.fact_rides`;


-- Check rider types
SELECT
    member_casual,
    COUNT(*) AS ride_count
FROM `exemplary-torch-471018-g9.cyclistic_analytics.fact_rides`
GROUP BY member_casual
ORDER BY ride_count DESC;


-- Check bike types
SELECT
    rideable_type,
    COUNT(*) AS ride_count
FROM `exemplary-torch-471018-g9.cyclistic_analytics.fact_rides`
GROUP BY rideable_type
ORDER BY ride_count DESC;


-- Check dates are within 2025
SELECT
    MIN(start_date) AS min_start_date,
    MAX(start_date) AS max_start_date,
    COUNT(DISTINCT start_date) AS distinct_active_days
FROM `exemplary-torch-471018-g9.cyclistic_analytics.fact_rides`;


-- Check missing station names
SELECT
    COUNTIF(TRIM(COALESCE(start_station_name, '')) = '') AS blank_start_station_name,
    COUNTIF(TRIM(COALESCE(end_station_name, '')) = '') AS blank_end_station_name
FROM `exemplary-torch-471018-g9.cyclistic_analytics.fact_rides`;


-- Check weekday and weekend values
SELECT
    start_day_of_week,
    start_day_name,
    is_weekend,
    COUNT(*) AS ride_count
FROM `exemplary-torch-471018-g9.cyclistic_analytics.fact_rides`
GROUP BY start_day_of_week, start_day_name, is_weekend
ORDER BY start_day_of_week;


-- Check coordinate values
SELECT
    COUNTIF(start_lat IS NOT NULL AND (start_lat < -90 OR start_lat > 90)) AS invalid_start_lat,
    COUNTIF(end_lat IS NOT NULL AND (end_lat < -90 OR end_lat > 90)) AS invalid_end_lat,
    COUNTIF(start_lng IS NOT NULL AND (start_lng < -180 OR start_lng > 180)) AS invalid_start_lng,
    COUNTIF(end_lng IS NOT NULL AND (end_lng < -180 OR end_lng > 180)) AS invalid_end_lng
FROM `exemplary-torch-471018-g9.cyclistic_analytics.fact_rides`;


-- Check rides by month
SELECT
    start_month,
    COUNT(*) AS ride_count
FROM `exemplary-torch-471018-g9.cyclistic_analytics.fact_rides`
GROUP BY start_month
ORDER BY start_month;