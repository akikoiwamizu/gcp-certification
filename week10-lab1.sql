#To check whether the duration of a rental varies by station, we can visualize the result of the following query in Data Studio
SELECT
  start_station_name,
  AVG(duration) AS duration
FROM
  `bigquery-public-data`.london_bicycles.cycle_hire
GROUP BY
  start_station_name;

#For the next candidate features, the process is similar. We can check whether dayofweek (or, similarly, hourofday) matter.
SELECT
  EXTRACT(dayofweek
  FROM
    start_date) AS dayofweek,
  AVG(duration) AS duration
FROM
  `bigquery-public-data`.london_bicycles.cycle_hire
GROUP BY
  dayofweek;

#Another potential feature is the number of bikes in the station. 
#Perhaps, we hypothesize, people keep bicycles longer if there are fewer bicycles on rent at the station they rented from.
SELECT
  bikes_count,
  AVG(duration) AS duration
FROM
  `bigquery-public-data`.london_bicycles.cycle_hire
JOIN
  `bigquery-public-data`.london_bicycles.cycle_stations
ON
  cycle_hire.start_station_name = cycle_stations.name
GROUP BY
  bikes_count;

#Based on the exploration of the bicycles dataset and the relationship of various columns to the label column, 
#we can prepare the training dataset by pulling out the selected features and the label:
SELECT
  duration,
  start_station_name,
  CAST(EXTRACT(dayofweek
    FROM
      start_date) AS STRING) AS dayofweek,
  CAST(EXTRACT(hour
    FROM
      start_date) AS STRING) AS hourofday
FROM
  `bigquery-public-data`.london_bicycles.cycle_hire;

#To train the ML model and save it into the dataset bike_model, we need to call CREATE MODEL, which works similarly to CREATE TABLE. 
#Since the label we're trying to predict is numeric this is a regression problem, which is why the most appropriate option is to 
#choose linear_reg as the model type under OPTIONS. Enter the following query into the query editor:
CREATE OR REPLACE MODEL
  bike_model.model
OPTIONS
  (input_label_cols=['duration'],
    model_type='linear_reg') AS
SELECT
  duration,
  start_station_name,
  CAST(EXTRACT(dayofweek
    FROM
      start_date) AS STRING) AS dayofweek,
  CAST(EXTRACT(hour
    FROM
      start_date) AS STRING) AS hourofday
FROM
  `bigquery-public-data`.london_bicycles.cycle_hire;

#To see some metrics related to model training, enter the following query into the BigQuery editor window:
SELECT * FROM ML.EVALUATE(MODEL `bike_model.model`);
#The mean absolute error is 1026 seconds or about 17 minutes. 
#This means that we should expect to be able to predict the duration of bicycle rentals with an average error of about 17 minutes.

#Build a BigQuery ML model with the combined days of week feature using the following query:
CREATE OR REPLACE MODEL
  bike_model.model_weekday
OPTIONS
  (input_label_cols=['duration'],
    model_type='linear_reg') AS
SELECT
  duration,
  start_station_name,
IF
  (EXTRACT(dayofweek
    FROM
      start_date) BETWEEN 2 AND 6,
    'weekday',
    'weekend') AS dayofweek,
  CAST(EXTRACT(hour
    FROM
      start_date) AS STRING) AS hourofday
FROM
  `bigquery-public-data`.london_bicycles.cycle_hire;
#This model results in a mean absolute error of 967 seconds which is less than the 1026 seconds for the original model. Improvement!

#Based on the relationship between hourofday and the duration, we can experiment with bucketizing the variable into 4 bins
#Build a BigQuery ML model with the bucketized hour of day, and combined days of week features using the query below:
CREATE OR REPLACE MODEL
  bike_model.model_bucketized
OPTIONS
  (input_label_cols=['duration'],
    model_type='linear_reg') AS
SELECT
  duration,
  start_station_name,
IF
  (EXTRACT(dayofweek
    FROM
      start_date) BETWEEN 2 AND 6,
    'weekday',
    'weekend') AS dayofweek,
  ML.BUCKETIZE(EXTRACT(hour
    FROM
      start_date),
    [5, 10, 17]) AS hourofday
FROM
  `bigquery-public-data`.london_bicycles.cycle_hire;
#This model results in a mean absolute error of 901 seconds which is less than the 967 seconds for the weekday-weekend model. Futher improvement!

#Build a BigQuery ML model with the TRANSFORM clause that incorporates the bucketized hour of day, and combined days of week features using the query below:
CREATE OR REPLACE MODEL
  bike_model.model_bucketized TRANSFORM(* EXCEPT(start_date),
  IF
    (EXTRACT(dayofweek
      FROM
        start_date) BETWEEN 2 AND 6,
      'weekday',
      'weekend') AS dayofweek,
    ML.BUCKETIZE(EXTRACT(HOUR
      FROM
        start_date),
      [5, 10, 17]) AS hourofday )
OPTIONS
  (input_label_cols=['duration'],
    model_type='linear_reg') AS
SELECT
  duration,
  start_station_name,
  start_date
FROM
  `bigquery-public-data`.london_bicycles.cycle_hire;

#With the TRANSFORM clause in place, enter this query to predict the duration of a rental from Park Lane right now (your result will vary):
SELECT
  *
FROM
  ML.PREDICT(MODEL bike_model.model_bucketized,
    (
    SELECT
      'Park Lane , Hyde Park' AS start_station_name,
      CURRENT_TIMESTAMP() AS start_date) );

#To make batch predictions on a sample of 100 rows in the training set use the query:
SELECT
  *
FROM
  ML.PREDICT(MODEL bike_model.model_bucketized,
    (
    SELECT
      start_station_name,
      start_date
    FROM
      `bigquery-public-data`.london_bicycles.cycle_hire
    LIMIT
      100) );

#Examine (or export) the weights of your model using the query below:
SELECT * FROM ML.WEIGHTS(MODEL bike_model.model_bucketized);









