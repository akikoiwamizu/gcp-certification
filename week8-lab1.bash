#Streaming Data Processing

#Open the SSH terminal for the Compute Engine instance training-vm.
#Verify that setup is complete by checking the contents of the new directory.
ls /training

#Next you will download a code repository for use in this lab.
git clone https://github.com/GoogleCloudPlatform/training-data-analyst

#On the training-vm SSH terminal enter the following:
#This script sets the $DEVSHELL_PROJECT_ID and $BUCKET environment variables.
source /training/project_env.sh
