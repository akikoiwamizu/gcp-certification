#Enter the following query in the BigQuery editor window:
#Query results window notice that the query completed in ~1.2s and processed ~372MB of data.
SELECT
  bike_id,
  duration
FROM
  `bigquery-public-data`.london_bicycles.cycle_hire
ORDER BY
  duration DESC
LIMIT 1;

#Enter the following query in the BigQuery editor window:
#Query results window notice that this query completed in ~4.5s and consumed ~2.6GB of data. Much longer!
SELECT
  *
FROM
  `bigquery-public-data`.london_bicycles.cycle_hire
ORDER BY
  duration DESC
LIMIT 1;


#Enter the following query into the BigQuery editor window:
SELECT
  MIN(start_station_name) AS start_station_name,
  MIN(end_station_name) AS end_station_name,
  APPROX_QUANTILES(duration, 10)[OFFSET (5)] AS typical_duration,
  COUNT(duration) AS num_trips
FROM
  `bigquery-public-data`.london_bicycles.cycle_hire
WHERE
  start_station_id != end_station_id
GROUP BY
  start_station_id,
  end_station_id
ORDER BY
  num_trips DESC
LIMIT 10;

#We can reduce the I/O overhead of the query if we do the filtering and grouping using the station name 
#rather than the station id since we will need to read fewer columns. 
#The above below avoids the need to read the two id columns.
#This speedup is caused by the downstream effects of reading less data.
SELECT
  start_station_name,
  end_station_name,
  APPROX_QUANTILES(duration, 10)[OFFSET(5)] AS typical_duration,
  COUNT(duration) AS num_trips
FROM
  `bigquery-public-data`.london_bicycles.cycle_hire
WHERE
  start_station_name != end_station_name
GROUP BY
  start_station_name,
  end_station_name
ORDER BY
  num_trips DESC
LIMIT 10;


#Suppose we wish to find the total distance traveled by each bicycle in our dataset.
#A naive way to do this would be to find the distance traveled in each trip undertaken by each bicycle and sum them up:
WITH trip_distance AS (
SELECT
  bike_id,
  ST_Distance(ST_GeogPoint(s.longitude,s.latitude),ST_GeogPoint(e.longitude,e.latitude)) AS distance
FROM
  `bigquery-public-data`.london_bicycles.cycle_hire,
  `bigquery-public-data`.london_bicycles.cycle_stations s,
  `bigquery-public-data`.london_bicycles.cycle_stations e
WHERE
  start_station_id = s.id
  AND end_station_id = e.id )

SELECT
  bike_id,
  SUM(distance)/1000 AS total_distance
FROM
  trip_distance
GROUP BY
  bike_id
ORDER BY
  total_distance DESC
LIMIT 5;


#Computing the distance is an expensive operation and we can avoid joining the cycle_stations table against 
#the cycle_hire table if we precompute the distances between all pairs of stations:
WITH stations AS (
SELECT
  s.id AS start_id,
  e.id AS end_id,
  ST_Distance(ST_GeogPoint(s.longitude,s.latitude),ST_GeogPoint(e.longitude,e.latitude)) AS distance
FROM
  `bigquery-public-data`.london_bicycles.cycle_stations s,
  `bigquery-public-data`.london_bicycles.cycle_stations e ),

trip_distance AS (
SELECT
  bike_id,
  distance
FROM
  `bigquery-public-data`.london_bicycles.cycle_hire,
  stations
WHERE
  start_station_id = start_id
  AND end_station_id = end_id )

SELECT
  bike_id,
  SUM(distance)/1000 AS total_distance
FROM
  trip_distance
GROUP BY
  bike_id
ORDER BY
  total_distance DESC
LIMIT 5;


#After creating a new dataset in the EU: Now you may execute the following query
CREATE OR REPLACE TABLE
  mydataset.typical_trip AS
SELECT
  start_station_name,
  end_station_name,
  APPROX_QUANTILES(duration, 10)[OFFSET (5)] AS typical_duration,
  COUNT(duration) AS num_trips
FROM
  `bigquery-public-data`.london_bicycles.cycle_hire
GROUP BY
  start_station_name,
  end_station_name;


