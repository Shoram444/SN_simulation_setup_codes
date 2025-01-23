#!/bin/sh

# SLURM options:

#SBATCH --job-name=%ISO%SOURCE         	 # Job name
#SBATCH --partition=htc                  # Partition choice (most generally we work with htc, but for quick debugging you can use
										 #					 #SBATCH --partition=flash. This avoids waiting times, but is limited to 1hr)
#SBATCH --mem=16G                     	 # RAM
#SBATCH --licenses=sps                   # When working on sps, must declare license!!

#SBATCH --chdir=$TMPDIR
#SBATCH --time=4-0                 	 	 # Time for the job in format “minutes:seconds” or  “hours:minutes:seconds”, “days-hours”
#SBATCH --cpus-per-task=1                # Number of CPUs

echo "================================="
echo "run_script started:"
start=`date +%s`

echo "Working in directory: "
pwd
echo "================================="

echo "STARTING flsimulate:"
%FAL/flsimulate -c %DATA_FOLDER/%USER_FOLDNAME/%f/%ISO.conf -o SD.brio 
echo "FINISHED flsimulate."

echo "ls after flsimulate."
ls -l

echo "STARTING flreconstruct:"
%FAL/flreconstruct -i SD.brio -p %MAIN_FOLDER/rec.conf -o CD.brio
echo "FINISHED flreconstruct."

echo "STARTING SNCuts module:"
%FAL/flreconstruct -i CD.brio -p %MAIN_FOLDER/SNCutsPipeline.conf -o CDCut.brio
echo "FINISHED SNCuts module."

echo "ls after flreconstruct"
ls -l

echo "STARTING MiModule:"
%FAL/flreconstruct -p %MAIN_FOLDER/p_MiModule_v00.conf -i CDCut.brio 
echo "FINISHED MiModule!"

cp CDCut.brio %DATA_FOLDER/%USER_FOLDNAME/%f/CDCut.brio              # if you want to keep CD.brio
ls -l

echo "==================="
echo "==================="
echo "FINISHED simulation, STARTING analysis!"
pwd
ls -l
echo "==================="
echo "STARTED Job23.cpp:"

cp %MAIN_FOLDER/Job23.cpp Job23.cpp

%ROOT_FOLDER/root -l -b Job23.cpp
echo "ls after Job23.cpp."
ls
echo "FINISHED Job23.cpp."

cp EnePhiDist_Job23.root %DATA_FOLDER/%USER_FOLDNAME/%f/EnePhiDist_Job23_SDBDRC.root

rm EnePhiDist_Job23.root
rm Default.root


echo "==================="
echo "==================="
echo "STARTING Vertex cut!"
echo "==================="
%FAL/flreconstruct -i CDCut.brio -p %MAIN_FOLDER/SNCutsPipeline_vertexCut.conf -o CDCut_vertex.brio
%FAL/flreconstruct -i CDCut_vertex.brio -p %MAIN_FOLDER/p_MiModule_v00.conf 
%ROOT_FOLDER/root -l -b Job23.cpp

cp CDCut_vertex.brio %DATA_FOLDER/%USER_FOLDNAME/%f/CDCut_vertex.brio
cp EnePhiDist_Job23.root %DATA_FOLDER/%USER_FOLDNAME/%f/EnePhiDist_Job23_SDBDRC_vertexCut_100mm.root

rm EnePhiDist_Job23.root
rm Default.root

echo "FINISHED Vertex cut!"
echo "==================="

echo "==================="
echo "==================="
echo "STARTING probability cut!"
echo "==================="
%FAL/flreconstruct -i CDCut.brio -p %MAIN_FOLDER/SNCutsPipeline_probabilityCut.conf -o CDCut_probability.brio
%FAL/flreconstruct -i CDCut_probability.brio -p %MAIN_FOLDER/p_MiModule_v00.conf 
%ROOT_FOLDER/root -l -b Job23.cpp

cp CDCut_probability.brio %DATA_FOLDER/%USER_FOLDNAME/%f/CDCut_probability.brio
cp EnePhiDist_Job23.root %DATA_FOLDER/%USER_FOLDNAME/%f/EnePhiDist_Job23_SDBDRC_probabilityCut_100mm.root

rm EnePhiDist_Job23.root
rm Default.root

echo "FINISHED probability cut!"
echo "==================="

end=`date +%s`

runtime=$((end-start))
echo " RUNTIME IS :"
echo $runtime
