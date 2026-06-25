-- 03_kpis.sql
-- Analysis queries used to explore rider behaviour and build the dashboard.

-- Compare member and casual riders
SELECT
    member_casual,
    COUNT(*) AS total_rides,
    ROUND(AVG(ride_length_min), 2) AS avg_ride_length_min,
    ROUND(MIN(ride_length_min), 2) AS min_ride_length_min,
    ROUND(MAX(ride_length_min), 2) AS max_ride_length_min
FROM `exemplary-torch-471018-g9.cyclistic_analytics.fact_rides`
GROUP BY member_casual
ORDER BY total_rides DESC;


-- Compare rides by month
SELECT
    start_year,
    start_month,
    season,
    member_casual,
    COUNT(*) AS total_rides,
    ROUND(AVG(ride_length_min), 2) AS avg_ride_length_min
FROM `exemplary-torch-471018-g9.cyclistic_analytics.fact_rides`
GROUP BY
    start_year,
    start_month,
    season,
    member_casual
ORDER BY
    start_year,
    start_month,
    member_casual;


-- Compare rides by day of week
SELECT
    start_day_of_week,
    start_day_name,
    is_weekend,
    member_casual,
    COUNT(*) AS total_rides,
    ROUND(AVG(ride_length_min), 2) AS avg_ride_length_min
FROM `exemplary-torch-471018-g9.cyclistic_analytics.fact_rides`
GROUP BY
    start_day_of_week,
    start_day_name,
    is_weekend,
    member_casual
ORDER BY
    start_day_of_week,
    member_casual;


-- Compare rides by hour
SELECT
    start_hour,
    member_casual,
    COUNT(*) AS total_rides,
    ROUND(AVG(ride_length_min), 2) AS avg_ride_length_min
FROM `exemplary-torch-471018-g9.cyclistic_analytics.fact_rides`
GROUP BY
    start_hour,
    member_casual
ORDER BY
    start_hour,
    member_casual;


-- Compare rides by season
SELECT
    season,
    member_casual,
    COUNT(*) AS total_rides,
    ROUND(AVG(ride_length_min), 2) AS avg_ride_length_min
FROM `exemplary-torch-471018-g9.cyclistic_analytics.fact_rides`
GROUP BY
    season,
    member_casual
ORDER BY
    season,
    member_casual;


-- Compare bike type usage
SELECT
    rideable_type,
    member_casual,
    COUNT(*) AS total_rides,
    ROUND(AVG(ride_length_min), 2) AS avg_ride_length_min
FROM `exemplary-torch-471018-g9.cyclistic_analytics.fact_rides`
GROUP BY
    rideable_type,
    member_casual
ORDER BY
    rideable_type,
    member_casual;


-- Find the most popular start stations by rider type
WITH station_rankings AS (
    SELECT
        member_casual,
        start_station_name,
        COUNT(*) AS total_rides,
        ROUND(AVG(ride_length_min), 2) AS avg_ride_length_min,
        ROW_NUMBER() OVER (
            PARTITION BY member_casual
            ORDER BY COUNT(*) DESC
        ) AS station_rank
    FROM `exemplary-torch-471018-g9.cyclistic_analytics.fact_rides`
    WHERE start_station_name IS NOT NULL
    GROUP BY
        member_casual,
        start_station_name
)

SELECT
    member_casual,
    station_rank,
    start_station_name,
    total_rides,
    avg_ride_length_min
FROM station_rankings
WHERE station_rank <= 20
ORDER BY
    member_casual,
    station_rank;