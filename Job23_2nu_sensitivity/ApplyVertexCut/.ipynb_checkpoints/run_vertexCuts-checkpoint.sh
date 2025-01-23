#!/bin/sh

# SLURM options:

#SBATCH --job-name=vCut              	 # Job name
#SBATCH --partition=htc                  # Partition choice (most generally we work with htc, but for quick debugging you can use
										 #					 #SBATCH --partition=flash. This avoids waiting times, but is limited to 1hr)
#SBATCH --mem=8G                     	 # RAM
#SBATCH --licenses=sps                   # When working on sps, must declare license!!

#SBATCH --time=0-1                	 	 # Time for the job in format “minutes:seconds” or  “hours:minutes:seconds”, “days-hours”
#SBATCH --cpus-per-task=1                # Number of CPUs

echo "================================="
echo "run_script started:"
start=`date +%s`

cd %subfolder
echo "pwd: "
pwd
ls

if [ -e "CDcut.brio" ]; then
    mv CDcut.brio CDCut.brio
fi
if [ -e "EnePhiDist_Job23.root" ]; then
	mv EnePhiDist_Job23.root EnePhiDist_Job23_SDBDRC.root
fi
if [ -e "EnePhiDist_Job23_SDBDRC_vertexCut_100mm.root" ]; then
	rm EnePhiDist_Job23_SDBDRC_vertexCut_100mm.root 
fi
if [ -e "CDCut_vertex.brio" ]; then
	rm CDCut_vertex.brio 
fi



%FAL/flreconstruct -i CDCut.brio -p SNCutsPipeline_vertexCut.conf -o CDCut_vertex.brio
%FAL/flreconstruct -p %CONF_FOLDER/p_MiModule_v00.conf -i CDCut_vertex.brio 

ls -l

echo "FINISHED simulation, STARTING analysis!"

%ROOT_FOLDER/root -l -b Job23.cpp
mv EnePhiDist_Job23.root EnePhiDist_Job23_SDBDRC_vertexCut_100mm.root


end=`date +%s`

runtime=$((end-start))
echo " RUNTIME IS :"
echo $runtime
