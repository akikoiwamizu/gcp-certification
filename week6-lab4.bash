#Create a GCS bucket & clone github repo to Cloud Shell
git clone https://github.com/GoogleCloudPlatform/training-data-analyst

#Upgrade packages and install Apache Beam
cd training-data-analyst/courses/data_analysis/lab2/python
sudo ./install_packages.sh


#View the file with nano. Do not make any changes to the code.
cd ~/training-data-analyst/courses/data_analysis/lab2/python
nano is_popular.py

#Run the pipeline locally:
cd ~/training-data-analyst/courses/data_analysis/lab2/python
python3 ./is_popular.py

#Identify the output file. It should be output<suffix> and could be a sharded file.
ls -al /tmp

#Examine the output file, replacing '-*' with the appropriate suffix.
cat /tmp/output-00000-of-00001

#Change the output prefix from the default value:
python3 ./is_popular.py --output_prefix=/tmp/myoutput

#Note that we now have a new file in the /tmp directory:
ls -lrt /tmp/myoutput*