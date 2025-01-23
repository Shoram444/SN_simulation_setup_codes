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
int first_step_in_gas(MiEvent* _eve, int _trackID, int _eventNo) // returns the step position of the hit_step when it first enters tracking gas
{
	int last_in_foil = -1;
	bool is_in_gas = false;

	// find last step in foil
	for (int step = _eve->getSD()->getvisuhitv()->size()-1; step != 0 ; step--) 
	{
		if( 																					
			_eve->getSD()->getvisuhitv()->at(step).getTrackID() == _trackID &&
			_eve->getSD()->getvisuhitv()->at(step).getMaterial().substr(0, 2) == "bb" 		 
		 )
		{
			last_in_foil = step;
			break;
		}
	}

	// iterating over the steps of the simulation
	for (int step = 0; step < _eve->getSD()->getvisuhitv()->size() ; step++) 
	{

		if( // check whether the particle belongs to 1st track, is in gas, has left volume (source) and entered new vol (gas)																					
			_eve->getSD()->getvisuhitv()->at(step).getTrackID()    == _trackID        &&
			_eve->getSD()->getvisuhitv()->at(step).getMaterial()   == "tracking_gas" 		 
		 )
		{
			is_in_gas = true;
			last_in_foil = step;
			break;
		}
	}

	// sanity check
	if(!is_in_gas || last_in_foil == -1)
	{
		return -1;
	}

	//return next step, or -1 if failed
	return last_in_foil+1; 
}


TVector3 get_vertex_vector(MiEvent* _eve, string _position, int _trackID) // returns the step position of the hit_step when it first enters tracking gas
{
	TVector3 vertexVector;
	if ( _position == "calo" )
	{
		for(int j = 0;j < _eve->getPTD()->getpart(_trackID)->getvertexv()->size();j++)
		{
			if(
				_eve->getPTD()->getpart(_trackID)->getvertex(j)->getpos() == "xcalo" || 
				_eve->getPTD()->getpart(_trackID)->getvertex(j)->getpos() == "calo" ||
				_eve->getPTD()->getpart(_trackID)->getvertex(j)->getpos() == "gveto" 
			)
			{
				vertexVector = TVector3(
					_eve->getPTD()->getpart(_trackID)->getvertex(j)->getr()->getX(),
					_eve->getPTD()->getpart(_trackID)->getvertex(j)->getr()->getY(),
					_eve->getPTD()->getpart(_trackID)->getvertex(j)->getr()->getZ()
				);
			}
		}
	}
	else
	{
		for(int j = 0;j < _eve->getPTD()->getpart(_trackID)->getvertexv()->size();j++)
		{
			if(_eve->getPTD()->getpart(_trackID)->getvertex(j)->getpos() == _position)
			{
				vertexVector = TVector3(
					_eve->getPTD()->getpart(_trackID)->getvertex(j)->getr()->getX(),
					_eve->getPTD()->getpart(_trackID)->getvertex(j)->getr()->getY(),
					_eve->getPTD()->getpart(_trackID)->getvertex(j)->getr()->getZ()
				);
			}
		}
	}

	return vertexVector; //return -1 if the particle never left source foil (happens when we get "fakeItTillYouMakeIt events")
}


float_t get_distance(TVector3* v1, TVector3* v2)
{
	float_t xDifSquared = pow(v1->X() - v2->X(), 2); // (x1 - x2)^2
	float_t yDifSquared = pow(v1->Y() - v2->Y(), 2); // (y1 - y2)^2
	float_t zDifSquared = pow(v1->Z() - v2->Z(), 2); // (z1 - z2)^2

	float_t distance = sqrt( xDifSquared + yDifSquared + zDifSquared );

	return distance; // sqrt( x^2 + y^2 + z^2 )
}

bool is_same_calo_gid(MiGID* cdGID, MiGID* sdGID )
{
	if(
		cdGID->gettype() == sdGID->gettype() &&
		cdGID->getmodule() == sdGID->getmodule() &&
		cdGID->getside() == sdGID->getside() &&
		cdGID->getwall() == sdGID->getwall() &&
		cdGID->getcolumn() == sdGID->getcolumn() &&
		cdGID->getrow() == sdGID->getrow()
	)
	{
		return true;
	}
	return false;
}

float_t get_SD_energy(MiEvent* _eve, int _trackID)
{
	float_t	E = 0.0;
	for ( auto & SDCaloHit : *_eve->getSD()->getcalohitv() )
	{
		if( is_same_calo_gid(_eve->getCD()->getcalohit(_trackID)->getGID(), SDCaloHit.getGID() ) )
		{
			E	+= SDCaloHit.getE(); // there are sometimes multiple SD hits where one will be large and then a few very small (fraction of MeV)
		}
	}
	return E;
}


