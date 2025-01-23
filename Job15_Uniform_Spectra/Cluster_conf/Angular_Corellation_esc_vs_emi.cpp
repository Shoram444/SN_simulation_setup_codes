// Mi headers
#include "/pbs/home/m/mpetro/PROGRAMS/MiModule_test/include/MiEvent.h" 
#include "/pbs/home/m/mpetro/PROGRAMS/MiModule_test/include/MiSDVisuHit.h" 
#include "/pbs/home/m/mpetro/PROGRAMS/MiModule_test/include/MiFilters.h"

#include "TLatex.h"
#include "TVector3.h"


#include <string>
#include <iostream>
#include <sstream>

R__LOAD_LIBRARY(/pbs/home/m/mpetro/PROGRAMS/MiModule_test/lib/libMiModule.so);

////////////// Function used in script
/////////////////////////////////////////////////////////////
int first_step_in_gas(MiEvent*  _eve, int _trackID) // returns the step position of the hit_step when it first enters tracking gas
{
	for (int step = 0; step < _eve->getSD()->getvisuhitv()->size() ; step++) // iterating over the steps of the simulation
	{
		if( // check whether the particle belongs to 1st track, is in gas, has left volume (source) and entered new vol (gas)																					
			_eve->getSD()->getvisuhitv()->at(step).getTrackID()       == _trackID                &&
			_eve->getSD()->getvisuhitv()->at(step).getMaterial()      == "tracking_gas" 		 &&
			_eve->getSD()->getvisuhitv()->at(step).getLeftVolume()    == true                    &&
			_eve->getSD()->getvisuhitv()->at(step).getEnteredVolume() == true                       	
		  )
		{
			return step;
		}
	}
	return -1; //return zero if the particle never left source foil (happens when we get "fakeItTillYouMakeIt events")
}

