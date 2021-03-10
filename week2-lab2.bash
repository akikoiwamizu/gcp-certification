# Make a new bucket to hold your training. 
# We use the magic variable $DEVSHELL_PROJECT_ID, which knows your current project, and simply add -vcm to the end.
gsutil mb -p $DEVSHELL_PROJECT_ID \
    -c regional    \
    -l us-central1 \
    gs://$DEVSHELL_PROJECT_ID-vcm/


# The training images are publicly available in a Cloud Storage bucket. Use the gsutil command-line utility for Cloud Storage to copy the training images into your bucket
gsutil -m cp -r gs://cloud-training/automl-lab-clouds/* gs://$DEVSHELL_PROJECT_ID-vcm/

# Once copying is complete you can view the three types of clouds you have images 
gsutil ls gs://$DEVSHELL_PROJECT_ID-vcm/

# Run the following commands which:
	# Copy the template file to your Cloud Shell instance
	# Update the CSV with the files in your project
	# Upload this file to your Cloud Storage bucket
	# Show the bucket to confirm the data.csv file is present
gsutil cp gs://cloud-training/automl-lab-clouds/data.csv .
head --lines=10 data.csv
sed -i -e "s/placeholder/$DEVSHELL_PROJECT_ID-vcm/g" ./data.csv
head --lines=10 data.csv
gsutil cp ./data.csv gs://$DEVSHELL_PROJECT_ID-vcm/
gsutil ls gs://$DEVSHELL_PROJECT_ID-vcm/

# View all the folders and files in your bucket you can add a wildcard
gsutil ls gs://$DEVSHELL_PROJECT_ID-vcm/*

# Note the location of the data.csv to input that location as the AutoML training dataset
 

