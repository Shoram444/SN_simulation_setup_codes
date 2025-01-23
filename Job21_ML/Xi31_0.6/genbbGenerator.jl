using MPGenbb, DataFrames, CSV

const MASS        = 0.511 # particle mass in MeV/c²
const PART_TYPE   = 3     # particle type: 1- gamma, 2-positron, 3-electron
const NEVENTS     = 1_000_001 #   how many events should be created +1
const FILENAME    = "input_module.genbb" # name of the output file
const INFILENAME  = "%CONF_FOLDER/xi51_0.1397-xi31_0.6-K2v_-0.6583-G0_G2_G22_G4.csv" # name of the input file - spectrum
const PROCESS     = "82Se 2νββ - Xi31 = 0.6"
const MAXENERGY   = 3.5

function main(kappa)

    df = CSV.File(INFILENAME) |> DataFrame

    T  = Tuple{Float64, Float64}[]
    p1 = Vector{Float64}[]
    p2 = Vector{Float64}[]
    
    open(FILENAME, "w") do file
        Threads.@threads for id in 0:NEVENTS-1

            T  = sample_energies(df)
            θ  = sample_theta_dif(kappa)

            p1 = get_first_vector(T[1], MASS)
            p2 = get_second_vector(T[2], MASS, p1, θ)
    
            if id%100_000 == 0 && id >1
                println("generated $id events!")
            end

            write(file, get_event_string(id, PART_TYPE , p1, p2))
        end
    end
end

####################################################
##### variables changed via sed command in Main_script.sh

sign     = "%KAPPA_SIGN"  
kappaMin = %KAPPA_MIN
kappaMax = %KAPPA_MAX
kappaN   = %KAPPA_N
kappaStep= %KAPPA_STEP

####################################################

kappa = sign == "plus" ? kappaMin + kappaStep*%k : -1*(kappaMin + kappaStep*%k)
kappa = round(kappa, digits = 4)
@show "Generated kappa = $kappa"

main(kappa)
