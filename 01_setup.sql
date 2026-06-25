-- 01_setup.sql
-- Builds the staging and final analysis tables from the 2025 ride data.

-- Create datasets for staging and analysis
CREATE SCHEMA IF NOT EXISTS `exemplary-torch-471018-g9.cyclistic_staging`
OPTIONS(location = "US");

CREATE SCHEMA IF NOT EXISTS `exemplary-torch-471018-g9.cyclistic_analytics`
OPTIONS(location = "US");


-- Create staging table
CREATE OR REPLACE TABLE `exemplary-torch-471018-g9.cyclistic_staging.stg_rides`
PARTITION BY start_date
CLUSTER BY member_casual, rideable_type
AS

-- Format raw columns
WITH base AS (
    SELECT
        CAST(ride_id AS STRING) AS ride_id,
        CAST(rideable_type AS STRING) AS rideable_type,
        LOWER(TRIM(CAST(member_casual AS STRING))) AS member_casual,

        CAST(started_at AS TIMESTAMP) AS started_at,
        CAST(ended_at AS TIMESTAMP) AS ended_at,

        NULLIF(TRIM(CAST(start_station_name AS STRING)), '') AS start_station_name,
        NULLIF(TRIM(CAST(end_station_name AS STRING)), '') AS end_station_name,

        CAST(start_station_id AS STRING) AS start_station_id,
        CAST(end_station_id AS STRING) AS end_station_id,

        SAFE_CAST(start_lat AS FLOAT64) AS start_lat,
        SAFE_CAST(start_lng AS FLOAT64) AS start_lng,
        SAFE_CAST(end_lat AS FLOAT64) AS end_lat,
        SAFE_CAST(end_lng AS FLOAT64) AS end_lng

    FROM `exemplary-torch-471018-g9.cyclistic_raw.trips_2025`
),

-- Add columns for analysis
ride_features AS (
    SELECT
        ride_id,
        rideable_type,

        CASE
            WHEN member_casual IN ('member', 'casual') THEN member_casual
            ELSE NULL
        END AS member_casual,

        started_at,
        ended_at,

        DATE(started_at) AS start_date,
        EXTRACT(YEAR FROM started_at) AS start_year,
        EXTRACT(MONTH FROM started_at) AS start_month,
        EXTRACT(DAYOFWEEK FROM started_at) AS start_day_of_week,

        CASE EXTRACT(DAYOFWEEK FROM started_at)
            WHEN 1 THEN 'Sunday'
            WHEN 2 THEN 'Monday'
            WHEN 3 THEN 'Tuesday'
            WHEN 4 THEN 'Wednesday'
            WHEN 5 THEN 'Thursday'
            WHEN 6 THEN 'Friday'
            WHEN 7 THEN 'Saturday'
        END AS start_day_name,

        EXTRACT(HOUR FROM started_at) AS start_hour,

        CASE
            WHEN EXTRACT(MONTH FROM started_at) IN (12, 1, 2) THEN 'winter'
            WHEN EXTRACT(MONTH FROM started_at) IN (3, 4, 5) THEN 'spring'
            WHEN EXTRACT(MONTH FROM started_at) IN (6, 7, 8) THEN 'summer'
            ELSE 'fall'
        END AS season,

        EXTRACT(DAYOFWEEK FROM started_at) IN (1, 7) AS is_weekend,

        TIMESTAMP_DIFF(ended_at, started_at, SECOND) AS ride_length_sec,
        ROUND(TIMESTAMP_DIFF(ended_at, started_at, SECOND) / 60.0, 2) AS ride_length_min,

        start_station_name,
        end_station_name,
        start_station_id,
        end_station_id,
        start_lat,
        start_lng,
        end_lat,
        end_lng

    FROM base
)

-- Keep valid rides for 2025 only
SELECT *
FROM ride_features
WHERE
    ride_id IS NOT NULL
    AND started_at IS NOT NULL
    AND ended_at IS NOT NULL
    AND start_date >= DATE '2025-01-01'
    AND start_date < DATE '2026-01-01'
    AND ride_length_sec >= 60
    AND ride_length_sec <= 86400
    AND member_casual IS NOT NULL;


-- Create final analysis table
CREATE OR REPLACE TABLE `exemplary-torch-471018-g9.cyclistic_analytics.fact_rides`
PARTITION BY start_date
CLUSTER BY member_casual, rideable_type
AS

SELECT
    ride_id,
    rideable_type,
    member_casual,
    started_at,
    ended_at,
    start_date,
    start_year,
    start_month,
    start_day_of_week,
    start_day_name,
    start_hour,
    season,
    is_weekend,
    ride_length_sec,
    ride_length_min,
    start_station_name,
    end_station_name,
    start_station_id,
    end_station_id,
    start_lat,
    start_lng,
    end_lat,
    end_lng
FROM `exemplary-torch-471018-g9.cyclistic_staging.stg_rides`;