#Use the table created to find days when bicycle trips are much longer than usual:
#Execution: 9.2sec, 1.7GB processed
SELECT
  EXTRACT (DATE
  FROM
    start_date) AS trip_date,
  APPROX_QUANTILES(duration / typical_duration, 10)[OFFSET(5)] AS ratio,
  COUNT(*) AS num_trips_on_day
FROM
  `bigquery-public-data`.london_bicycles.cycle_hire AS hire
JOIN
  mydataset.typical_trip AS trip
ON
  hire.start_station_name = trip.start_station_name
  AND hire.end_station_name = trip.end_station_name
  AND num_trips > 10
GROUP BY
  trip_date
HAVING
  num_trips_on_day > 10
ORDER BY
  ratio DESC
LIMIT 10;


#Use the WITH clause to find days when bicycle trips are much longer than usual:
#Execution: 17.2sec, 1.7GB processed
WITH
typical_trip AS (
SELECT
  start_station_name,
  end_station_name,
  APPROX_QUANTILES(duration, 10)[OFFSET (5)] AS typical_duration,
  COUNT(duration) AS num_trips
FROM
  `bigquery-public-data`.london_bicycles.cycle_hire
GROUP BY
  start_station_name,
  end_station_name )
SELECT
  EXTRACT (DATE
  FROM
    start_date) AS trip_date,
  APPROX_QUANTILES(duration / typical_duration, 10)[
OFFSET
  (5)] AS ratio,
  COUNT(*) AS num_trips_on_day
FROM
  `bigquery-public-data`.london_bicycles.cycle_hire AS hire
JOIN
  typical_trip AS trip
ON
  hire.start_station_name = trip.start_station_name
  AND hire.end_station_name = trip.end_station_name
  AND num_trips > 10
GROUP BY
  trip_date
HAVING
  num_trips_on_day > 10
ORDER BY
  ratio DESC
LIMIT 10;


#Instead of storing the bicycle station latitudes and longitudes 
#separately from the cycle hire information, we could create a denormalized table
CREATE OR REPLACE TABLE
  mydataset.london_bicycles_denorm AS
SELECT
  start_station_id,
  s.latitude AS start_latitude,
  s.longitude AS start_longitude,
  end_station_id,
  e.latitude AS end_latitude,
  e.longitude AS end_longitude
FROM
  `bigquery-public-data`.london_bicycles.cycle_hire AS h
JOIN
  `bigquery-public-data`.london_bicycles.cycle_stations AS s
ON
  h.start_station_id = s.id
JOIN
  `bigquery-public-data`.london_bicycles.cycle_stations AS e
ON
  h.end_station_id = e.id;


#It is possible to query the dataset to find the most common male names in 2015 in MA
SELECT
  name,
  number AS num_babies
FROM
  `bigquery-public-data`.usa_names.usa_1910_current
WHERE
  gender = 'M'
  AND year = 2015
  AND state = 'MA'
ORDER BY
  num_babies DESC
LIMIT 5;

#Similarly, query the dataset to find the most common female names in 2015 in the state of Massachusetts:
SELECT
  name,
  number AS num_babies
FROM
  `bigquery-public-data`.usa_names.usa_1910_current
WHERE
  gender = 'F'
  AND year = 2015
  AND state = 'MA'
ORDER BY
  num_babies DESC
LIMIT 5;


#What are the most common names assigned to both male and female babies in the country over all the years in the dataset? 
#A naive way to solve this problem involves reading the input table twice and doing a self-join:
#The self-JOIN unfortunately joins across state and year boundaries.
WITH male_babies AS (
SELECT
  name,
  number AS num_babies
FROM
  `bigquery-public-data`.usa_names.usa_1910_current
WHERE
  gender = 'M' ),

female_babies AS (
SELECT
  name,
  number AS num_babies
FROM
  `bigquery-public-data`.usa_names.usa_1910_current
WHERE
  gender = 'F' ),

both_genders AS (
SELECT
  name,
  SUM(m.num_babies) + SUM(f.num_babies) AS num_babies,
  SUM(m.num_babies) / (SUM(m.num_babies) + SUM(f.num_babies)) AS frac_male
FROM
  male_babies AS m
JOIN
  female_babies AS f
USING (name)
GROUP BY name )

SELECT *
FROM
  both_genders
WHERE
  frac_male BETWEEN 0.3 AND 0.7
ORDER BY
  num_babies DESC
LIMIT 5;


