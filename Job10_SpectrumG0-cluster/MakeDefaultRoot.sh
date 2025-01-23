DIR=/sps/nemo/scratch/mpetro/Projects/PhD/Cluster/Data/Job10_10f_1e5events_final/

for (( i=7 ; i<20 ; i++ ))
do
	echo "Starting $i file"

	cd $DIR/$i/

    rm Default.root

	pwd
	ls -la
	flreconstruct -i $DIR/$i/CD.brio -p ~/Projects/PhD/Codes/Job10_SpectrumG0-cluster/p_MiModule_v00.conf 
	echo "Finished $i file"

	pwd
	ls -la
	echo "==================="

done
