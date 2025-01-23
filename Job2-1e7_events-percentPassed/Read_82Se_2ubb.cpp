// Mi headers
#include "/pbs/home/m/mpetro/PROGRAMS/MiModule/include/MiEvent.h" 

R__LOAD_LIBRARY(/pbs/home/m/mpetro/PROGRAMS/MiModule/lib/libMiModule.so);

double count_CD_events(const char* _fpath, double _minE, double _maxE)
{
	TFile* 		f = new TFile(_fpath);
	TTree* 		s = (TTree*) f->Get("Event");
	MiEvent*  Eve = new MiEvent();
	s->SetBranchAddress("Eventdata", &Eve);

	double countCDevents    = 0.0;

	for(UInt_t i=0; i < s->GetEntries(); i++)	// Loop over events
	{
		s->GetEntry(i);
		MiFilters*  CDFilter 	= new MiFilters(Eve, _minE, _maxE);
		int    		numCDHit   	= Eve->getCD()->getnoofcaloh();

		if (numCDHit > 0 && CDFilter->getAll())
		{
			countCDevents 			+= 1;
		}
	}	
	return countCDevents ;
}

double count_SD_events(const char* _fpath)
{
	TFile* 		f = new TFile(_fpath);
	TTree* 		s = (TTree*) f->Get("Event");
	MiEvent*  Eve = new MiEvent();
	s->SetBranchAddress("Eventdata", &Eve);

	double countSDevents    = 0.0;

	for(UInt_t i=0; i < s->GetEntries(); i++)	// Loop over events
	{
		s->GetEntry(i);
		int    numPart   = Eve->getSD()->getpartv()->size();

		if (numPart > 0)
		{
			countSDevents 		+= 1;
		}
	}	
	return countSDevents ;

}

void Read_82Se_2ubb()
{
    const char* DIRPATH = "/pbs/home/m/mpetro/Projects/PhD/Cluster/Data/82Se_2ubb-1e5epf/Data/";

    double allSDEvents     = 0.0;
    double allCDF1Events   = 0.0;
    double allCDF2Events   = 0.0;
    double allCDF3Events   = 0.0;
    double percentF1Passed = 0.0;
    double percentF2Passed = 0.0;
    double percentF3Passed = 0.0;

	for (int fld = 0; fld < 100; fld++)
	{
		stringstream fpath;
		fpath << DIRPATH << fld << "/Default.root";

		if(gSystem->AccessPathName(fpath.str().c_str()))
		{
        	cout << "Default.root DOESNT EXIST - " << fld << endl;
	    } 
	    else 
	    {
        	allCDF1Events += count_CD_events(fpath.str().c_str(), -1000.0, 10000.0);
        	allCDF2Events += count_CD_events(fpath.str().c_str(),  2000.0,  3300.0);
        	allCDF3Events += count_CD_events(fpath.str().c_str(),  2700.0,  3300.0);
        	allSDEvents   += count_SD_events(fpath.str().c_str()); 

        	cout << "Processing file " << fpath.str().c_str() << endl;
	    }
	}
	cout << "================== 82Se 2nubb ================================" << endl;
	cout << " percentF1Passed = " << (allCDF1Events/allSDEvents)*100 << " %" << endl;
	cout << " percentF2Passed = " << (allCDF2Events/allSDEvents)*100 << " %" << endl;
	cout << " percentF3Passed = " << (allCDF3Events/allSDEvents)*100 << " %" << endl;

}






