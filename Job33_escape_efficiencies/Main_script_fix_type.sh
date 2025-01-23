#!/bin/bash
	
## ABSOLUTE LINKING:

FAL=/sps/nemo/sw/redhat-9-x86_64/snsw/opt/falaise-5.1.2/bin
DATA_FOLDER=/sps/nemo/scratch/mpetro/Projects/PhD/Cluster_sim_data
MAIN_FOLDER=/pbs/home/m/mpetro/Projects/PhD/Codes/Job33_escape_efficiencies
ROOT_FOLDER=/sps/nemo/sw/redhat-9-x86_64/snsw/opt/root-6.26.06/bin

ENERGIES=("1500" "2500" "3000")
THICKNESSES=("250" ) #"300" "400" "500" "1000")

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

			cp $MAIN_FOLDER/Job33_eff.cpp $WORK_DIR/Job33_eff.cpp
			echo "WORK_DIR = $WORK_DIR"
		done
		ARRAY_RANGE=$((FILES - 1))

		sbatch \
			--array=0-$ARRAY_RANGE \
			--export=ALL,E_DIR=$E_DIR,FAL=$FAL,DATA_FOLDER=$DATA_FOLDER,MAIN_FOLDER=$MAIN_FOLDER,ROOT_FOLDER=$ROOT_FOLDER,USER_FOLDNAME=$USER_FOLDNAME \
			-o $E_DIR/%a/out_%A_%a.log -e $E_DIR/%a/err_%A_%a.log\
			$MAIN_FOLDER/run_script_3.sh  
	done
done
###

