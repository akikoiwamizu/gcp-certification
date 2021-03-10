# The training-vm is installing some software in the background. 
# Verify that setup is complete by checking the contents of the new directory.
ls /training

# Next you will download a code repository for use in this lab.
git clone https://github.com/GoogleCloudPlatform/training-data-analyst

# On the training-vm SSH terminal, set the DEVSHELL_PROJECT_ID environment variable 
# and export it so it will be available to other shells.
export DEVSHELL_PROJECT_ID=$(gcloud config get-value project)

# On the training-vm SSH terminal, navigate to the directory for this lab.
cd ~/training-data-analyst/courses/streaming/publish

# Create your topic and publish a simple message.
gcloud pubsub topics create sandiego

# Publish a simple message.
gcloud pubsub topics publish sandiego --message "hello"

# Create a subscription for the topic.
gcloud pubsub subscriptions create --topic sandiego mySub1

# Pull the first message that was published to your topic.
gcloud pubsub subscriptions pull --auto-ack mySub1

# Try to publish another message and then pull it using the subscription.
gcloud pubsub topics publish sandiego --message "hello again"
gcloud pubsub subscriptions pull --auto-ack mySub1

# In the training-vm SSH terminal, cancel your subscription.
gcloud pubsub subscriptions delete mySub1

#Explore the python script to simulate San Diego traffic sensor data. Do not make any changes to the code.
#Look at the simulate function. This one lets the script behave as if traffic sensors were sending in data in real time to Pub/Sub. 
#The speedFactor parameter determines how fast the simulation will go.
cd ~/training-data-analyst/courses/streaming/publish
nano send_sensor_data.py

#Download the traffic simulation dataset.
./download_data.sh

#Run the send_sensor_data.py.
#This command simulates sensor data by sending recorded sensor data via Pub/Sub messages. 
#The script extracts the original time of the sensor data and pauses between sending each message 
#to simulate realistic timing of the sensor data. The value speedFactor changes the time between messages proportionally. 
#So a speedFactor of 60 means "60 times faster" than the recorded timing. 
#It will send about an hour of data every 60 seconds.
./send_sensor_data.py --speedFactor=60 --project $DEVSHELL_PROJECT_ID


#Open a second SSH terminal of the Compute Engine instance: training-vm
#Change into the directory you were working in.
cd ~/training-data-analyst/courses/streaming/publish

#Create a subscription for the topic and do a pull to confirm that messages are coming in 
#Note: you may need to issue the 'pull' command more than once to start seeing messages:
gcloud pubsub subscriptions create --topic sandiego mySub2
gcloud pubsub subscriptions pull --auto-ack mySub2

#Cancel this subscription.
gcloud pubsub subscriptions delete mySub2

#Close the second terminal.
exit

#Return to the first terminal and interrupt the publisher by typical CTRL+C to stop it. Then exit.
exit