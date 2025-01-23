// Mi headers
#include "/pbs/home/m/mpetro/PROGRAMS/MiModule/include/MiEvent.h" 
#include "TLatex.h"

R__LOAD_LIBRARY(/pbs/home/m/mpetro/PROGRAMS/MiModule/lib/libMiModule.so);

/////////////////////////////////////
//////////Function headers

double 	count_CD_passed_events 	(TFile* 	_tFile, double _minE, double _maxE);
double 	count_SD_events 		(TFile* 	_tFile);
TH1F* 	get_Mi_hist 			(TFile* 	_tFile, double _minE, double _maxE);

/////////////////////////////////////
///////////Main

void Read_job7()
{
	const char* inPath  = "Default.root";
	const char* outPath = "hist2D.root";
    double      dE      =  100.0;  // in keV
    double      EMAX    = 3500.0;  // in kev
    double      EMIN    =    0.0;  // in kev
    double      NPassed =    0.0;

    TFile* 	   inFile = new TFile(inPath);
	TH2F*   h2NPassed = new TH2F("h2", "N_Passed in (E_min, E_max); E_min; E_max", 
								35, 0, 3500, 34, 100, 3500);
	TCanvas* cNPassed = new TCanvas("c","c", 3200, 3200);

	if(gSystem->AccessPathName(inPath))
	{
    	cout << "Default.root DOESNT EXIST - PATH: " << inPath << endl;
    } 
    else 
    {
    	for (double emi = EMIN; emi < EMAX; emi += dE)
    	{
    		for (double ema = emi + dE; ema < EMAX + dE; ema += dE)
    		{
    			NPassed = count_CD_passed_events(inFile, emi, ema);
				h2NPassed->Fill(emi, ema, NPassed);
				
				cout << " \tE in (" << emi << ", " << ema << ") keV" << endl; 
				cout << " \tNPassed = " << NPassed << endl;
    		}
    	}
    	cout << "Processing file " << inPath << endl;
    }

	TFile* outFile = new TFile(outPath, "RECREATE");

    h2NPassed->SetStats(kFALSE);
    h2NPassed->Draw("colz");
    h2NPassed->Write();
    cNPassed ->SaveAs("hist2D.png");
    outFile  ->Close();
}

///////////////////////////////////////
////////////// Function Definitions


double count_CD_passed_events(TFile* _tFile , double _minE, double _maxE)
{
	TTree* 		s = (TTree*) _tFile->Get("Event");
	MiEvent*  eve = new MiEvent();
	s->SetBranchAddress("Eventdata", &eve);

	double passedEvents   = 0.0;

	for(UInt_t i=0; i < s->GetEntries(); i++)	// Loop over events 
	{
		s->GetEntry(i);
		MiFilters*  CDFilter 	= new MiFilters(eve, _minE, _maxE);
		int    		numCDHit   	= eve->getCD()->getnoofcaloh();

		if (numCDHit > 0 && CDFilter->getAll())
		{
			passedEvents += 1;
		}
	}	

	return passedEvents ;
}

double count_SD_events(TFile* 	_tFile)
{
	TTree* 		s = (TTree*) _tFile->Get("Event");
	MiEvent*  eve = new MiEvent();
	s->SetBranchAddress("Eventdata", &eve);

	double countSDevents    = 0.0;

	for(UInt_t i=0; i < s->GetEntries(); i++)	// Loop over events
	{
		s->GetEntry(i);
		int    numPart   = eve->getSD()->getpartv()->size();

		if (numPart > 0)
		{
			countSDevents 		+= 1;
		}
	}	
	return countSDevents ;

}

TH1F* get_Mi_hist(TFile* 	_tFile , double _minE, double _maxE) //const char* _fPath
{
	TTree* 	tTree = (TTree*) _tFile->Get("Event");
	MiEvent*  eve = new MiEvent();
	TH1F*    tH1F = new TH1F("h1", "h1", 330, 0, 3300);    		// nBins, xMin, xMax are subject to change

	tTree->SetBranchAddress("Eventdata", &eve);

	for(UInt_t e=0; e < tTree->GetEntries(); e++)	// Loop over events
	{
		tTree->GetEntry(e);

		int 		numCDHit = eve->getCD()->getnoofcaloh();
		MiFilters*  CDFilter = new MiFilters(eve, _minE, _maxE);

		if (numCDHit > 0 && CDFilter->getAll())
		{
			for (int hit = 0; hit < numCDHit; hit++)
			{

				tH1F->Fill(eve->getCD()->getcalohit(hit)->getE());
			}			
		}
	}	
	return  tH1F;
}