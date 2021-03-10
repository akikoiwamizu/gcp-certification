#You can list the active account name with this command:
gcloud auth list


#You can list the project ID with this command:
gcloud config list project


#To clone the Git repository for the lab enter the following command in Cloud Shell:
git -C ~ clone https://github.com/GoogleCloudPlatform/training-data-analyst


#To locate the default Cloud Storage bucket used by Cloud Dataproc enter the following command in Cloud Shell:
export DP_STORAGE="gs://$(gcloud dataproc clusters describe sparktodp --region=us-central1 --format=json | jq -r '.config.configBucket')"


#To copy the sample notebooks into the Jupyter working folder enter the following command in Cloud Shell:
gsutil -m cp ~/training-data-analyst/quests/sparktobq/*.ipynb $DP_STORAGE/notebooks/jupyter


#In the Cloud Shell create a new storage bucket for your source data:
export PROJECT_ID=$(gcloud info --format='value(config.project)')
gsutil mb gs://$PROJECT_ID


#In the Cloud Shell copy the source data into the bucket:
wget http://kdd.ics.uci.edu/databases/kddcup99/kddcup.data_10_percent.gz
gsutil cp kddcup.data_10_percent.gz gs://$PROJECT_ID/


#You now create a standalone Python file, that can be deployed as a Cloud Dataproc Job, 
#that will perform the same functions as this notebook. To do this you add magic commands 
#to the Python cells in a copy of this notebook to write the cell contents out to a file. 

#You will also add an input parameter handler to set the storage bucket location when the 
#Python script is called to make the code more portable.


#The %%writefile spark_analysis.py Jupyter magic command creates a new output file to contain your standalone python script.
#Paste the following library import and parameter handling code into this new first code cell:
%%writefile spark_analysis.py

import matplotlib
matplotlib.use('agg')

import argparse
parser = argparse.ArgumentParser()
parser.add_argument("--bucket", help="bucket for input and output")
args = parser.parse_args()

BUCKET = args.bucket


#For the remaining cells insert %%writefile -a spark_analysis.py at the start of each Python code cell. 
#These are the five cells labelled In [x].
%%writefile -a spark_analysis.py


#Paste the following code into the new cell at the bottom of the notebook.
%%writefile -a spark_analysis.py

ax[0].get_figure().savefig('report.png');


#Add another new cell at the end of the notebook and paste in the following:
%%writefile -a spark_analysis.py

import google.cloud.storage as gcs
bucket = gcs.Client().get_bucket(BUCKET)
for blob in bucket.list_blobs(prefix='sparktodp/'):
    blob.delete()
bucket.blob('sparktodp/report.png').upload_from_filename('report.png')


#Add a new cell at the end of the notebook and paste in the following:
%%writefile -a spark_analysis.py

connections_by_protocol.write.format("csv").mode("overwrite").save(
    "gs://{}/sparktodp/connections_by_protocol".format(BUCKET))


#In the PySpark-analysis-file notebook add a new cell at the end of the notebook and paste in the following:
BUCKET_list = !gcloud info --format='value(config.project)'
BUCKET=BUCKET_list[0]
print('Writing to {}'.format(BUCKET))
!/opt/conda/anaconda/bin/python spark_analysis.py --bucket=$BUCKET


#This lists the script output files that have been saved to your Cloud Storage bucket.
#Add a new cell at the end of the notebook and paste in the following:
!gsutil ls gs://$BUCKET/sparktodp/**



#To save a copy of the Python file to persistent storage, add a new cell and paste in the following:
!gsutil cp spark_analysis.py gs://$BUCKET/sparktodp/spark_analysis.py


#Switch to your Cloud Shell and copy the Python script from Cloud Storage so you can run it as a Cloud Dataproc Job.
gsutil cp gs://$PROJECT_ID/sparktodp/spark_analysis.py spark_analysis.py



#Create a launch script
nano submit_onejob.sh


#Paste the following into the script:
#!/bin/bash
gcloud dataproc jobs submit pyspark \
       --cluster sparktodp \
       --region us-central1 \
       spark_analysis.py \
       -- --bucket=$1


#Make the script executable:
chmod +x submit_onejob.sh


#Launch the PySpark Analysis job:
./submit_onejob.sh $PROJECT_ID





