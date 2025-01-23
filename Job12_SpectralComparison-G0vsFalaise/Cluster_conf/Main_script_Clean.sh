#!/bin/bash

#This is the main script to run the a job on the CC-LYON cluster. In order to run this script use:
# 1. chmod 755 Main_script_Clean.sh   # this is necessary only once to make the script executable
# 2. ./Main_script_Clean.sh

# In the first part of this script, the relevant paths are specified (eg. to where Falaise is installed)
# The second part of the script takes the sample "run_script.sh" file and with the help of linux's sed command
# changes the relevant variables within "run_script.sh". Afterwards run_script.sh with the changed paths is copied
# into the directory where the cluster will work (USER_FOLDNAME). 
# This file must be made executable with chmod 755 command. 
# To run the eun_script.sh, the command sbatch (or srun, if in interactive mode) is run. The output and error logs are specified with -o, -e respectively.
	
## ABSOLUTE LINKING:

	USER_FOLDNAME=EXAMPLE_JOB # The name of the folder where we will work in. 

	FAL=/pbs/home/m/mpetro/PROGRAMS/Falaise/install/bin   # Here we find flsimulate, flreconstruct, flvisualise
	MAIN_FOLDER=/sps/nemo/scratch/mpetro/Projects/PhD/Cluster/Data # The main directory where Data is saved. (This is one above USER_FOLDNAME)
	CONF_FOLDER=/pbs/home/m/mpetro/Projects/PhD/Codes/Job12_SpectralComparison-G0vsFalaise/Cluster_conf # In this folder we have: Main_script_Clean.sh, run_script.sh, simu.conf, variant.profile, etc.
	ROOT_FOLDER=/sps/nemo/sw/BxCppDev/opt/root-6.16.00/bin # Installation of ROOT. 

## END LINKING

	sed -e "s|%FAL|$FAL|g" \                        # sed command opens the run_script.sh file and changes variables where indicated by %. 
	    -e "s|%USER_FOLDNAME|$USER_FOLDNAME|g" \    # (eg. %FAL in run_script.sh is changed by the value of FAL in this file -> path to falaise)
	    -e "s|%CONF_FOLDER|$CONF_FOLDER|g" \
	    -e "s|%MAIN_FOLDER|$MAIN_FOLDER|g" \
	    -e "s|%ROOT_FOLDER|$ROOT_FOLDER|g" \
		$CONF_FOLDER/run_script.sh > $MAIN_FOLDER/$USER_FOLDNAME/run_script.sh # this line copies the changed run_script.sh from CONF_FOLDER to the USER_FOLDNAME

	cd $MAIN_FOLDER/$USER_FOLDNAME/

	chmod 755 $MAIN_FOLDER/$USER_FOLDNAME/run_script.sh

	sbatch -o $MAIN_FOLDER/$USER_FOLDNAME/OUT.log -e $MAIN_FOLDER/$USER_FOLDNAME/ERR.log $MAIN_FOLDER/$USER_FOLDNAME/run_script.sh  
		
###
