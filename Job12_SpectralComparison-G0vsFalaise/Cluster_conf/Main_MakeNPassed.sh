#!/bin/bash
	
## ABSOLUTE LINKING:

	FAL=/pbs/home/m/mpetro/PROGRAMS/Falaise/install/bin
	JULIA=/pbs/home/m/mpetro/PROGRAMS/Julia/julia-1.7.2/bin
	MAIN_FOLDER=/sps/nemo/scratch/mpetro/Projects/PhD/Cluster/Data
	CONF_FOLDER=/pbs/home/m/mpetro/Projects/PhD/Codes/Job12_SpectralComparison-G0vsFalaise/Cluster_conf
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
		
	for (( i=1 ; i<$FILES ; i++ ))
	do
		if [ ! -f "NPassedhist2D.root" ] 
		then
		
			echo 	"Sending request for Run $i!"
			echo    "==========================="
			cd 		$MAIN_FOLDER/$USER_FOLDNAME/$i/	

			sed -e "s|%i|$i|g" \
			    -e "s|%USER_FOLDNAME|$USER_FOLDNAME|g" \
			    -e "s|%MAIN_FOLDER|$MAIN_FOLDER|g" \
			    -e "s|%ROOT_FOLDER|$ROOT_FOLDER|g" \
			    -e "s|%CONF_FOLDER|$CONF_FOLDER|g" \
				$CONF_FOLDER/MakeNPassed.sh > $MAIN_FOLDER/$USER_FOLDNAME/$i/MakeNPassed.sh 


			chmod 755 $MAIN_FOLDER/$USER_FOLDNAME/$i/MakeNPassed.sh

			# sbatch -o $MAIN_FOLDER/$USER_FOLDNAME/$i/Job7_OUT_${i}.log -e $MAIN_FOLDER/$USER_FOLDNAME/$i/Job7_ERR_${i}.log $MAIN_FOLDER/$USER_FOLDNAME/$i/MakeNPassed.sh  
			$MAIN_FOLDER/$USER_FOLDNAME/$i/MakeNPassed.sh
		fi
	done	
	
		
		
		
###