#A faster, more elegant (and correct!) solution is to recast the query to read the input only once
#and avoid the self-join completely.
WITH all_babies AS (
SELECT
  name,
  SUM(IF(gender = 'M', number, 0)) AS male_babies,
  SUM(IF(gender = 'F', number, 0)) AS female_babies
FROM
  `bigquery-public-data.usa_names.usa_1910_current`
GROUP BY name ),

both_genders AS (
SELECT
  name,
  (male_babies + female_babies) AS num_babies,
  SAFE_DIVIDE(male_babies, male_babies + female_babies) AS frac_male
FROM
  all_babies
WHERE
  male_babies > 0
  AND female_babies > 0 )

SELECT *
FROM
  both_genders
WHERE
  frac_male BETWEEN 0.3
  AND 0.7
ORDER BY
  num_babies DESC
LIMIT 5;


#It is possible to carry out the query above with an efficient join as long as we reduce the amount of data 
#being joined by grouping the data by name and gender early on:
WITH all_names AS (
SELECT
  name,
  gender,
  SUM(number) AS num_babies
FROM
  `bigquery-public-data`.usa_names.usa_1910_current
GROUP BY
  name,
  gender ),

male_names AS (
SELECT
  name,
  num_babies
FROM
  all_names
WHERE gender = 'M' ),

female_names AS (
SELECT
  name,
  num_babies
FROM
  all_names
WHERE gender = 'F' ),

ratio AS (
SELECT
  name,
  (f.num_babies + m.num_babies) AS num_babies,
  m.num_babies / (f.num_babies + m.num_babies) AS frac_male
FROM
  male_names AS m
JOIN
  female_names AS f
USING
  (name) )

SELECT
  *
FROM
  ratio
WHERE
  frac_male BETWEEN 0.3
  AND 0.7
ORDER BY
  num_babies DESC
LIMIT 5;


#You can, however, avoid a self-join by using a window function
SELECT
  bike_id,
  start_date,
  end_date,
  TIMESTAMP_DIFF( start_date, LAG(end_date) OVER (PARTITION BY bike_id ORDER BY start_date), SECOND) AS time_at_station
FROM
  `bigquery-public-data`.london_bicycles.cycle_hire
LIMIT 5;

#Using this, we can compute the average time that a bicycle is unused at each station and rank stations by that measure
WITH
unused AS (
  SELECT
    bike_id,
    start_station_name,
    start_date,
    end_date,
    TIMESTAMP_DIFF(start_date, LAG(end_date) OVER (PARTITION BY bike_id ORDER BY start_date), SECOND) AS time_at_station
  FROM
    `bigquery-public-data`.london_bicycles.cycle_hire )
SELECT
  start_station_name,
  AVG(time_at_station) AS unused_seconds
FROM
  unused
GROUP BY
  start_station_name
ORDER BY
  unused_seconds ASC
LIMIT 5;


#We could create a denormalized table with distances between stations and then compute the average pace:
#The below query invokes the geospatial function ST_DISTANCE once for each row in the cycle_hire table
WITH
  denormalized_table AS (
  SELECT
    start_station_name,
    end_station_name,
    ST_DISTANCE(ST_GeogPoint(s1.longitude,
        s1.latitude),
      ST_GeogPoint(s2.longitude,
        s2.latitude)) AS distance,
    duration
  FROM
    `bigquery-public-data`.london_bicycles.cycle_hire AS h
  JOIN
    `bigquery-public-data`.london_bicycles.cycle_stations AS s1
  ON
    h.start_station_id = s1.id
  JOIN
    `bigquery-public-data`.london_bicycles.cycle_stations AS s2
  ON
    h.end_station_id = s2.id ),
  durations AS (
  SELECT
    start_station_name,
    end_station_name,
    MIN(distance) AS distance,
    AVG(duration) AS duration,
    COUNT(*) AS num_rides
  FROM
    denormalized_table
  WHERE
    duration > 0
    AND distance > 0
  GROUP BY
    start_station_name,
    end_station_name
  HAVING
    num_rides > 100 )
SELECT
  start_station_name,
  end_station_name,
  distance,
  duration,
  duration/distance AS pace
FROM
  durations
ORDER BY
  pace ASC
LIMIT 5;


