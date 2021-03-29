#Execute the following Python install command by hitting Shift + Enter in the first cell of the notebook 
#to install the google-cloud-bigquery library at version 1.25.0
!pip install google-cloud-bigquery==1.25.0 --use-feature=2020-resolver

#Restart the kernel by clicking Restart kernel icon > Restart.

#Enter the following in the second cell of the notebook:
%%bigquery df
SELECT
  departure_delay,
  COUNT(1) AS num_flights,
  APPROX_QUANTILES(arrival_delay, 10) AS arrival_delay_deciles
FROM
  `bigquery-samples.airline_ontime_data.flights`
GROUP BY
  departure_delay
HAVING
  num_flights > 100
ORDER BY
  departure_delay ASC;

#View the first five rows of the query's output by executing the following code in a new cell:
df.head()

#To get a DataFrame containing the data we need we first have to wrangle the raw query output. 
#Enter the following code in a new cell to convert the list of arrival_delay_deciles into a Pandas Series object. 
#The code also renames the resulting columns.
import pandas as pd

percentiles = df['arrival_delay_deciles'].apply(pd.Series)
percentiles.rename(columns = lambda x : '{0}%'.format(x*10), inplace=True)
percentiles.head()

#Since we want to relate departure delay times to arrival delay times we have to concatenate our percentiles table
#to the departure_delay field in our original DataFrame. Execute the following code in a new cell:
df = pd.concat([df['departure_delay'], percentiles], axis=1)
df.head()

#Before plotting the contents of our DataFrame, we'll want to drop extreme values stored in the 0% and 100% fields. 
#Execute the following code in a new cell:
df.drop(labels=['0%', '100%'], axis=1, inplace=True)
df.plot(x='departure_delay', xlim=(-30,50), ylim=(-50,50));