#!/bin/bash
	
## ABSOLUTE LINKING:

echo "Number of events to simulate?: "
read NSIM


FAL=/sps/nemo/sw/redhat-9-x86_64/snsw/opt/falaise-5.1.2/bin
DATA_FOLDER=/sps/nemo/scratch/mpetro/Projects/PhD/Cluster_sim_data
MAIN_FOLDER=/pbs/home/m/mpetro/Projects/PhD/Codes/Job33_escape_efficiencies
ROOT_FOLDER=/sps/nemo/sw/redhat-9-x86_64/snsw/opt/root-6.26.06/bin

SOURCE_ISO=("Nd150") #("Se82")
ENERGIES=("200" "300" "400" "500" "750" "1000" "1500" "2500" "3000" "3500")
# ENERGIES=( "200" "300") # "400" "500" "750" "1000" "1500" "2500" "3000" "3500")
THICKNESSES=("150" "250" "300" "400" "500") #("150" "200" "250" "300" "400" "500")

T_DIR=""
E_DIR=""
WORK_DIR=""
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


for t in "${THICKNESSES[@]}";
do
	echo "creating variable T_DIR" 
	T_DIR=$DATA_FOLDER/$USER_FOLDNAME/${t}_um
	echo $T_DIR
	for E in "${ENERGIES[@]}";
	do
		E_DIR=$T_DIR/${E}_keV
		echo $E_DIR
		for (( f=0; f < $FILES; f++  )) # iterate over number of files 
		do
			WORK_DIR=$E_DIR/$f
			if [ ! -d $WORK_DIR ]  # create unique folder 
			then
				mkdir -p $WORK_DIR	
				cp $MAIN_FOLDER/Job33.cpp $WORK_DIR/Job33.cpp
				cp $MAIN_FOLDER/Job33_eff.cpp $WORK_DIR/Job33_eff.cpp

				sed -e "s|%ENERGY|$E|" \
					-e "s|%THICKNESS|$t|g" \
					-e "s|%SOURCE_ISO|$SOURCE_ISO|g" \
					$MAIN_FOLDER/falaise_conf/variant.profile > $WORK_DIR/E_${E}_f_${t}.profile

				sed -e "s|%NSIM|$NSIM|" \
					-e "s|%WORK_DIR|$WORK_DIR|g" \
					-e "s|%ENERGY|$E|g" \
					-e "s|%THICKNESS|$t|g" \
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
					$MAIN_FOLDER/run_script_2.sh > $WORK_DIR/run_script_2.sh 
				chmod 755 $WORK_DIR/run_script_2.sh 

			fi
		done
		ARRAY_RANGE=$((FILES - 1))
		echo "Submitting array job: 0-$ARRAY_RANGE"
		echo "Variables: WORK_DIR=$WORK_DIR"


		sbatch \
			--array=0-$ARRAY_RANGE \
			--export=ALL,E_DIR=$E_DIR,FAL=$FAL,DATA_FOLDER=$DATA_FOLDER,MAIN_FOLDER=$MAIN_FOLDER,ROOT_FOLDER=$ROOT_FOLDER,USER_FOLDNAME=$USER_FOLDNAME \
			-o $E_DIR/%a/out_%A_%a.log -e $E_DIR/%a/err_%A_%a.log\
			$MAIN_FOLDER/run_script_2.sh  
	done
done
###
