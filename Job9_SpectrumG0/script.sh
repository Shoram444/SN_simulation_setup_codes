flsimulate -c simu.conf -o SD.brio -V "debug"
flreconstruct -i SD.brio -p rec.conf -o CD.brio
flreconstruct -p p_MiModule_v00.conf -i CD.brio
