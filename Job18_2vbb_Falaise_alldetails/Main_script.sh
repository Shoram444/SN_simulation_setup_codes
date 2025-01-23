#!/bin/bash
	
## ABSOLUTE LINKING:

	FAL=/pbs/home/m/mpetro/PROGRAMS/Falaise/install/bin
	JULIA=/pbs/home/m/mpetro/PROGRAMS/Julia/julia-1.7.2/bin
	MAIN_FOLDER=/sps/nemo/scratch/mpetro/Projects/PhD/Cluster/Data
	CONF_FOLDER=/pbs/home/m/mpetro/Projects/PhD/Codes/Job18_2vbb_Falaise_alldetails
	RESOURCES=/pbs/home/m/mpetro/PROGRAMS/Falaise/install/share/Falaise-4.0.3/resources/genbb
	ROOT_FOLDER=/sps/nemo/sw/BxCppDev/opt/root-6.16.00/bin



## END LINKING
	
	echo "	"
	cd $MAIN_FOLDER
	ls
	echo "	"

	echo "Choose the name of simulation folder:"
	read USER_FOLDNAME
	echo "					   "

	if [ ! -d "$MAIN_FOLDER/$USER_FOLDNAME" ] 
	then
		mkdir -p $MAIN_FOLDER/$USER_FOLDNAME
	else
		echo "Warning: Simulation name already exists. Using previously used configuration files."
		echo "											 "
	fi
		
	cd $MAIN_FOLDER/$USER_FOLDNAME
	ls
	echo "	"

	echo "Choose number of jobs (files):"
	read FILES
	echo "				    "
		
	for (( i=0 ; i<$FILES ; i++ ))
	do
		if [ ! -d "$MAIN_FOLDER/$USER_FOLDNAME/$i/" ] 
		then
			mkdir 	$MAIN_FOLDER/$USER_FOLDNAME/$i/	

    		echo 	"Sending request for Run $i!"
    		echo    "==========================="

    		cp $CONF_FOLDER/Job16.cpp $MAIN_FOLDER/$USER_FOLDNAME/$i/
    		cp $CONF_FOLDER/variant.profile $MAIN_FOLDER/$USER_FOLDNAME/$i/

    		sed -e "s|%i|$i|g" \
    			-e "s|%MAIN_FOLDER|$MAIN_FOLDER|g" \
    			-e "s|%USER_FOLDNAME|$USER_FOLDNAME|g" \
				$CONF_FOLDER/simu.conf > $MAIN_FOLDER/$USER_FOLDNAME/$i/simu.conf    # change path to variant_%i.profile in simu.conf and copy to working directory


    		sed -e "s|%i|$i|g" \
			    -e "s|%FAL|$FAL|g" \
			    -e "s|%JULIA|$JULIA|g" \
			    -e "s|%USER_FOLDNAME|$USER_FOLDNAME|g" \
			    -e "s|%CONF_FOLDER|$CONF_FOLDER|g" \
			    -e "s|%MAIN_FOLDER|$MAIN_FOLDER|g" \
			    -e "s|%RESOURCES|$RESOURCES|g" \
			    -e "s|%ROOT_FOLDER|$ROOT_FOLDER|g" \
				$CONF_FOLDER/run_script.sh > $MAIN_FOLDER/$USER_FOLDNAME/$i/run_script.sh 

			chmod 755 $MAIN_FOLDER/$USER_FOLDNAME/$i/run_script.sh

    		sbatch -o $MAIN_FOLDER/$USER_FOLDNAME/$i/OUT_${i}.log -e $MAIN_FOLDER/$USER_FOLDNAME/$i/ERR_${i}.log $MAIN_FOLDER/$USER_FOLDNAME/$i/run_script.sh  
		fi
	done
	
		
		
		
###
