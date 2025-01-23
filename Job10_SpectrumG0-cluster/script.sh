echo "STARTED generating .genbb files:"
%JULIA/julia %MAIN_FOLDER/%USER_FOLDNAME/%i/genbbGenerator.jl
echo "FINISHED generating .genbb files:"
echo "================================="
cp input_module.genbb %MAIN_FOLDER/%USER_FOLDNAME/%i/

echo "STARTED flsimulate:"
%FAL/flsimulate -c %CONF_FOLDER/simu.conf -o %MAIN_FOLDER/%USER_FOLDNAME/%i/SD.brio 
echo "FINISHED flsimulate:"


echo "STARTED flreconstruct 1:"
%FAL/flreconstruct -i %MAIN_FOLDER/%USER_FOLDNAME/%i/SD.brio -p %CONF_FOLDER/rec.conf -o %MAIN_FOLDER/%USER_FOLDNAME/%i/CD.brio
echo "FINISHED flreconstruct:"


echo "STARTED flreconstruct 2:"
%FAL/flreconstruct -p %CONF_FOLDER/p_MiModule_v00.conf -i %MAIN_FOLDER/%USER_FOLDNAME/%i/CD.brio 

echo "FINISHED flreconstruct 2!"

cp Default.root %MAIN_FOLDER/%USER_FOLDNAME/%i/Default.root

