#!/bin/sh

# SLURM options:

#SBATCH --job-name=Tl208              	 # Job name
#SBATCH --partition=htc                  # Partition choice (most generally we work with htc, but for quick debugging you can use
										 #					 #SBATCH --partition=flash. This avoids waiting times, but is limited to 1hr)
#SBATCH --mem=8G                     # RAM
#SBATCH --licenses=sps                   # When working on sps, must declare license!!

#SBATCH --time=4-0                 	 # Time for the job in format “minutes:seconds” or  “hours:minutes:seconds”, “days-hours”
#SBATCH --cpus-per-task=1                # Number of CPUs

echo "================================="
echo "run_script started:"
start=`date +%s`

cp %MAIN_FOLDER/%USER_FOLDNAME/%f/* .

pwd
ls

echo "================================="

echo "STARTING flsimulate:"
%FAL/flsimulate -c %MAIN_FOLDER/%USER_FOLDNAME/%f/Tl208.conf -o SD.brio 


echo "ls after flsimulate."
ls
echo "FINISHED flsimulate."


echo "STARTING flreconstruct 1:"
%FAL/flreconstruct -i SD.brio -p %CONF_FOLDER/rec.conf -o CD.brio


echo "ls after flreconstruct 1."
ls
echo "FINISHED flreconstruct 1."

ls -l

echo "STARTED flreconstruct 2:"
%FAL/flreconstruct -p %CONF_FOLDER/p_MiModule_v00.conf -i CD.brio 
echo "FINISHED flreconstruct 2!"

cp $TMPDIR/CD.brio %MAIN_FOLDER/%USER_FOLDNAME/%f/CD.brio              # if you want to keep CD.brio
cp $TMPDIR/Default.root %MAIN_FOLDER/%USER_FOLDNAME/%f/Default.root              # if you want to keep Default.root


end=`date +%s`

runtime=$((end-start))
echo " RUNTIME IS :"
echo $runtime
