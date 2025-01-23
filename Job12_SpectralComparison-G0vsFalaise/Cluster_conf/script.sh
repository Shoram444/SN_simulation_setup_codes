#!/bin/sh

# SLURM options:

#SBATCH --job-name=2ubb_testScript       # Job name
#SBATCH --partition=htc                  # Partition choice
#SBATCH --mem=8096M                      # RAM
#SBATCH --licenses=sps                   # When working on sps, must declare license!!

j=%i
GENBBFOLDER=%MAIN_FOLDER/%USER_FOLDNAME/%i   # this variable is probably reduntant, but it helps point to the genbb file (it's the main data folder path)
 
echo "STARTED generating .genbb files:"
%JULIA/julia %MAIN_FOLDER/%USER_FOLDNAME/%i/genbbGenerator.jl
echo "FINISHED generating .genbb files:"
echo "================================="
echo "CURRENT WORKING DIRECTORY:"
pwd
ls
echo "================================="


sed -e "s|%GENBBFOLDER|$GENBBFOLDER|g" \
	-e "s|%j|$j|g" \
	%CONF_FOLDER/InputEvents.conf > %RESOURCES/InputEvents/InputEvents_$j.conf # change path of genbb file in InputEvents.conf to the path of .genbb file


echo "PATHS changed:"

echo "STARTED flsimulate:"

date
%FAL/flsimulate -c %MAIN_FOLDER/%USER_FOLDNAME/%i/simu.conf -o %MAIN_FOLDER/%USER_FOLDNAME/%i/SD.brio 
date
echo "FINISHED flsimulate:"


echo "STARTED flreconstruct 1:"
%FAL/flreconstruct -i %MAIN_FOLDER/%USER_FOLDNAME/%i/SD.brio -p %CONF_FOLDER/rec.conf -o %MAIN_FOLDER/%USER_FOLDNAME/%i/CD.brio
echo "FINISHED flreconstruct:"


echo "STARTED flreconstruct 2:"
%FAL/flreconstruct -p %CONF_FOLDER/p_MiModule_v00.conf -i %MAIN_FOLDER/%USER_FOLDNAME/%i/CD.brio 

echo "FINISHED flreconstruct 2!"

cp %CONF_FOLDER/Read_job11.cpp %MAIN_FOLDER/%USER_FOLDNAME/%i/Read_job11.cpp

%ROOT_FOLDER/root -l %MAIN_FOLDER/%USER_FOLDNAME/%i/Read_job11.cpp