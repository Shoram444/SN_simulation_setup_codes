using MPGenbb, DataFrames, CSV

const MASS        = 0.511 # particle mass in MeV/c²
const PART_TYPE   = 3     # particle type: 1- gamma, 2-positron, 3-electron
const NEVENTS     = 1_000_001  # how many events should be created +1
const FILENAME    = "input_module.genbb" # name of the output file
const PROCESS     = "82Se 0νββ - Energy generated via SpectrumG0 - from R. Dvornicky"

function main()
    inFile = string("/pbs/home/m/mpetro/Projects/PhD/Codes/Job12_SpectralComparison-G0vsFalaise/Cluster_conf/spectrumG0_Rebinned_prec0001.csv")


    df = CSV.File(inFile) |> DataFrame

    T  = Tuple{Float64, Float64}[]
    p1 = Vector{Float64}[]
    p2 = Vector{Float64}[]
    
    open(FILENAME, "w") do file
        Threads.@threads for id in 0:NEVENTS-1
            T  = sample_energies(df)

            p1 = get_first_vector(T[1], MASS)
            p2 = get_second_vector(T[2], MASS, p1)
    
            if id%100_000 == 0 && id >1
                println("generated $id events!")
            end

            write(file, get_event_string(id, PART_TYPE , p1, p2))
        end
    end
end

main()



