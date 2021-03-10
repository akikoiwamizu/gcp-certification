# Clone the repository from the Cloud Shell command line:
git clone https://github.com/GoogleCloudPlatform/training-data-analyst

# In Cloud Shell enter the following to create an environment variable named "BUCKET" 
# and verify that it exists with the echo command.
BUCKET="qwiklabs-gcp-04-43e38f5e169b"
echo $BUCKET

#In Cloud Shell navigate to the directory for this lab:
cd ~/training-data-analyst/courses/data_analysis/lab2/python

#Install the necessary dependencies for Python dataflow:
sudo ./install_packages.sh

#Verify that you have the right version of pip. (It should be > 8.0):
pip3 -V

#Navigate to the directory /training-data-analyst/courses/data_analysis/lab2/python 
#and view the file grep.py. Do not make any changes to the code.
cd ~/training-data-analyst/courses/data_analysis/lab2/python
nano grep.py

#In the Cloud Shell command line, locally execute grep.py.
cd ~/training-data-analyst/courses/data_analysis/lab2/python
python3 grep.py

#Locate the file by examining the file's time.
ls -al /tmp

#Examine the output file. Replace "-*" below with the appropriate suffix.
cat /tmp/output-00000-of-00001

#Copy some Java files to the cloud.
gsutil cp ../javahelp/src/main/java/com/google/cloud/training/dataanalyst/javahelp/*.java gs://$BUCKET/javahelp

#In the Cloud Shell code editor navigate to the directory /training-data-analyst/courses/data_analysis/lab2/python
#and edit the file grepc.py.
nano grepc.py

#Replace PROJECT and BUCKET with your Project ID and Bucket name. Here are easy ways to retrieve the values:
echo $DEVSHELL_PROJECT_ID
echo $BUCKET

#Submit the Dataflow job to the cloud:
python3 grepc.py

#Download the file in Cloud Shell and view it:
gsutil cp gs://$BUCKET/javahelp/output* .
cat output*