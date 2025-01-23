# Falaise Simulation Setup Repository

This repository contains various simulation setup scripts and configuration files for running simulations in **Falaise**. Each folder is named `JobXX_description`, where `XX` corresponds to a specific simulation setup. The scripts and files within these folders are useful for creating and managing simulation pipelines. While some folders may be outdated (designed for older versions of Falaise), the general structure and concepts remain applicable.

## Folder Contents

Each `JobXX_description` folder typically includes the following:

- **Simulation setup scripts:** `Main_script.sh` and `run_script.sh`
- **Configuration files:** `variant.profile`, `simu.conf`, `pipeline.config`, and others
- Supporting scripts, root macros, SNCuts config, logs, and files for setting up and running simulations

### `Main_script.sh`

This script is the entry point for running a simulation. It includes paths to essential dependencies and prompts the user for the following inputs:

1. **Simulation process type**
2. **Number of events to simulate per simulation run**
3. **Output directory for simulation results**
4. **Number of repetitions/runs**

The script allows splitting large simulations into smaller chunks. For example, a simulation with 100 million events can be split into 100 runs of 1 million events each, with the script creating subdirectories for each run.

### `run_script.sh`

This script is executed by `Main_script.sh` using SLURM via `sbatch run_script.sh`. It defines parameters required for submitting a SLURM job:

- **Partition:** Specifies the SLURM partition (queue) to use
- **Time:** Maximum runtime for the job (e.g., `--time=HH:MM:SS`)
- **Number of CPUs:** Number of CPU cores required (e.g., `--cpus-per-task=NUM`)
- **Memory:** Memory allocation for the job (e.g., `--mem=SIZE`)
- **Other SLURM parameters:** Additional required options, like `--output` and `--error` for log files

The script also includes commands for:

- Running simulations (`flsimulate`)
- Performing reconstruction (`flreconstruct`)
- Transforming `.brio` files into `.root` files for further analysis

### Configurations and Pipelines

Each folder contains configuration files (`simu.conf`, `pipeline.conf`, etc.) for setting up and running simulations. These files are often copied to the output data directories for reference and reproducibility.

## Notes

- Some setups may require adapting paths or parameters to match your local environment or the current version of Falaise.
- Ensure you have the necessary dependencies (e.g., Falaise, ROOT, Julia) installed and properly configured.

## Usage

1. Navigate to the desired folder:
```bash
cd JobXX_description
```
2. Run the main script:
```bash
./Main_script.sh
``` 
3. Follow the prompts to configure your simulation run.
4. Monitor SLURM job status using:
```bash
squeue
```
5. Analyze the resulting .root files as needed.

# Contributing
Feel free to contribute updates or improvements to the scripts, especially for compatibility with newer versions of Falaise.

# Disclaimer
Some folders may contain outdated configurations. Always verify compatibility with your software version.