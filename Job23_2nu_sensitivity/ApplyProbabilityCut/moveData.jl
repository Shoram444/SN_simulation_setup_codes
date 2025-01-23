MAIN_DIR = "/sps/nemo/scratch/mpetro/Projects/PhD/Cluster/DataWithBField"
DATA_DIR = "/pbs/home/m/mpetro/sps_mpetro/Projects/SNSensitivityEstimate/data/sims/SDBDRC_vertex_prob"

folders  = readdir(MAIN_DIR)

for fldr in folders # iterate through folders in MAIN_DIR
    if ( occursin( "Job23", fldr ) ) # foldername must start with Job23
        @show fldr = joinpath(MAIN_DIR, fldr, "0") # get full absolute path to the folder Job23_*
        rootFileOld = "combined_vertex_probability_cut.root" 

        for subfldr in readdir(fldr) # iterate through subfolders in folder
            if( occursin(rootFileOld, subfldr) ) # check that rootFileOld is in the subfolder
                @show oldRootFilePath = joinpath( fldr, subfldr) # create full old path
                fname = replace(fldr, "Job23_" => "") * "_SDBDRC_vertex_prob.root" # rename the file

                @show newRootFilePath = joinpath(DATA_DIR, fname) # get full new path to copy to
                cp(oldRootFilePath,  newRootFilePath )
            end
        end
    end
end



