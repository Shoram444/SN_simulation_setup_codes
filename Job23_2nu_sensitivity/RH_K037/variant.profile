#@format=datatools::configuration::variant
#@format.version=1.0
#@organization=snemo
#@application=falaise

[registry="geometry"]
layout = "Basic"
layout/if_basic/magnetic_field = false
layout/if_basic/source_layout = "RealisticFlat"
layout/if_basic/source_calibration = false
layout/if_basic/shielding = false
calo_film_thickness = 25 um
tracking_gas_material = "HeliumMix"

[registry="vertexes"]
generator = "source_pads_bulk"

[registry="primary_events"]
generator = "event_input_%i"

[registry="simulation"]
physics_mode = "Constructors"
physics_mode/if_constructors/em_model = "standard"
production_cuts = true
output_profile = "none"

