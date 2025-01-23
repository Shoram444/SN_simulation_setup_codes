#!/bin/bash
	
## ABSOLUTE LINKING:

	echo "Choose the isotope: "
	echo "Se82.0nubb, Se82.2nubb, Bi214, K40, Tl208, Pa234m, ..."
	read ISO

	echo "Choose the vertex generator: "
	echo "source_pads_bulk, real_flat_source_full_foils_se82_bulk, pmt_glass_bulk, anode_wire_surface, anode_wire_bulk, source_pads_external_surface, ..."
	echo "real_flat_source_full_foils_surface, real_flat_source_full_foils_mass_bulk"
	echo "experimental_hall_surface"
	read SOURCE

	echo "Number of events to simulate?: "
	read NSIM
	

	FAL=/sps/nemo/sw/redhat-9-x86_64/snsw/opt/falaise-5.1.2/bin
	JULIA=/pbs/home/m/mpetro/PROGRAMS/Julia/julia-1.7.2/bin
	DATA_FOLDER=/sps/nemo/scratch/mpetro/Projects/PhD/Cluster_sim_data
	ISO_FOLDER=/pbs/home/m/mpetro/Projects/PhD/Codes/Job23_2nu_sensitivity/${ISO}
	MAIN_FOLDER=/pbs/home/m/mpetro/Projects/PhD/Codes/Job23_2nu_sensitivity/main
	ROOT_FOLDER=/sps/nemo/sw/BxCppDev/opt/root-6.16.00/bin

## END LINKING
	
	echo "	"
	cd $DATA_FOLDER
	ls	
	echo "	"

	echo "Choose the name of simulation folder:"
	read USER_FOLDNAME
	echo "					   "

	echo "Choose number of files:"
	read FILES
	echo "	"		
		

	if [ ! -d "$DATA_FOLDER/$USER_FOLDNAME" ] 
	then
		mkdir -p $DATA_FOLDER/$USER_FOLDNAME
	else
		echo "Warning: Simulation name already exists. Using previously used configuration files."
		echo "											 "
	fi

	cd $DATA_FOLDER/$USER_FOLDNAME
	ls
	echo "	"
		
	echo 	"Sending request for Run $USER_FOLDNAME!"
	echo    "==========================="

	for (( f=0; f < $FILES; f++  )) # iterate over number of files 
	do
		if [ ! -d "$DATA_FOLDER/$USER_FOLDNAME/$f/" ]  # create unique folder 
		then

			mkdir 	$DATA_FOLDER/$USER_FOLDNAME/$f/	

    		cp $MAIN_FOLDER/Job23.cpp $DATA_FOLDER/$USER_FOLDNAME/$f/

			# For B field on
			# sed -e "s|%SOURCE|$SOURCE|" \
			# 	-e "s|%ISO|$ISO|" \
			# 	$MAIN_FOLDER/variant.profile > $DATA_FOLDER/$USER_FOLDNAME/$f/${ISO}_on_${SOURCE}.profile

			# For B field off
			sed -e "s|%SOURCE|$SOURCE|" \
				-e "s|%ISO|$ISO|" \
				$MAIN_FOLDER/Boff_variant.profile > $DATA_FOLDER/$USER_FOLDNAME/$f/${ISO}_on_${SOURCE}.profile

			sed -e "s|%SOURCE|$SOURCE|" \
				-e "s|%ISO|$ISO|" \
				-e "s|%NSIM|$NSIM|" \
				-e "s|%USER_FOLDNAME|$USER_FOLDNAME|g" \
			    -e "s|%MAIN_FOLDER|$MAIN_FOLDER|g" \
			    -e "s|%DATA_FOLDER|$DATA_FOLDER|g" \
				-e "s|%f|$f|g" \
				$MAIN_FOLDER/simu.conf > $DATA_FOLDER/$USER_FOLDNAME/$f/${ISO}.conf

			sed -e "s|%f|$f|g" \
			    -e "s|%FAL|$FAL|g" \
			    -e "s|%ISO|$ISO|g" \
			    -e "s|%SOURCE|$SOURCE|g" \
			    -e "s|%USER_FOLDNAME|$USER_FOLDNAME|g" \
			    -e "s|%MAIN_FOLDER|$MAIN_FOLDER|g" \
			    -e "s|%DATA_FOLDER|$DATA_FOLDER|g" \
			    -e "s|%RESOURCES|$RESOURCES|g" \
			    -e "s|%ROOT_FOLDER|$ROOT_FOLDER|g" \
			    -e "s|%SENSITIVITY_MODULE|$SENSITIVITY_MODULE|g" \
				$MAIN_FOLDER/run_script.sh > $DATA_FOLDER/$USER_FOLDNAME/$f/run_script.sh 

			chmod 755 $DATA_FOLDER/$USER_FOLDNAME/$f/run_script.sh

			# sbatch $DATA_FOLDER/$USER_FOLDNAME/$f/run_script.sh  
			sbatch -o $DATA_FOLDER/$USER_FOLDNAME/$f/OUT_${f}.log -e $DATA_FOLDER/$USER_FOLDNAME/$f/ERR_${f}.log $DATA_FOLDER/$USER_FOLDNAME/$f/run_script.sh  

		fi
	done
		
###
