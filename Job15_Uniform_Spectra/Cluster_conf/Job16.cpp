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
	const char* inFileName                 = "Default.root";													 //FOR TESTING PURPOSES USING ONLY FOLDER 0/
	const char* outPathAngularCorrelation  = "AngularCorrelationAllEnergies.root";
	TFile* 	    outFileAngularCorrelation  = new TFile(outPathAngularCorrelation, "RECREATE");

	int nFiles = 1;

////////////// Initialize variables to be saved
/////////////////////////////////////////////////////////////
	double   theta, p1XEmitted, p1YEmitted, p1ZEmitted, p2XEmitted, p2YEmitted, p2ZEmitted;
	double   x1Emitted, y1Emitted, z1Emitted, x2Emitted, y2Emitted, z2Emitted;

	TVector3 p1Emitted;
	TVector3 p2Emitted;

	double   phi, p1XEscaped, p1YEscaped, p1ZEscaped, p2XEscaped, p2YEscaped, p2ZEscaped;
	double   x1Escaped, y1Escaped, z1Escaped, x2Escaped, y2Escaped, z2Escaped;

	TVector3 p1Escaped;
	TVector3 p2Escaped;

	double   reconstructedEnergy1, reconstructedEnergy2;

////////////// Saving Data
/////////////////////////////////////////////////////////////
	TTree* tree 			= new TTree("tree","tree");
	tree->Branch("theta", &theta, "theta/D");
	tree->Branch("p1XEmitted", &p1XEmitted, "p1XEmitted/D");
	tree->Branch("p1YEmitted", &p1YEmitted, "p1YEmitted/D");
	tree->Branch("p1ZEmitted", &p1ZEmitted, "p1ZEmitted/D");
	tree->Branch("p2XEmitted", &p2XEmitted, "p2XEmitted/D");
	tree->Branch("p2YEmitted", &p2YEmitted, "p2YEmitted/D");
	tree->Branch("p2ZEmitted", &p2ZEmitted, "p2ZEmitted/D");
	tree->Branch("x1Emitted", &x1Emitted, "x1Emitted/D");
	tree->Branch("y1Emitted", &y1Emitted, "y1Emitted/D");
	tree->Branch("z1Emitted", &z1Emitted, "z1Emitted/D");
	tree->Branch("x2Emitted", &x2Emitted, "x2Emitted/D");
	tree->Branch("y2Emitted", &y2Emitted, "y2Emitted/D");
	tree->Branch("z2Emitted", &z2Emitted, "z2Emitted/D");

	tree->Branch("phi", &phi, "phi/D");
	tree->Branch("p1XEscaped", &p1XEscaped, "p1XEscaped/D");
	tree->Branch("p1YEscaped", &p1YEscaped, "p1YEscaped/D");
	tree->Branch("p1ZEscaped", &p1ZEscaped, "p1ZEscaped/D");
	tree->Branch("p2XEscaped", &p2XEscaped, "p2XEscaped/D");
	tree->Branch("p2YEscaped", &p2YEscaped, "p2YEscaped/D");
	tree->Branch("p2ZEscaped", &p2ZEscaped, "p2ZEscaped/D");
	tree->Branch("x1Escaped", &x1Escaped, "x1Escaped/D");
	tree->Branch("y1Escaped", &y1Escaped, "y1Escaped/D");
	tree->Branch("z1Escaped", &z1Escaped, "z1Escaped/D");
	tree->Branch("x2Escaped", &x2Escaped, "x2Escaped/D");
	tree->Branch("y2Escaped", &y2Escaped, "y2Escaped/D");
	tree->Branch("z2Escaped", &z2Escaped, "z2Escaped/D");

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

					p1XEmitted 		= eve->getSD()->getpart(0)->getp()->getX();
					p1YEmitted 		= eve->getSD()->getpart(0)->getp()->getY();
					p1ZEmitted 		= eve->getSD()->getpart(0)->getp()->getZ();
					x1Emitted       = eve->getSD()->getpart(0)->getr()->getX();
					y1Emitted       = eve->getSD()->getpart(0)->getr()->getY();
					z1Emitted       = eve->getSD()->getpart(0)->getr()->getZ();
					reconstructedEnergy1	= eve->getSD()->getpart(0)->getE();

					p2XEmitted 		= eve->getSD()->getpart(1)->getp()->getX();
					p2YEmitted 		= eve->getSD()->getpart(1)->getp()->getY();
					p2ZEmitted 		= eve->getSD()->getpart(1)->getp()->getZ();
					x2Emitted       = eve->getSD()->getpart(1)->getr()->getX();
					y2Emitted       = eve->getSD()->getpart(1)->getr()->getY();
					z2Emitted       = eve->getSD()->getpart(1)->getr()->getZ();
					reconstructedEnergy2	= eve->getSD()->getpart(1)->getE();


					p1Emitted.SetXYZ(
										p1XEmitted,   // Since in MiModule, MiSDParticle momentum is of type MiVector3d
										p1YEmitted,   // There is a need for converstion to TVector3 for convenience (can use v.Angle(v2))
										p1ZEmitted    // is it so that particle 0 is TrackID 1?
									);  

					p2Emitted.SetXYZ(
										p2XEmitted,   
										p2YEmitted,   
										p2ZEmitted    // is it so that particle 1 is TrackID 2? Does it matter?
									);  

					int firstOuttaGas1 = first_step_in_gas(eve, 1); // returns the step at which the particle escapes source foil and enters tracker
					int firstOuttaGas2 = first_step_in_gas(eve, 2); // the trackID should be the ones of primary tracks I guess?

					if( firstOuttaGas1 == -1 || firstOuttaGas2 == -1 ) // faker events (this happens when one of the emitted electrons is killed in foil
																	   // but the other one splits into two [ie. scattering] before escaping foil)
					{
						fakeItTillYouMakeItCounter++;
						cout << " AT EVENT " << e << "  firstOuttaGas1 = " << firstOuttaGas1 << " firstOuttaGas2 = " << firstOuttaGas2 << endl;
						continue;
					}

					p1Escaped = eve->getSD()->getvisuhitv()->at(firstOuttaGas1).getMomentumStart();  // This is implemented in MiModule by MP 
					p2Escaped = eve->getSD()->getvisuhitv()->at(firstOuttaGas2).getMomentumStart();  // Momentum is returned as TVector3

					p1XEscaped = p1Escaped.X();
					p1YEscaped = p1Escaped.Y();
					p1ZEscaped = p1Escaped.Z();
					x1Escaped  = eve->getSD()->getvisuhitv()->at(firstOuttaGas1).getStart()->getX();  
					y1Escaped  = eve->getSD()->getvisuhitv()->at(firstOuttaGas1).getStart()->getY();  
					z1Escaped  = eve->getSD()->getvisuhitv()->at(firstOuttaGas1).getStart()->getZ();  

					p2XEscaped = p2Escaped.X();
					p2YEscaped = p2Escaped.Y();
					p2ZEscaped = p2Escaped.Z();
					x2Escaped  = eve->getSD()->getvisuhitv()->at(firstOuttaGas2).getStart()->getX();  
					y2Escaped  = eve->getSD()->getvisuhitv()->at(firstOuttaGas2).getStart()->getY();  
					z2Escaped  = eve->getSD()->getvisuhitv()->at(firstOuttaGas2).getStart()->getZ();  

					theta = p1Emitted.Angle(p2Emitted)*180/TMath::Pi();  // Angle() returns in radians, conversion to degrees
					phi   = p1Escaped.Angle(p2Escaped)*180/TMath::Pi();

					tree->Fill();
				} 
			} 	
		}
	}
	////////////// Visualization
	/////////////////////////////////////////////////////////////
	cout << "fakeItTillYouMakeItCounter = " << fakeItTillYouMakeItCounter << endl;


	outFileAngularCorrelation->Write();
	outFileAngularCorrelation->Close();
}

