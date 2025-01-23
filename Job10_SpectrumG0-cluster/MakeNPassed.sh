
echo "Starting %i file"

cd %MAIN_FOLDER/%USER_FOLDNAME/%i/

cp %CONF_FOLDER/Read_job7.cpp %MAIN_FOLDER/%USER_FOLDNAME/%i/Read_job7.cpp

pwd %MAIN_FOLDER/%USER_FOLDNAME/%i/
ls -la
%ROOT_FOLDER/root -l %MAIN_FOLDER/%USER_FOLDNAME/%i/Read_job7.cpp
echo "Finished %i file"

# cp ./NPassedhist2D.root %MAIN_FOLDER/%USER_FOLDNAME/%i/

pwd
ls -la
echo "==================="