////////////// MAIN BLOCK OF CODE
/////////////////////////////////////////////////////////////
void Angular_Corellation_esc_vs_emi()
{

////////////// Initialize File names/paths
/////////////////////////////////////////////////////////////
	const char* inFileName   = "Default.root";													 //FOR TESTING PURPOSES USING ONLY FOLDER 0/
	const char* outPathAngularCorrelation  = "AngularCorrelationAllEnergies.root";

	int nFiles = 1;

////////////// Initialize visualization
/////////////////////////////////////////////////////////////
	TH2D* 			h2d 						= new TH2D("h2d", "angularCorrelation", 180, 0, 180, 180, 0, 180); 
	TFile* 			outFileAngularCorrelation 	= new TFile(outPathAngularCorrelation, "RECREATE");
	TCanvas*  		c2d    						= new TCanvas("c", "angularCorrelation", 3600,2400);
	
	TCanvas*  		c1d[180];
	TH1F*           h1d[180]; // initialize TH1D histograms
	for (int h = 0; h < 180; h++)
	{
		stringstream ssCanvas1D;
		ssCanvas1D << "Emitted_up_" << h;
		c1d[h] = new TCanvas(ssCanvas1D.str().c_str(), ssCanvas1D.str().c_str(), 3600, 2800);

		stringstream ssHist1D;
		ssHist1D << "h" << h;
		h1d[h] = new TH1F(ssHist1D.str().c_str(), ssHist1D.str().c_str(), 180, 0, 180);
	}

////////////// Initialize variables to be saved
/////////////////////////////////////////////////////////////
	double   thetaEmitted, momentumEmitted1x, momentumEmitted1y, momentumEmitted1z, momentumEmitted2x, momentumEmitted2y, momentumEmitted2z;
	TVector3 momentumEmitted1;
	TVector3 momentumEmitted2;

	double   thetaEscaped, momentumEscaped1x, momentumEscaped1y, momentumEscaped1z, momentumEscaped2x, momentumEscaped2y, momentumEscaped2z;
	TVector3 momentumEscaped1;
	TVector3 momentumEscaped2;

	double   reconstructedEnergy1, reconstructedEnergy2;

////////////// Saving Data
/////////////////////////////////////////////////////////////
	TTree* tree 			= new TTree("tree","tree");
	tree->Branch("thetaEmitted", &thetaEmitted, "thetaEmitted/D");
	tree->Branch("momentumEmitted1x", &momentumEmitted1x, "momentumEmitted1x/D");
	tree->Branch("momentumEmitted1y", &momentumEmitted1y, "momentumEmitted1y/D");
	tree->Branch("momentumEmitted1z", &momentumEmitted1z, "momentumEmitted1z/D");
	tree->Branch("momentumEmitted2x", &momentumEmitted2x, "momentumEmitted2x/D");
	tree->Branch("momentumEmitted2y", &momentumEmitted2y, "momentumEmitted2y/D");
	tree->Branch("momentumEmitted2z", &momentumEmitted2z, "momentumEmitted2z/D");

	tree->Branch("thetaEscaped", &thetaEscaped, "thetaEscaped/D");
	tree->Branch("momentumEscaped1x", &momentumEscaped1x, "momentumEscaped1x/D");
	tree->Branch("momentumEscaped1y", &momentumEscaped1y, "momentumEscaped1y/D");
	tree->Branch("momentumEscaped1z", &momentumEscaped1z, "momentumEscaped1z/D");
	tree->Branch("momentumEscaped2x", &momentumEscaped2x, "momentumEscaped2x/D");
	tree->Branch("momentumEscaped2y", &momentumEscaped2y, "momentumEscaped2y/D");
	tree->Branch("momentumEscaped2z", &momentumEscaped2z, "momentumEscaped2z/D");

	tree->Branch("reconstructedEnergy1", &reconstructedEnergy1, "reconstructedEnergy1/D");
	tree->Branch("reconstructedEnergy2", &reconstructedEnergy2, "reconstructedEnergy2/D");


////////////// Initialize counters
/////////////////////////////////////////////////////////////
	int stepBeforeGas 				= -1;   // Represents the step just before exitting to the tracker gas volume
											// this is initiated to -1
	int fakeItTillYouMakeItCounter 	= 0; 	// counts the events where one of the primary electron dies, but the event passes MiFilters still


////////////// Loop over files
/////////////////////////////////////////////////////////////
	for( int file = 0; file < nFiles; file ++)
	{
		stringstream ssInPath;
		ssInPath << inFileName;

		if(gSystem->AccessPathName(ssInPath.str().c_str())) // check whether Default.root exists
		{
	    	cout << "Default.root DOESNT EXIST - PATH: " << ssInPath.str().c_str() << endl;
		} 
		else 
		{
			cout << ssInPath.str().c_str() << endl;

	////////////// Initialize reading data
	/////////////////////////////////////////////////////////////
			TFile* 	  		inFile 						= new TFile(ssInPath.str().c_str());
			TTree* 			s 		  					= (TTree*) inFile->Get("Event");
			MiEvent*  		eve 						= new MiEvent();
			MiFilters*  	miFilter;

			s->SetBranchAddress("Eventdata", &eve);

	/////////////////////////////////////////////////////////////
			for (int e = 0; e < s->GetEntries(); ++e)  //s->GetEntries()  
			{ 	
				s->GetEntry(e);
				miFilter 	= new MiFilters(eve, 0, 3500);

				if(miFilter->getAll()) // only particles that have passed 2vbb filters
				{
					if(eve->getSD()->getpartv()->size() != 2){continue;} // precaution, that allways we have 2 particles 

					momentumEmitted1x 		= eve->getSD()->getpart(0)->getp()->getX();
					momentumEmitted1y 		= eve->getSD()->getpart(0)->getp()->getY();
					momentumEmitted1z 		= eve->getSD()->getpart(0)->getp()->getZ();
					reconstructedEnergy1	= eve->getSD()->getpart(0)->getE();

					momentumEmitted2x 		= eve->getSD()->getpart(1)->getp()->getX();
					momentumEmitted2y 		= eve->getSD()->getpart(1)->getp()->getY();
					momentumEmitted2z 		= eve->getSD()->getpart(1)->getp()->getZ();
					reconstructedEnergy2	= eve->getSD()->getpart(1)->getE();


					momentumEmitted1.SetXYZ(momentumEmitted1x,   // Since in MiModule, MiSDParticle momentum is of type MiVector3d
											momentumEmitted1y,   // There is a need for converstion to TVector3 for convenience (can use v.Angle(v2))
											momentumEmitted1z);  // is it so that particle 0 is TrackID 1?

					momentumEmitted2.SetXYZ(momentumEmitted2x,   
											momentumEmitted2y,   
											momentumEmitted2z);  // is it so that particle 1 is TrackID 2? Does it matter?

					int firstOuttaGas1 = first_step_in_gas(eve, 1); // returns the step at which the particle escapes source foil and enters tracker
					int firstOuttaGas2 = first_step_in_gas(eve, 2); // the trackID should be the ones of primary tracks I guess?

					if( firstOuttaGas1 == -1 || firstOuttaGas2 == -1 ) // faker events (this happens when one of the emitted electrons is killed in foil
																	   // but the other one splits into two [ie. scattering] before escaping foil)
					{
						fakeItTillYouMakeItCounter++;
						cout << " AT EVENT " << e << "  firstOuttaGas1 = " << firstOuttaGas1 << " firstOuttaGas2 = " << firstOuttaGas2 << endl;
						continue;
					}

					momentumEscaped1 = eve->getSD()->getvisuhitv()->at(firstOuttaGas1).getMomentumStart();  // This is implemented in MiModule by MP 
					momentumEscaped2 = eve->getSD()->getvisuhitv()->at(firstOuttaGas2).getMomentumStart();  // Momentum is returned as TVector3

					momentumEscaped1x = momentumEscaped1.X();
					momentumEscaped1y = momentumEscaped1.Y();
					momentumEscaped1z = momentumEscaped1.Z();

					momentumEscaped2x = momentumEscaped2.X();
					momentumEscaped2y = momentumEscaped2.Y();
					momentumEscaped2z = momentumEscaped2.Z();

					thetaEmitted = momentumEmitted1.Angle(momentumEmitted2)*180/TMath::Pi();  // Angle() returns in radians, conversion to degrees
					thetaEscaped = momentumEscaped1.Angle(momentumEscaped2)*180/TMath::Pi();

					h1d[int(floor(thetaEmitted))]->Fill(thetaEscaped);   // fill histogram1D where the emitted angle falls within 1 bin
					h2d                          ->Fill(thetaEmitted,thetaEscaped);

					tree->Fill();
				} 
			} 	
		}
	}
	////////////// Visualization
	/////////////////////////////////////////////////////////////
	cout << "fakeItTillYouMakeItCounter = " << fakeItTillYouMakeItCounter << endl;


	c2d->cd();
	h2d->SetTitle("Uniform Spectrum; thetaEmitted; thetaEscaped");
	h2d->Draw("COLZ");

	for( int h = 0; h < 180; h++ )
	{
		c1d[h]->cd();
		h1d[h]->Fit("gaus");
		gStyle->SetOptFit(1111); // to show the fit parameters in box
		h1d[h]->Draw();
	}


	outFileAngularCorrelation->Write();
	outFileAngularCorrelation->Close();
}

