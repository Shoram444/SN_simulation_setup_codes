#!/bin/bash
	
## ABSOLUTE LINKING:

	FAL=/pbs/home/m/mpetro/PROGRAMS/Falaise/install/bin
	JULIA=/pbs/home/m/mpetro/PROGRAMS/Julia/julia-1.7.2/bin
	MAIN_FOLDER=/sps/nemo/scratch/mpetro/Projects/PhD/Cluster/DataWithoutBField
	CONF_FOLDER=/pbs/home/m/mpetro/Projects/PhD/Codes/Job21_ML/Xi31_0.6
	RESOURCES=/pbs/home/m/mpetro/PROGRAMS/Falaise/install/share/Falaise-4.0.3/resources/genbb
	ROOT_FOLDER=/sps/nemo/sw/BxCppDev/opt/root-6.16.00/bin
	SENSITIVITY_MODULE=/sps/nemo/scratch/vpalusov/sw/my_falaise/SensitivityModule2/SensitivityModule/build/SensitivityModuleExample.conf

## SPECIFY KAPPAS!!

	KAPPA_SIGN=minus
	KAPPA_MIN=0.6583    # included
	KAPPA_MAX=0.6583    # exluded
	KAPPA_STEP=0.01
	KAPPA_N=1         # number of kappas to simulate over the specified range (if 1, only one spectrum will be simulated) 

	i=100  # CHANGE THIS WHEN ADDING TO ALREADY EXISTING SIMULATION!!
		   # Counter for unique ID this is needed since the input_profile_i MUST be unique!


## END LINKING
	
	echo "	"
	cd $MAIN_FOLDER
	ls	
	echo "	"

	echo "Choose the name of simulation folder:"
	read USER_FOLDNAME
	echo "					   "

	echo "Choose number of files per kappa:"
	read FILES
	echo "	"		
		
	cd $MAIN_FOLDER/$USER_FOLDNAME
	ls
	echo "	"

	if [ ! -d "$MAIN_FOLDER/$USER_FOLDNAME" ] 
	then
		mkdir -p $MAIN_FOLDER/$USER_FOLDNAME
	else
		echo "Warning: Simulation name already exists. Using previously used configuration files."
		echo "											 "
	fi
		
	echo 	"Sending request for Run $USER_FOLDNAME!"
	echo    "==========================="

	for (( k=0 ; k<$KAPPA_N ; k++  ))  # iterate over kappas
	do
		if [ ! -d "$MAIN_FOLDER/$USER_FOLDNAME/$k/" ] 
		then
			mkdir 	$MAIN_FOLDER/$USER_FOLDNAME/$k/	
		# k=0
			for (( f=0; f < $FILES; f++  )) # iterate over number of files per kappa
			do
				if [ ! -d "$MAIN_FOLDER/$USER_FOLDNAME/$k/$i/" ]  # create unique folder (must have unique i)
				then

					mkdir 	$MAIN_FOLDER/$USER_FOLDNAME/$k/$i/	
					cp $CONF_FOLDER/Job21.cpp $MAIN_FOLDER/$USER_FOLDNAME/$k/$i/
    				cp $CONF_FOLDER/Job22.cpp $MAIN_FOLDER/$USER_FOLDNAME/$k/$i/

					sed -e "s|%k|$k|g" \
						-e "s|%i|$i|g" \
						-e "s|%MAIN_FOLDER|$MAIN_FOLDER|g" \
						-e "s|%USER_FOLDNAME|$USER_FOLDNAME|g" \
						$CONF_FOLDER/simu.conf > $MAIN_FOLDER/$USER_FOLDNAME/$k/$i/simu.conf    # change path to variant_%k.profile in simu.conf and copy to working directory

					sed -e "s|%i|$i|g" \
						$CONF_FOLDER/variant.profile > $MAIN_FOLDER/$USER_FOLDNAME/$k/$i/variant_$i.profile # change event_input_%i in variant_%k.profile 

					sed -e "s|%k|$k|g" \
						-e "s|%i|$i|g" \
						-e "s|%USER_FOLDNAME|$USER_FOLDNAME|g" \
						-e "s|%MAIN_FOLDER|$MAIN_FOLDER|g" \
						$CONF_FOLDER/InputEvents.conf > $RESOURCES/InputEvents/InputEvents_$i.conf # change InputEvents into resources

					sed -e "s|%k|$k|g" \
						-e "s|%KAPPA_SIGN|$KAPPA_SIGN|g" \
						-e "s|%KAPPA_MIN|$KAPPA_MIN|g" \
						-e "s|%KAPPA_MAX|$KAPPA_MAX|g" \
						-e "s|%KAPPA_STEP|$KAPPA_STEP|g" \
						-e "s|%KAPPA_N|$KAPPA_N|g" \
						-e "s|%CONF_FOLDER|$CONF_FOLDER|g" \
						$CONF_FOLDER/genbbGenerator.jl > $MAIN_FOLDER/$USER_FOLDNAME/$k/$i/genbbGenerator.jl # change genbbGenerator.jl 

					sed -e "s|%k|$k|g" \
						-e "s|%i|$i|g" \
					    -e "s|%FAL|$FAL|g" \
					    -e "s|%JULIA|$JULIA|g" \
					    -e "s|%USER_FOLDNAME|$USER_FOLDNAME|g" \
					    -e "s|%CONF_FOLDER|$CONF_FOLDER|g" \
					    -e "s|%MAIN_FOLDER|$MAIN_FOLDER|g" \
					    -e "s|%RESOURCES|$RESOURCES|g" \
					    -e "s|%ROOT_FOLDER|$ROOT_FOLDER|g" \
			    		-e "s|%SENSITIVITY_MODULE|$SENSITIVITY_MODULE|g" \
						$CONF_FOLDER/run_script.sh > $MAIN_FOLDER/$USER_FOLDNAME/$k/$i/run_script.sh 



					chmod 755 $MAIN_FOLDER/$USER_FOLDNAME/$k/$i/run_script.sh

					sbatch -o $MAIN_FOLDER/$USER_FOLDNAME/$k/$i/OUT_${k}.log -e $MAIN_FOLDER/$USER_FOLDNAME/$k/$i/ERR_${k}.log $MAIN_FOLDER/$USER_FOLDNAME/$k/$i/run_script.sh  
					$i=$(( i++ ))
					
				fi
			done
		fi
	done
		
###
