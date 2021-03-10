#Streaming Data Processing

#Open the SSH terminal for the Compute Engine instance training-vm.
#Verify that setup is complete by checking the contents of the new directory.
ls /training

#Next you will download a code repository for use in this lab.
git clone https://github.com/GoogleCloudPlatform/training-data-analyst

#On the training-vm SSH terminal enter the following:
#This script sets the $DEVSHELL_PROJECT_ID and $BUCKET environment variables.
source /training/project_env.sh

#In the training-vm SSH terminal run the script to download and unzip the quickstart files 
#You will later use these to run the HBase shell.
cd ~/training-data-analyst/courses/streaming/process/sandiego
./install_quickstart.sh

#In the training-vm SSH terminal, start the sensor simulator. 
#The script reads sample data from a csv file and publishes it to Pub/Sub.
/training/sensor_magic.sh

#Open a second SSH terminal and connect to the training VM
#In the new training-vm SSH terminal enter the following:
source /training/project_env.sh

#In the second training-vm SSH terminal, navigate to the directory for this lab.
cd ~/training-data-analyst/courses/streaming/process/sandiego

nano run_oncloud.sh

#This script above will direct the pipeline to write into Cloud Bigtable
#Run the following script to create the Bigtable instance.
cd ~/training-data-analyst/courses/streaming/process/sandiego

./create_cbt.sh

#Run the Dataflow pipeline to read from PubSub and write into Cloud Bigtable.
cd ~/training-data-analyst/courses/streaming/process/sandiego

./run_oncloud.sh $DEVSHELL_PROJECT_ID $BUCKET CurrentConditions --bigtable

#In the second training-vm SSH terminal, run the quickstart.sh script to launch the HBase shell.
cd ~/training-data-analyst/courses/streaming/process/sandiego/quickstart

./quickstart.sh

#When the script completes, you will be in an HBase shell prompt that looks like this:
hbase(main):001:0>

#At the HBase shell prompt, type the following query to retrieve 2 rows from your Bigtable table that was populated by the pipeline.
scan 'current_conditions', {'LIMIT' => 2}

#Run another query. This time look only at the lane: speed column, limit to 10 rows, and specify rowid patterns for start and end rows to scan over.
scan 'current_conditions', {'LIMIT' => 10, STARTROW => '15#S#1', ENDROW => '15#S#999', COLUMN => 'lane:speed'}

#Once you're satisfied, quit to exit the shell.
quit

#Run the script to delete your Bigtable instance. If prompted, press Enter.
cd ~/training-data-analyst/courses/streaming/process/sandiego
./delete_cbt.sh

