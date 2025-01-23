#@format=datatools::configuration::variant
#@format.version=1.0
#@organization=snemo
#@application=falaise

[registry="geometry"]
layout = "Basic"
layout/if_basic/magnetic_field = false
layout/if_basic/source_layout = "Basic"
layout/if_basic/source_layout/if_basic/thickness = %THICKNESS um
layout/if_basic/source_layout/if_basic/material = "%SOURCE_ISO"
layout/if_basic/source_calibration = false
layout/if_basic/shielding = true
calo_film_thickness = 25 um
tracking_gas_material = "Nemo3"

[registry="vertexes"]
generator = "source_pads_bulk"

[registry="primary_events"]
generator = "flat_versatile_generator"
generator/if_flat_versatile/particle = "electron"
generator/if_flat_versatile/energy_min = %ENERGY keV
generator/if_flat_versatile/energy_max = %ENERGY keV


[registry="simulation"]
physics_mode = "Constructors"
physics_mode/if_constructors/em_model = "standard"
production_cuts = true
output_profile = "all_details"