////////////// MAIN BLOCK OF CODE
/////////////////////////////////////////////////////////////
void Job33()
{
////////////// Initialize File names/paths
/////////////////////////////////////////////////////////////
	const char* inFileName         = "Default.root";													 //FOR TESTING PURPOSES USING ONLY FOLDER 0/
	const char* outPathAngularCorrelation = "efficiency.root";
	TFile* 	  outFileAngularCorrelation = new TFile(outPathAngularCorrelation, "RECREATE");

////////////// Initialize variables to be saved
/////////////////////////////////////////////////////////////

	// variables Simulated at Decay (SD)
	int nRecoTracks; // number of reconstructed tracks

	float_t  x1SD, y1SD, z1SD; 			// position
	float_t  px1SD, py1SD, pz1SD; 	// momentum		
	float_t  theta;

	// variables Simulated at Escape (SE)
	float_t  x1SE, y1SE, z1SE; 			// position
	float_t  px1SE, py1SE, pz1SE; 	// momentum		

	// variables Reconstructed at Escape (RE)
	float_t  x1RE, y1RE, z1RE; 			// position
	float_t  px1RE, py1RE, pz1RE; 		// momentum		
	float_t  phiRE;

	// Other
	float_t  recoEnergy1;
	float_t  simuEnergy1;

////////////// Initialize working variables NOT SAVED
/////////////////////////////////////////////////////////////

	TVector3 r1SD, r1SE, r1RE;  	// position vectors used in "Track length caclulation"
	TVector3 p1SD, p1SE;  				// momenutm vectors used in "Angle caclulation"
	TVector3 dir1RE; 						// direction of electrons escape from track reconstruction

////////////// Saving Data
/////////////////////////////////////////////////////////////
	TTree* tree = new TTree("tree","tree");

	// Simulated Decay
	tree->Branch("x1SD", &x1SD, "x1SD");
	tree->Branch("y1SD", &y1SD, "y1SD");
	tree->Branch("z1SD", &z1SD, "z1SD");

	tree->Branch("px1SD", &px1SD, "px1SD");
	tree->Branch("py1SD", &py1SD, "py1SD");
	tree->Branch("pz1SD", &pz1SD, "pz1SD");


	// Simulated Escape
	tree->Branch("x1SE", &x1SE, "x1SE");
	tree->Branch("y1SE", &y1SE, "y1SE");
	tree->Branch("z1SE", &z1SE, "z1SE");

	tree->Branch("px1SE", &px1SE, "px1SE");
	tree->Branch("py1SE", &py1SE, "py1SE");
	tree->Branch("pz1SE", &pz1SE, "pz1SE");

	// Reconstructed Escape
	tree->Branch("x1RE", &x1RE, "x1RE");
	tree->Branch("y1RE", &y1RE, "y1RE");
	tree->Branch("z1RE", &z1RE, "z1RE");

	tree->Branch("px1RE", &px1RE, "px1RE");
	tree->Branch("py1RE", &py1RE, "py1RE");
	tree->Branch("pz1RE", &pz1RE, "pz1RE");

	// Other
	tree->Branch("recoEnergy1", &recoEnergy1, "recoEnergy1");
	tree->Branch("simuEnergy1", &simuEnergy1, "simuEnergy1");

	tree->Branch("nRecoTracks", &nRecoTracks, "nRecoTracks/I");


////////////// Initialize counters
/////////////////////////////////////////////////////////////
	int stepBeforeGas 				= -1;  // Represents the step just before exitting to the tracker gas volume
	int stepBeforeOM 				= -1;

	int nPassed = 0;
	double nPassedFraction = 0.0;

	////////////// Loop over files
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
				
			nPassed += 1;
			nPassedFraction += 1.0/double(nEntries);

			/////////////////////////////////////////
			// Simulated Decay
			// Energy
			simuEnergy1 = get_SD_energy(eve, 0);

			// Position

			x1SD = eve->getSD()->getpart(0)->getr()->getX();
			y1SD = eve->getSD()->getpart(0)->getr()->getY();
			z1SD = eve->getSD()->getpart(0)->getr()->getZ();
			// momentum 

			px1SD = eve->getSD()->getpart(0)->getp()->getX();
			py1SD = eve->getSD()->getpart(0)->getp()->getY();
			pz1SD = eve->getSD()->getpart(0)->getp()->getZ();


			// Angle
			p1SD.SetXYZ(px1SD ,py1SD, pz1SD); 

			
			/////////////////////////////////////////
			// Simulated Escape
			// Energy
			recoEnergy1	= eve->getCD()->getcalohit(0)->getE();

			cout << "==========================" << endl;
			cout << "Event number: " << e 		 << endl;
			// Position
			int firstOuttaGas1 = first_step_in_gas(eve, 1, e); // returns the step at which the particle escapes source foil and enters tracker

			x1SE = eve->getSD()->getvisuhitv()->at(firstOuttaGas1).getStart()->getX(); 
			y1SE = eve->getSD()->getvisuhitv()->at(firstOuttaGas1).getStart()->getY(); 
			z1SE = eve->getSD()->getvisuhitv()->at(firstOuttaGas1).getStart()->getZ(); 
			

			// Momentum
			p1SE = eve->getSD()->getvisuhitv()->at(firstOuttaGas1).getMomentumStart(); // This is implemented in MiModule by MP 

			px1SE = p1SE.X(); 
			py1SE = p1SE.Y(); 
			pz1SE = p1SE.Z(); 

			// Reconstrcuted Escape 
			r1RE = get_vertex_vector(eve, "source foil", 0);

			x1RE = r1RE.X();
			y1RE = r1RE.Y();
			z1RE = r1RE.Z();

			// Angle
			dir1RE = eve->getPTD()->getpart(0)->getdirectionfromfoil();

			px1RE = dir1RE.X(); 
			py1RE = dir1RE.Y(); 
			pz1RE = dir1RE.Z(); 

			
			tree->Fill();
		} 	
	}

	// cout << "fakeItTillYouMakeItCounter = " << fakeItTillYouMakeItCounter << endl; // these events are skipped in the simulation 
	cout <<" nPassed = " << nPassed << endl;
	cout <<" nPassedFraction = " << nPassedFraction*100 << "%" << endl;

	outFileAngularCorrelation->Write();
	outFileAngularCorrelation->Close();
}

