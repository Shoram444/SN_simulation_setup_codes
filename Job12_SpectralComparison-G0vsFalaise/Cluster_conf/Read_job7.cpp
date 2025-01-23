// Mi headers
#include "/pbs/home/m/mpetro/PROGRAMS/MiModule/include/MiEvent.h" 
#include "TLatex.h"

R__LOAD_LIBRARY(/pbs/home/m/mpetro/PROGRAMS/MiModule/lib/libMiModule.so);

//////////////////////////////////////////////////////////////////////
////   Main

void Read_job7()
{
//////////////////////////////////////////////////////////////////////
////   INITIALIZING FILES, HISTOGRAMS AND ENERGY RANGE
	const char* inPath  = "Default.root";
	const char* outPath = "NPassedSpectrumG0.root";
    double      dE      =  100.0;  // in keV
    double      EMAX    = 3500.0;  // in kev
    double      EMIN    =    0.0;  // in kev

	TH2F*   h2NPassed = new TH2F("h2", "N_Passed in (E_min, E_max); E_min; E_max", 
									35, 0, 3500, 34, 100, 3500);
	TCanvas* cNPassed = new TCanvas("c","c", 3200, 3200);
////
//////////////////////////////////////////////////////////////////////

	if(gSystem->AccessPathName(inPath)) // check whether file can be opened
	{
    	cout << "Default.root DOESNT EXIST - PATH: " << inPath << endl;
    } 
    else 
    {
    	cout << inPath << endl;

//////////////////////////////////////////////////////////////////////
////   INITIALIZING TTREE AND EVENT

    	TFile* 	   inFile 	= new TFile(inPath);
    	TTree* 		s 		= (TTree*) inFile->Get("Event");
		MiEvent*  eve 		= new MiEvent();
		s->SetBranchAddress("Eventdata", &eve);
////
//////////////////////////////////////////////////////////////////////

		MiFilters*  CDFilter;
		int    		numCDHit;

		TDatime startTime = TDatime();
		TDatime stopTime  = TDatime();

		for(UInt_t i=0; i < s->GetEntries(); i++)									// Loop over events 
		{
			s->GetEntry(i);
			numCDHit   	= eve->getCD()->getnoofcaloh();  

			if (numCDHit > 0 )  													// check that there are calohits, if not than skip this event
			{	
		    	for (double emin = EMIN; emin < EMAX; emin += dE) 					// loop over Emin 
		    	{
		    		for (double emax = emin + dE; emax < EMAX + dE; emax += dE) 	// loop over Emax
		    		{
		    			CDFilter 	= new MiFilters(eve, emin, emax); 				// create filter with event and energy range

		    			if (CDFilter->getAll()) 									// add event to histogram iff all filters are passed
						{
							h2NPassed->Fill(emin, emax);                       	    
						}
						delete CDFilter;
		    		}
		    	}
			}
			if(i%20000 == 0)
			{
				stopTime = TDatime();

				printf("Processed %i events! It took %i s \n", i, (stopTime.GetSecond() - startTime.GetSecond()));
				startTime = stopTime;
			}
		}	

    	inFile->Close();
    }

	TFile* outFile = new TFile(outPath, "RECREATE");

    h2NPassed->SetStats(kFALSE);
    h2NPassed->Draw("colz");
    h2NPassed->Write();
    cNPassed ->SaveAs("hist2D.png");
    outFile  ->Close();
}

