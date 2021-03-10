# BigQuery visually displays arrays as flattened. 
# It simply lists the value in the array vertically (note that all of those values still belong to a single row)
SELECT
['raspberry', 'blackberry', 'strawberry', 'cherry'] AS fruit_array;

#standardSQL
SELECT
['raspberry', 'blackberry', 'strawberry', 'cherry', 1234567] AS fruit_array;

#standardSQL
SELECT person, fruit_array, total_cost FROM `data-to-insights.advanced.fruit_store`;


# Don't have arrays in your tables already? You can create them!
# Copy and Paste the below query to explore this public dataset
# Returns: 111 rows
SELECT
  fullVisitorId,
  date,
  v2ProductName,
  pageTitle
  FROM `data-to-insights.ecommerce.all_sessions`
WHERE visitId = 1501570398
ORDER BY date;


# We will use the ARRAY_AGG() function to aggregate our string values into an array
# Returns: 2 - one for each day
SELECT
  fullVisitorId,
  date,
  ARRAY_AGG(v2ProductName) AS products_viewed,
  ARRAY_AGG(pageTitle) AS pages_viewed
  FROM `data-to-insights.ecommerce.all_sessions`
WHERE visitId = 1501570398
GROUP BY fullVisitorId, date
ORDER BY date;


# We will use the ARRAY_LENGTH() function to count the number of pages and products that were viewed.
SELECT
  fullVisitorId,
  date,
  ARRAY_AGG(v2ProductName) AS products_viewed,
  ARRAY_LENGTH(ARRAY_AGG(v2ProductName)) AS num_products_viewed,
  ARRAY_AGG(pageTitle) AS pages_viewed,
  ARRAY_LENGTH(ARRAY_AGG(pageTitle)) AS num_pages_viewed
  FROM `data-to-insights.ecommerce.all_sessions`
WHERE visitId = 1501570398
GROUP BY fullVisitorId, date
ORDER BY date;


# Next, lets deduplicate the pages and products so we can see how many unique products were viewed. 
# We'll simply add DISTINCT to our ARRAY_AGG()
SELECT
  fullVisitorId,
  date,
  ARRAY_AGG(DISTINCT v2ProductName) AS products_viewed,
  ARRAY_LENGTH(ARRAY_AGG(DISTINCT v2ProductName)) AS distinct_products_viewed,
  ARRAY_AGG(DISTINCT pageTitle) AS pages_viewed,
  ARRAY_LENGTH(ARRAY_AGG(DISTINCT pageTitle)) AS distinct_pages_viewed
  FROM `data-to-insights.ecommerce.all_sessions`
WHERE visitId = 1501570398
GROUP BY fullVisitorId, date
ORDER BY date;


# Before we can query REPEATED fields (arrays) normally, you must first break the arrays back into rows.
# Use the UNNEST() function on your array field:
SELECT DISTINCT
  visitId,
  h.page.pageTitle
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_20170801`,
UNNEST(hits) AS h
WHERE visitId = 1501570398
LIMIT 10;


# The main advantage of having 32 STRUCTs in a single table is it allows you to run queries like this one without having to do any JOINs:
# Note: The .* syntax tells BigQuery to return all fields for that STRUCT (much like it would if totals.* was a separate table we joined against)
SELECT
  visitId,
  totals.*,
  device.*
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_20170801`
WHERE visitId = 1501570398
LIMIT 10;


# Try out the STRUCT syntax and note the different field types within the struct container:
SELECT STRUCT("Rudisha" as name, 23.4 as split) as runner;


# What if the runner has multiple split times for a single race (like time per lap)?
# With an array of course! Run the below query to confirm:
SELECT STRUCT("Rudisha" as name, [23.4, 26.3, 26.4, 26.1] as splits) AS runner;


# Let's see all of our racers for the 800 Meter race
SELECT * FROM racing.race_results


# What if you wanted to list the name of each runner and the type of race?
# Even though the participants STRUCT is like a table, it is still technically a field in the racing.race_results table.
SELECT race, participants.name
FROM racing.race_results
CROSS JOIN race_results.participants # full STRUCT names  # this is the STRUCT (it's like a table within a table)


# This will give you the same query result:
SELECT race, participants.name
FROM racing.race_results AS r
, r.participants


# Task: Write a query to COUNT how many racers were there in total.
SELECT COUNT(p.name) AS racer_count
FROM racing.race_results AS r
, UNNEST(r.participants) AS p


# Task: Write a query that will list the total race time for racers whose names begin with R. Order the results with the fastest total time first. 
# Use the UNNEST() operator and start with the partially written query below.
SELECT
  p.name,
  SUM(split_times) as total_race_time
FROM racing.race_results AS r
, UNNEST(r.participants) AS p
, UNNEST(p.splits) AS split_times
WHERE p.name LIKE 'R%'
GROUP BY p.name
ORDER BY total_race_time ASC;


#Task: You happened to see that the fastest lap time recorded for the 800 M race was 23.2 seconds, but you did not see which runner ran that particular lap. Create a query that returns that result.
SELECT
  p.name,
  split_time
FROM racing.race_results AS r
, UNNEST(r.participants) AS p
, UNNEST(p.splits) AS split_time
WHERE split_time = 23.2;

