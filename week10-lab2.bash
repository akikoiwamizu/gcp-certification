#Run the following command to create a BigQuery dataset named movies:
bq --location=EU mk --dataset movies

#Run the following commands separately in the Cloud Shell:
 bq load --source_format=CSV \
 --location=EU \
 --autodetect movies.movielens_ratings \
 gs://dataeng-movielens/ratings.csv

  bq load --source_format=CSV \
 --location=EU   \
 --autodetect movies.movielens_movies_raw \
 gs://dataeng-movielens/movies.csv