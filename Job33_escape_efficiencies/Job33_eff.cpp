// Mi headers
// #include "/pbs/home/m/mpetro/PROGRAMS/MiModule/include/MiEvent.h" 
// #include "/pbs/home/m/mpetro/PROGRAMS/MiModule/include/MiSDVisuHit.h" 
// #include "/pbs/home/m/mpetro/PROGRAMS/MiModule/include/MiFilters.h"
// #include "/pbs/home/m/mpetro/PROGRAMS/MiModule/include/MiCDParticle.h"
// #include "/pbs/home/m/mpetro/PROGRAMS/MiModule/include/MiModule.h"

#include "TLatex.h"
#include "TVector3.h"


#include <string>
#include <iostream>
#include <sstream>
#include <algorithm>

R__LOAD_LIBRARY(/pbs/home/m/mpetro/PROGRAMS/MiModule/lib/libMiModule.so);

////////////// Function used in script
/////////////////////////////////////////////////////////////



////////////// MAIN BLOCK OF CODE
/////////////////////////////////////////////////////////////
void Job33_eff()
{
////////////// Initialize File names/paths
/////////////////////////////////////////////////////////////
	const char* inFileName         = "Default.root";													 //FOR TESTING PURPOSES USING ONLY FOLDER 0/
	const char* outPathAngularCorrelation = "efficiency_count.root";
	TFile* 	  outFileAngularCorrelation = new TFile(outPathAngularCorrelation, "RECREATE");

////////////// Initialize variables to be saved
/////////////////////////////////////////////////////////////

	// variables Simulated at Decay (SD)
	int nRecoTracks; // number of reconstructed tracks

	TTree* tree = new TTree("tree","tree");


	tree->Branch("nRecoTracks", &nRecoTracks, "nRecoTracks/I");


////////////// Initialize counters
/////////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////////
	if(gSystem->AccessPathName(inFileName)) // check whether Default.root exists
	{
		cout << "Default.root DOESNT EXIST - PATH: " << inFileName << endl;
	} 
	else 
	{
		cout << "Processing: " << inFileName << endl;

		////////////// Initialize reading data
		/////////////////////////////////////////////////////////////
		TFile* 	 		inFile 						= new TFile(inFileName);
		TTree* 			inTree 		 				= (TTree*) inFile->Get("Event");
		MiEvent* 		eve 						= new MiEvent();

		inTree->SetBranchAddress("Eventdata", &eve);
		int nEntries = inTree->GetEntries();


/////////////////////////////////////////////////////////////
		for (int e = 0; e < nEntries; ++e) 
		{ 	
			inTree->GetEntry(e);
				
			nRecoTracks = eve->getPTD()->getpartv()->size();
			tree->Fill();
		} 	
	}

	// cout << "fakeItTillYouMakeItCounter = " << fakeItTillYouMakeItCounter << endl; // these events are skipped in the simulation 

	outFileAngularCorrelation->Write();
	outFileAngularCorrelation->Close();
}

