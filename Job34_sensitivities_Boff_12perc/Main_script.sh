#!/bin/bash
	
## ABSOLUTE LINKING:

FAL=/sps/nemo/sw/redhat-9-x86_64/snsw/opt/falaise-5.1.3/bin
DATA_FOLDER=/sps/nemo/scratch/mpetro/Projects/PhD/Cluster_sim_data
MAIN_FOLDER=/pbs/home/m/mpetro/Projects/PhD/Codes/Job34_sensitivities_Boff_12perc
ROOT_FOLDER=/sps/nemo/sw/redhat-9-x86_64/snsw/opt/root-6.26.06/bin

SIM_DIR=""
## PROMPTS
	echo "Choose the isotope: "
	echo "Se82.0nubb , Se82.2nubb , Bi214 , K40 , Tl208 , Pa234m , ..."
	read ISO

	echo "Choose the vertex generator: "
	echo "source_pads_bulk , real_flat_source_full_foils_se82_bulk , pmt_glass_bulk , anode_wire_surface , anode_wire_bulk , source_pads_external_surface , ..."
	echo "real_flat_source_full_foils_surface , real_flat_source_full_foils_mass_bulk"
	echo "experimental_hall_surface"
	read SOURCE

	echo "Number of events to simulate?: "
	read NSIM


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
		WORK_DIR=$DATA_FOLDER/$USER_FOLDNAME/$f/	
		mkdir 	$WORK_DIR

		cp $MAIN_FOLDER/Job23.cpp $WORK_DIR/Job23.cpp

		sed -e "s|%ISO|$ISO|" \
			-e "s|%SOURCE|$SOURCE|g" \
			$MAIN_FOLDER/falaise_conf/variant.profile > $WORK_DIR/${ISO}_on_${SOURCE}.profile

		sed -e "s|%NSIM|$NSIM|" \
			-e "s|%WORK_DIR|$WORK_DIR|g" \
			-e "s|%ISO|$ISO|" \
			-e "s|%SOURCE|$SOURCE|g" \
			$MAIN_FOLDER/falaise_conf/simu.conf > $WORK_DIR/simu.conf

		sed -e "s|%f|$f|g" \
			-e "s|%FAL|$FAL|g" \
			-e "s|%ISO|$ISO|g" \
			-e "s|%SOURCE|$SOURCE|g" \
			-e "s|%USER_FOLDNAME|$USER_FOLDNAME|g" \
			-e "s|%MAIN_FOLDER|$MAIN_FOLDER|g" \
			-e "s|%DATA_FOLDER|$DATA_FOLDER|g" \
			-e "s|%RESOURCES|$RESOURCES|g" \
			-e "s|%ROOT_FOLDER|$ROOT_FOLDER|g" \
			$MAIN_FOLDER/run_script.sh > $WORK_DIR/run_script.sh 
		chmod 755 $WORK_DIR/run_script.sh 

	fi
done

ARRAY_RANGE=$((FILES - 1))
echo "Submitting array job: 0-$ARRAY_RANGE"
echo "Variables: WORK_DIR=$WORK_DIR"

SIM_DIR=$DATA_FOLDER/$USER_FOLDNAME

sbatch \
	--array=0-$ARRAY_RANGE \
	--export=ALL,SIM_DIR=$SIM_DIR,FAL=$FAL,DATA_FOLDER=$DATA_FOLDER,MAIN_FOLDER=$MAIN_FOLDER,ROOT_FOLDER=$ROOT_FOLDER,USER_FOLDNAME=$USER_FOLDNAME \
	-o $SIM_DIR/%a/out_%A_%a.log -e $SIM_DIR/%a/err_%A_%a.log\
	$MAIN_FOLDER/run_script.sh  
###
