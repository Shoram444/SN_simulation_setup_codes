#!/bin/sh

# SLURM options:

#SBATCH --job-name=pCut              	 # Job name
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

if [ -e "Default.root" ]; then
	rm Default.root
fi
if [ -e "EnePhiDist_Job23_SDBDRC_probabilityCut_100mm_prob.root" ]; then
	rm EnePhiDist_Job23_SDBDRC_probabilityCut_100mm_prob.root
fi
if [ -e "CDCut_vertex_probability.brio" ]; then
	rm CDCut_vertex_probability.brio
fi

%FAL/flreconstruct -i CDCut_vertex.brio -p SNCutsPipeline_probabilityCut.conf -o CDCut_vertex_probability.brio
%FAL/flreconstruct -p %CONF_FOLDER/p_MiModule_v00.conf -i CDCut_vertex_probability.brio 

ls -l

echo "FINISHED simulation, STARTING analysis!"

%ROOT_FOLDER/root -l -b Job23.cpp
mv EnePhiDist_Job23.root EnePhiDist_Job23_SDBDRC_probabilityCut_100mm_prob.root


end=`date +%s`

runtime=$((end-start))
echo " RUNTIME IS :"
echo $runtime
