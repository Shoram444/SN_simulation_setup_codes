#@format=datatools::configuration::variant
#@format.version=1.0
#@organization=snemo
#@application=falaise

[registry="geometry"]
layout = "Basic"
layout/if_basic/magnetic_field = false
layout/if_basic/source_layout = "Basic"
layout/if_basic/source_layout/if_basic/thickness = 250 um
layout/if_basic/source_layout/if_basic/material = "Se82"
layout/if_basic/source_calibration = false
layout/if_basic/shielding = true
calo_film_thickness = 25 um
tracking_gas_material = "Nemo3"

[registry="vertexes"]
generator = "source_pads_bulk"

[registry="primary_events"]
generator = "aegir"
generator/if_aegir/generators_file = "/pbs/home/m/mpetro/sps_mpetro/Projects/PhD/Aegir_generators/Aegir_flat_spectra/Examle_generators.conf"
generator/if_aegir/selected = "flat_2e_generator"

[registry="simulation"]
physics_mode = "Constructors"
physics_mode/if_constructors/em_model = "standard"
production_cuts = true
output_profile = "none"

