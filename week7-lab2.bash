# After going to the Compute Engine instance and beginning the SSH terminal verify that setup is complete.
ls /training

#Next you will download a code repository for use in this lab.
git clone https://github.com/GoogleCloudPlatform/training-data-analyst

# On the training-vm SSH terminal enter the following:
#This script sets the DEVSHELL_PROJECT_ID and BUCKET environment variables.
source /training/project_env.sh

#In the training-vm SSH terminal, start the sensor simulator. 
#The script reads sample data from a CSV file and publishes it to Pub/Sub.
/training/sensor_magic.sh

#Start another terminal of training-vm and enter the following:
source /training/project_env.sh

#Return to the second training-vm SSH terminal. Change into the directory for this lab.
cd ~/training-data-analyst/courses/streaming/process/sandiego

#Identify the script that creates and runs the Dataflow pipeline.
cat run_oncloud.sh

#Copy-and-paste the following URL into a new browser tab to view the source code on Github.
https://github.com/GoogleCloudPlatform/training-data-analyst/blob/master/courses/streaming/process/sandiego/run_oncloud.sh

#Go into the java directory. Identify the source file AverageSpeeds.java.
cd ~/training-data-analyst/courses/streaming/process/sandiego/src/main/java/com/google/cloud/training/dataanalyst/sandiego

cat AverageSpeeds.java

#Copy-and-paste the following URL into a browser tab to view the source code on Github.
https://github.com/GoogleCloudPlatform/training-data-analyst/blob/master/courses/streaming/process/sandiego/src/main/java/com/google/cloud/training/dataanalyst/sandiego/AverageSpeeds.java

#Return to the training-vm SSH terminal. Run the Dataflow pipeline to read from PubSub and write into BigQuery.
cd ~/training-data-analyst/courses/streaming/process/sandiego

./run_oncloud.sh $DEVSHELL_PROJECT_ID $BUCKET AverageSpeeds


#Return to the training-vm SSH terminal where the sensor data is script is running.
#Press CRTL+C to stop it. Then issue the command to start the script again.
cd ~/training-data-analyst/courses/streaming/publish

./send_sensor_data.py --speedFactor=60 --project $DEVSHELL_PROJECT_ID

#Open a third ssh terminal window and enter the following to create env variables:
source /training/project_env.sh

#Use the following commands to start a new sensor simulator.
cd ~/training-data-analyst/courses/streaming/publish

./send_sensor_data.py --speedFactor=60 --project $DEVSHELL_PROJECT_ID

#Examine the CurrentConditions.java application. Do not make any changes to the code.
cd ~/training-data-analyst/courses/streaming/process/sandiego/src/main/java/com/google/cloud/training/dataanalyst/sandiego

cat CurrentConditions.java

#Copy-and-paste the following URL into a browser tab to view the source code on Github.
https://github.com/GoogleCloudPlatform/training-data-analyst/blob/master/courses/streaming/process/sandiego/src/main/java/com/google/cloud/training/dataanalyst/sandiego/CurrentConditions.java

#Run the CurrentConditions.java code in a new Dataflow pipeline
cd ~/training-data-analyst/courses/streaming/process/sandiego

./run_oncloud.sh $DEVSHELL_PROJECT_ID $BUCKET CurrentConditions