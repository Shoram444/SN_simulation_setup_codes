#!/bin/sh

# SLURM options:

#SBATCH --job-name=2ubb_testScript       # Job name
#SBATCH --partition=htc                  # Partition choice
#SBATCH --mem=8096M                      # RAM
#SBATCH --licenses=sps                   # When working on sps, must declare license!!


echo "WOKRING IN DIRECTORY: "
pwd
ls -l
echo "==========="

cp %CONF_FOLDER/Read_job7.cpp %MAIN_FOLDER/%USER_FOLDNAME/%i/Read_job7.cpp

%ROOT_FOLDER/root -l -q %MAIN_FOLDER/%USER_FOLDNAME/%i/Read_job7.cpp
