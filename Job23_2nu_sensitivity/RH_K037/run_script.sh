#!/bin/sh

# SLURM options:

#SBATCH --job-name=RH037              	 # Job name
#SBATCH --partition=htc                  # Partition choice (most generally we work with htc, but for quick debugging you can use
										 #					 #SBATCH --partition=flash. This avoids waiting times, but is limited to 1hr)
#SBATCH --mem=16G	                     # RAM
#SBATCH --licenses=sps                   # When working on sps, must declare license!!

#SBATCH --chdir=$TMPDIR
#SBATCH --time=4-0                 	 	# Time for the job in format “minutes:seconds” or  “hours:minutes:seconds”, “days-hours”
#SBATCH --cpus-per-task=1                # Number of CPUs

echo "================================="
echo "run_script started:"
start=`date +%s`

cp %MAIN_FOLDER/%USER_FOLDNAME/%k/%i/* .

echo "STARTED generating .genbb files:"
%JULIA/julia genbbGenerator.jl
echo "FINISHED generating .genbb files:"
echo "================================="
cp input_module.genbb %MAIN_FOLDER/%USER_FOLDNAME/%k/%i/

pwd
ls

echo "================================="

echo "STARTING flsimulate:"
%FAL/flsimulate -c %MAIN_FOLDER/%USER_FOLDNAME/%k/%i/simu.conf -o SD.brio 
echo "ls after flsimulate."
ls
echo "FINISHED flsimulate."


echo "STARTING flreconstruct 1:"
%FAL/flreconstruct -i SD.brio -p %CONF_FOLDER/rec.conf -o CDCut.brio
%FAL/flreconstruct -i CDCut.brio -p %CONF_FOLDER/SNCutsPipeline.conf -o CDCut.brio


echo "ls after flreconstruct 1."
ls
echo "FINISHED flreconstruct 1."

ls -l

echo "STARTED flreconstruct 2:"
%FAL/flreconstruct -p %CONF_FOLDER/p_MiModule_v00.conf -i CDCut.brio 
echo "FINISHED flreconstruct 2!"

cp CDCut.brio %MAIN_FOLDER/%USER_FOLDNAME/%k/%i/CDCut.brio              # if you want to keep CD.brio

ls -l

echo "FINISHED simulation, STARTING analysis!"

pwd
ls -la
echo "==================="


echo "STARTED Job23.cpp:"

cp %CONF_FOLDER/Job23.cpp Job23.cpp

%ROOT_FOLDER/root -l -b Job23.cpp
echo "ls after Job23.cpp."
ls
echo "FINISHED Job23.cpp."

cp EnePhiDist_Job23.root %MAIN_FOLDER/%USER_FOLDNAME/%k/%i/EnePhiDist_Job23_SDBDRC.root

rm EnePhiDist_Job23.root
rm Default.root

echo "STARTING Vertex cut!"
echo "==================="
%FAL/flreconstruct -i CDCut.brio -p %CONF_FOLDER/SNCutsPipeline_vertexCut.conf -o CDCut_vertex.brio
%FAL/flreconstruct -i CDCut_vertex.brio -p %CONF_FOLDER/p_MiModule_v00.conf 
%ROOT_FOLDER/root -l -b Job23.cpp

cp CDCut_vertex.brio %MAIN_FOLDER/%USER_FOLDNAME/%k/%i/CDCut_vertex.brio
cp EnePhiDist_Job23.root %MAIN_FOLDER/%USER_FOLDNAME/%k/%i/EnePhiDist_Job23_SDBDRC_vertexCut_100mm.root

rm EnePhiDist_Job23.root
rm Default.root

echo "FINISHED Vertex cut!"
echo "==================="

echo "STARTING Probability cut!"
echo "==================="
%FAL/flreconstruct -i CDCut.brio -p %CONF_FOLDER/SNCutsPipeline_probabilityCut.conf -o CDCut_probability.brio
%FAL/flreconstruct -i CDCut_probability.brio -p %CONF_FOLDER/p_MiModule_v00.conf 
%ROOT_FOLDER/root -l -b Job23.cpp

cp CDCut_probability.brio %MAIN_FOLDER/%USER_FOLDNAME/%k/%i/CDCut_probability.brio
cp EnePhiDist_Job23.root %MAIN_FOLDER/%USER_FOLDNAME/%k/%i/EnePhiDist_Job23_SDBDRC_probabilityCut_100mm.root

rm EnePhiDist_Job23.root
rm Default.root

echo "FINISHED probability cut!"
echo "==================="


end=`date +%s`

runtime=$((end-start))
echo " RUNTIME IS :"
echo $runtime
