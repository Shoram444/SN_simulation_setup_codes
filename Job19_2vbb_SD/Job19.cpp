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
			_eve->getSD()->getvisuhitv()->at(step).getMaterial()      == "tracking_gas" 		 
		  )
		{
			return step;
		}
	}
	return -1; //return -1 if the particle never left source foil (happens when we get "fakeItTillYouMakeIt events")
}

////////////// MAIN BLOCK OF CODE
/////////////////////////////////////////////////////////////
void Job19()
{

////////////// Initialize File names/paths
/////////////////////////////////////////////////////////////
	const char* inFileName                 = "Default.root";													 //FOR TESTING PURPOSES USING ONLY FOLDER 0/
	const char* outPathAngularCorrelation  = "SimulatedEneTheta.root";
	TFile* 	    outFileAngularCorrelation  = new TFile(outPathAngularCorrelation, "RECREATE");

	int nFiles = 1;

////////////// Initialize variables to be saved
/////////////////////////////////////////////////////////////
	float_t   theta, p1XEmitted, p1YEmitted, p1ZEmitted, p2XEmitted, p2YEmitted, p2ZEmitted;

	TVector3 p1Emitted;
	TVector3 p2Emitted;

	float_t   simulatedEnergy1, simulatedEnergy2;

////////////// Saving Data
/////////////////////////////////////////////////////////////
	TTree* tree 			= new TTree("tree","tree");
	tree->Branch("theta", &theta, "theta/f");
	tree->Branch("p1XEmitted", &p1XEmitted, "p1XEmitted/f");
	tree->Branch("p1YEmitted", &p1YEmitted, "p1YEmitted/f");
	tree->Branch("p1ZEmitted", &p1ZEmitted, "p1ZEmitted/f");
	tree->Branch("p2XEmitted", &p2XEmitted, "p2XEmitted/f");
	tree->Branch("p2YEmitted", &p2YEmitted, "p2YEmitted/f");
	tree->Branch("p2ZEmitted", &p2ZEmitted, "p2ZEmitted/f");

	tree->Branch("simulatedEnergy1", &simulatedEnergy1, "simulatedEnergy1/f");
	tree->Branch("simulatedEnergy2", &simulatedEnergy2, "simulatedEnergy2/f");


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
				if(eve->getSD()->getpartv()->size() != 2 ) // precaution, that allways we have 2 particles + calohits
				{
					continue;
				} 

				p1XEmitted 		= eve->getSD()->getpart(0)->getp()->getX();
				p1YEmitted 		= eve->getSD()->getpart(0)->getp()->getY();
				p1ZEmitted 		= eve->getSD()->getpart(0)->getp()->getZ();

				p2XEmitted 		= eve->getSD()->getpart(1)->getp()->getX();
				p2YEmitted 		= eve->getSD()->getpart(1)->getp()->getY();
				p2ZEmitted 		= eve->getSD()->getpart(1)->getp()->getZ();
				
				simulatedEnergy1	= eve->getSD()->getpart(0)->getE();
				simulatedEnergy2	= eve->getSD()->getpart(1)->getE();


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


				theta = p1Emitted.Angle(p2Emitted)*180/TMath::Pi();  // Angle() returns in radians, conversion to degrees

				tree->Fill();
			} 	
		}
	}
	////////////// Visualization
	/////////////////////////////////////////////////////////////

	outFileAngularCorrelation->Write();
	outFileAngularCorrelation->Close();
}

