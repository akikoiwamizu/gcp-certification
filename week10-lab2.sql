#In BigQuery's Query editor execute the following query:
SELECT
  COUNT(DISTINCT userId) numUsers,
  COUNT(DISTINCT movieId) numMovies,
  COUNT(*) totalRatings
FROM
  movies.movielens_ratings;

#Examine the first few movies using the query:
SELECT
  *
FROM
  movies.movielens_movies_raw
WHERE
  movieId < 5;

#We can see that the genres column is a formatted string. Parse the genres into an array and rewrite the results into a table named movielens_movies.
CREATE OR REPLACE TABLE
  movies.movielens_movies AS
SELECT
  * REPLACE(SPLIT(genres, "|") AS genres)
FROM
  movies.movielens_movies_raw;

#NOTE: The query below is for reference only. Please DO NOT EXECUTE this query in your project.
CREATE OR REPLACE MODEL movies.movie_recommender
OPTIONS (model_type='matrix_factorization', user_col='userId', item_col='movieId', rating_col='rating', l2_reg=0.2, num_factors=16) AS
SELECT userId, movieId, rating
FROM movies.movielens_ratings;
#Note, the num_factors and l2_reg options have been selected after much experimentation to speed up training of the model.

#To view metrics for the trained model, run the following query:
SELECT * FROM ML.EVALUATE(MODEL `cloud-training-prod-bucket.movies.movie_recommender`)
#ERROR: Request had invalid authentication credentials. Expected OAuth 2 access token, login cookie or other valid authentication credential. See https://developers.google.com/identity/sign-in/web/devconsole-project.

#With the trained model, we can now provide recommendations.
#Let’s find the best comedy movies to recommend to the user whose userId is 903. Enter the query below:
SELECT
  *
FROM
  ML.PREDICT(MODEL `cloud-training-prod-bucket.movies.movie_recommender`,
    (
    SELECT
      movieId,
      title,
      903 AS userId
    FROM
      `movies.movielens_movies`,
      UNNEST(genres) g
    WHERE
      g = 'Comedy' ))
ORDER BY
  predicted_rating DESC
LIMIT
  5;

#This result includes movies the user has already seen and rated in the past. Let’s remove them:
SELECT
  *
FROM
  ML.PREDICT(MODEL `cloud-training-prod-bucket.movies.movie_recommender`,
    (
    WITH
      seen AS (
      SELECT
        ARRAY_AGG(movieId) AS movies
      FROM
        movies.movielens_ratings
      WHERE
        userId = 903 )
    SELECT
      movieId,
      title,
      903 AS userId
    FROM
      movies.movielens_movies,
      UNNEST(genres) g,
      seen
    WHERE
      g = 'Comedy'
      AND movieId NOT IN UNNEST(seen.movies) ))
ORDER BY
  predicted_rating DESC
LIMIT
  5;

#We wish to get more reviews for movieId=96481 which has only one rating and we wish to send coupons to the 100 users 
#who are likely to rate it the highest. Identify those users using:
SELECT
  *
FROM
  ML.PREDICT(MODEL `cloud-training-prod-bucket.movies.movie_recommender`,
    (
    WITH
      allUsers AS (
      SELECT
        DISTINCT userId
      FROM
        movies.movielens_ratings )
    SELECT
      96481 AS movieId,
      (
      SELECT
        title
      FROM
        movies.movielens_movies
      WHERE
        movieId=96481) title,
      userId
    FROM
      allUsers ))
ORDER BY
  predicted_rating DESC
LIMIT
  100;

#What if we wish to carry out predictions for every user and movie combination? 
#Instead of having to pull distinct users and movies as in the previous query, a convenience function is provided
#to carry out batch predictions for all movieId and userId encountered during training.
#Enter the following query to obtain batch predictions:
SELECT
  *
FROM
  ML.RECOMMEND(MODEL `cloud-training-prod-bucket.movies.movie_recommender`)
LIMIT 
  100000;

#Without the LIMIT command the results would be too large to return given the default settings. 
#But the output provides you a sense of the type of predictions that can be made with this model.
#As seen in a section above, it is possible to filter out movies the user has already seen and rated in the past. 
#The reason already seen movies aren’t filtered out by default is that there are situations (think of restaurant recommendations.
#For example, where it is perfectly expected that we would need to recommend restaurants the user has liked in the past.