#Alternately, we can use the cycle_stations table to precompute the distance between every pair of stations 
#(this is a self-join) and then join it with the reduced-size table of average duration between stations:
#The recast query with the more efficient joins takes only 8.2 seconds, a 1.8x speedup and processes 554 MB, a nearly 4x reduction in cost.
WITH
  distances AS (
  SELECT
    a.id AS start_station_id,
    a.name AS start_station_name,
    b.id AS end_station_id,
    b.name AS end_station_name,
    ST_DISTANCE(ST_GeogPoint(a.longitude,
        a.latitude),
      ST_GeogPoint(b.longitude,
        b.latitude)) AS distance
  FROM
    `bigquery-public-data`.london_bicycles.cycle_stations a
  CROSS JOIN
    `bigquery-public-data`.london_bicycles.cycle_stations b
  WHERE
    a.id != b.id ),
  durations AS (
  SELECT
    start_station_id,
    end_station_id,
    AVG(duration) AS duration,
    COUNT(*) AS num_rides
  FROM
    `bigquery-public-data`.london_bicycles.cycle_hire
  WHERE
    duration > 0
  GROUP BY
    start_station_id,
    end_station_id
  HAVING
    num_rides > 100 )
SELECT
  start_station_name,
  end_station_name,
  distance,
  duration,
  duration/distance AS pace
FROM
  distances
JOIN
  durations
USING
  (start_station_id,
    end_station_id)
ORDER BY
  pace ASC
LIMIT 5;


#Let’s say that we wish to go through the rentals and number them 1, 2, 3, etc. 
#in the order that the rental ended. We could do that using the ROW_NUMBER() function
SELECT
  rental_id,
  ROW_NUMBER() OVER(ORDER BY end_date) AS rental_number
FROM
  `bigquery-public-data.london_bicycles.cycle_hire`
ORDER BY
  rental_number ASC
LIMIT 5;


#We might want to consider whether it is possible to limit the large sorts and distribute them. 
#Indeed, it is possible to extract the date from the rentals and then sort trips within each day:
WITH
  rentals_on_day AS (
  SELECT
    rental_id,
    end_date,
    EXTRACT(DATE
    FROM
      end_date) AS rental_date
  FROM
    `bigquery-public-data.london_bicycles.cycle_hire` )
SELECT
  rental_id,
  rental_date,
  ROW_NUMBER() OVER(PARTITION BY rental_date ORDER BY end_date) AS rental_number_on_day
FROM
  rentals_on_day
ORDER BY
  rental_date ASC,
  rental_number_on_day ASC
LIMIT 5;


#Because there are more than 3 million GitHub repositories and the commits are well distributed among them, this query succeeds 
SELECT
  repo_name,
  ARRAY_AGG(STRUCT(author,
      committer,
      subject,
      message,
      trailer,
      difference,
      encoding)
  ORDER BY
    author.date.seconds)
FROM
  `bigquery-public-data.github_repos.commits`,
  UNNEST(repo_name) AS repo_name
GROUP BY
  repo_name;


#Most of the people using GitHub live in only a few time zones, so grouping by the timezone fails -- we are asking a single worker to sort a significant fraction of 750GB:
SELECT
  author.tz_offset,
  ARRAY_AGG(STRUCT(author,
      committer,
      subject,
      message,
      trailer,
      difference,
      encoding)
  ORDER BY
    author.date.seconds)
FROM
  `bigquery-public-data.github_repos.commits`
GROUP BY
  author.tz_offset;


#For example, instead of grouping only by the time zone, it is possible to group by both timezone and repo_name and then aggregate across repos to get the actual answer for each timezone:
SELECT
  repo_name,
  author.tz_offset,
  ARRAY_AGG(STRUCT(author,
      committer,
      subject,
      message,
      trailer,
      difference,
      encoding)
  ORDER BY
    author.date.seconds)
FROM
  `bigquery-public-data.github_repos.commits`,
  UNNEST(repo_name) AS repo_name
GROUP BY
  repo_name,
  author.tz_offset;


#We can find the number of unique GitHub repositories using:
SELECT
  COUNT(DISTINCT repo_name) AS num_repos
FROM
  `bigquery-public-data`.github_repos.commits,
  UNNEST(repo_name) AS repo_name;

#Using the approximate function:
SELECT
  APPROX_COUNT_DISTINCT(repo_name) AS num_repos
FROM
  `bigquery-public-data`.github_repos.commits,
  UNNEST(repo_name) AS repo_name;














