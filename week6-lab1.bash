# Enable Cloud Data Fusion in the Cloud Shell
gcloud services enable datafusion.googleapis.com

# Execute the following commands to create a new bucket and copy the relevant data into it:
export BUCKET=$GOOGLE_CLOUD_PROJECT
gsutil mb gs://$BUCKET
gsutil cp gs://cloud-training/OCBL017/ny-taxi-2018-sample.csv gs://$BUCKET

# Execute the following command to create a bucket for temporary storage items that Cloud Data Fusion will create
gsutil mb gs://$BUCKET-temp

# 