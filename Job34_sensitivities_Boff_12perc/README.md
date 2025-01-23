The objective of this simulation setup is to obtain 2-electron topology simulations. 

## The simulation setup is the following: 
- Use `realistic_flat` source foil geometry (afaik the curved foils geometry is not exactly compatible across all analyses, correct me if I'm wrong)
- Use **magnetic field off**
- Use **TKReconstrcut** to reconstruct the trajectories (with polylines)
- Use **12% FWHM** across main OMs (Or do we have some better solution ready?)
- Use basic **SimRC** setup

## Data-cuts
```bash
useEventHasTwoTracks : boolean = true
useEventHasTwoFoilVertices : boolean = true
useEventHasTwoCaloHits : boolean = true
useEventHasTwoDistinctAssociatedCaloHits : boolean = true

useEventHasSumEnergyAbove : boolean = true
minSumEnergy : real = 300.0
useEventHasSumEnergyBelow : boolean = true
maxSumEnergy : real = 3500.0

useEventHasFoilVertexDistanceBelow : boolean = true
maxFoilVertexDistance : real = 50.0  # mm

useEventHasPintAbove : boolean = true  # internal probability ToF cut
minPint : real = 0.04

useEventHasPextBelow : boolean = true   # external probability ToF cut
maxPext : real = 0.01
```

