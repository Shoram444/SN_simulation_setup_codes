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
void Job31()
{
////////////// Initialize File names/paths
/////////////////////////////////////////////////////////////
	const char* inFileName         = "Default.root";													 //FOR TESTING PURPOSES USING ONLY FOLDER 0/
	const char* outPathAngularCorrelation = "reco_data.root";
	TFile* 	  outFileAngularCorrelation = new TFile(outPathAngularCorrelation, "RECREATE");

////////////// Initialize variables to be saved
/////////////////////////////////////////////////////////////

	// variables Simulated at Decay (SD)
	float_t  x1SD, y1SD, z1SD, x2SD, y2SD, z2SD; 			// position
	float_t  px1SD, py1SD, pz1SD, px2SD, py2SD, pz2SD; 	// momentum		
	float_t  theta;

	// variables Simulated at Escape (SE)
	float_t  x1SE, y1SE, z1SE, x2SE, y2SE, z2SE; 			// position
	float_t  px1SE, py1SE, pz1SE, px2SE, py2SE, pz2SE; 	// momentum		
	float_t  phiSE;

	// variables Reconstructed at Escape (RE)
	float_t  x1RE, y1RE, z1RE, x2RE, y2RE, z2RE; 			// position
	float_t  px1RE, py1RE, pz1RE, px2RE, py2RE, pz2RE; 		// momentum		
	float_t  phiRE;

	// Other
	float_t  recoEnergy1, recoEnergy2;
	float_t  simuEnergy1, simuEnergy2;

////////////// Initialize working variables NOT SAVED
/////////////////////////////////////////////////////////////

	TVector3 r1SD, r2SD, r1SE, r2SE, r1RE, r2RE;  	// position vectors used in "Track length caclulation"
	TVector3 p1SD, p2SD, p1SE, p2SE;  				// momenutm vectors used in "Angle caclulation"
	TVector3 dir1RE, dir2RE; 						// direction of electrons escape from track reconstruction

////////////// Saving Data
/////////////////////////////////////////////////////////////
	TTree* tree = new TTree("tree","tree");

	// Simulated Decay
	tree->Branch("x1SD", &x1SD, "x1SD/f");
	tree->Branch("y1SD", &y1SD, "y1SD/f");
	tree->Branch("z1SD", &z1SD, "z1SD/f");
	tree->Branch("x2SD", &x2SD, "x2SD/f");
	tree->Branch("y2SD", &y2SD, "y2SD/f");
	tree->Branch("z2SD", &z2SD, "z2SD/f");

	tree->Branch("px1SD", &px1SD, "px1SD/f");
	tree->Branch("py1SD", &py1SD, "py1SD/f");
	tree->Branch("pz1SD", &pz1SD, "pz1SD/f");
	tree->Branch("px2SD", &px2SD, "px2SD/f");
	tree->Branch("py2SD", &py2SD, "py2SD/f");
	tree->Branch("pz2SD", &pz2SD, "pz2SD/f");

	tree->Branch("theta", &theta, "theta/f");

	// Simulated Escape
	tree->Branch("x1SE", &x1SE, "x1SE/f");
	tree->Branch("y1SE", &y1SE, "y1SE/f");
	tree->Branch("z1SE", &z1SE, "z1SE/f");
	tree->Branch("x2SE", &x2SE, "x2SE/f");
	tree->Branch("y2SE", &y2SE, "y2SE/f");
	tree->Branch("z2SE", &z2SE, "z2SE/f");

	tree->Branch("px1SE", &px1SE, "px1SE/f");
	tree->Branch("py1SE", &py1SE, "py1SE/f");
	tree->Branch("pz1SE", &pz1SE, "pz1SE/f");
	tree->Branch("px2SE", &px2SE, "px2SE/f");
	tree->Branch("py2SE", &py2SE, "py2SE/f");
	tree->Branch("pz2SE", &pz2SE, "pz2SE/f");

	tree->Branch("phiSE", &phiSE, "phiSE/f");

	// Reconstructed Escape
	tree->Branch("x1RE", &x1RE, "x1RE/f");
	tree->Branch("y1RE", &y1RE, "y1RE/f");
	tree->Branch("z1RE", &z1RE, "z1RE/f");
	tree->Branch("x2RE", &x2RE, "x2RE/f");
	tree->Branch("y2RE", &y2RE, "y2RE/f");
	tree->Branch("z2RE", &z2RE, "z2RE/f");

	tree->Branch("px1RE", &px1RE, "px1RE/f");
	tree->Branch("py1RE", &py1RE, "py1RE/f");
	tree->Branch("pz1RE", &pz1RE, "pz1RE/f");
	tree->Branch("px2RE", &px2RE, "px2RE/f");
	tree->Branch("py2RE", &py2RE, "py2RE/f");
	tree->Branch("pz2RE", &pz2RE, "pz2RE/f");

	tree->Branch("phiRE", &phiRE, "phiRE/f");

	// Other
	tree->Branch("recoEnergy1", &recoEnergy1, "recoEnergy1/f");
	tree->Branch("recoEnergy2", &recoEnergy2, "recoEnergy2/f");
	tree->Branch("simuEnergy1", &simuEnergy1, "simuEnergy1/f");
	tree->Branch("simuEnergy2", &simuEnergy2, "simuEnergy2/f");

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
			if(eve->getSD()->getpartv()->size() == 2)
			{
				// Energy
				simuEnergy1 = get_SD_energy(eve, 0);
				simuEnergy2 = get_SD_energy(eve, 1);

				// Position

				x1SD = eve->getSD()->getpart(0)->getr()->getX();
				y1SD = eve->getSD()->getpart(0)->getr()->getY();
				z1SD = eve->getSD()->getpart(0)->getr()->getZ();
				x2SD = eve->getSD()->getpart(1)->getr()->getX();
				y2SD = eve->getSD()->getpart(1)->getr()->getY();
				z2SD = eve->getSD()->getpart(1)->getr()->getZ();
				// momentum 

				px1SD = eve->getSD()->getpart(0)->getp()->getX();
				py1SD = eve->getSD()->getpart(0)->getp()->getY();
				pz1SD = eve->getSD()->getpart(0)->getp()->getZ();
				px2SD = eve->getSD()->getpart(1)->getp()->getX();
				py2SD = eve->getSD()->getpart(1)->getp()->getY();
				pz2SD = eve->getSD()->getpart(1)->getp()->getZ();


				// Angle
				p1SD.SetXYZ(px1SD ,py1SD, pz1SD); 
				p2SD.SetXYZ(px2SD ,py2SD, pz2SD); 

				theta = p1SD.Angle(p2SD)*180/TMath::Pi();
			}

			
			/////////////////////////////////////////
			// Simulated Escape
			if ( eve->getCD()->getnoofcaloh() == 2 )  
			{

				// Energy
				recoEnergy1	= eve->getCD()->getcalohit(0)->getE();
				recoEnergy2	= eve->getCD()->getcalohit(1)->getE();

				cout << "==========================" << endl;
				cout << "Event number: " << e 		 << endl;
				// Position
				int firstOuttaGas1 = first_step_in_gas(eve, 1, e); // returns the step at which the particle escapes source foil and enters tracker
				int firstOuttaGas2 = first_step_in_gas(eve, 2, e); // the trackID should be the ones of primary tracks I guess?

				if( firstOuttaGas1 == -1 || firstOuttaGas2 == -1 ) // this sucks, but we lose the particle 
				{
					x1SE = 0.0; 
					y1SE = 0.0; 
					z1SE = 0.0; 
					x2SE = 0.0; 
					y2SE = 0.0; 
					z2SE = 0.0;
 
					px1SE = 0.0;
					py1SE = 0.0;
					pz1SE = 0.0;
					px2SE = 0.0;
					py2SE = 0.0;
					pz2SE = 0.0;
 
					phiSE = 0.0;
				} 
				else
				{
					x1SE = eve->getSD()->getvisuhitv()->at(firstOuttaGas1).getStart()->getX(); 
					y1SE = eve->getSD()->getvisuhitv()->at(firstOuttaGas1).getStart()->getY(); 
					z1SE = eve->getSD()->getvisuhitv()->at(firstOuttaGas1).getStart()->getZ(); 
					x2SE = eve->getSD()->getvisuhitv()->at(firstOuttaGas2).getStart()->getX(); 
					y2SE = eve->getSD()->getvisuhitv()->at(firstOuttaGas2).getStart()->getY(); 
					z2SE = eve->getSD()->getvisuhitv()->at(firstOuttaGas2).getStart()->getZ(); 

					// Momentum
					p1SE = eve->getSD()->getvisuhitv()->at(firstOuttaGas1).getMomentumStart(); // This is implemented in MiModule by MP 
					p2SE = eve->getSD()->getvisuhitv()->at(firstOuttaGas2).getMomentumStart(); // Momentum is returned as TVector3

					px1SE = p1SE.X(); 
					py1SE = p1SE.Y(); 
					pz1SE = p1SE.Z(); 
					px2SE = p2SE.X(); 
					py2SE = p2SE.Y(); 
					pz2SE = p2SE.Z(); 

					// Angle
					phiSE = p1SE.Angle(p2SE)*180/TMath::Pi();
				}
			}

			cout <<"ID 1 SD X = " << x1SD << " | SE = " << x1SE << endl;
			cout <<"ID 2 SD X = " << x2SD << " | SE = " << x2SE << endl;

			// Reconstrcuted Escape 
			if(eve->getPTD()->getpartv()->size() == 2)
			{
				// Position
				r1RE = get_vertex_vector(eve, "source foil", 0);
				r2RE = get_vertex_vector(eve, "source foil", 1);

				x1RE = r1RE.X();
				y1RE = r1RE.Y();
				z1RE = r1RE.Z();
				x2RE = r2RE.X();
				y2RE = r2RE.Y();
				z2RE = r2RE.Z();

				// Angle
				dir1RE = eve->getPTD()->getpart(0)->getdirectionfromfoil();
				dir2RE = eve->getPTD()->getpart(1)->getdirectionfromfoil();

				px1RE = dir1RE.X(); 
				py1RE = dir1RE.Y(); 
				pz1RE = dir1RE.Z(); 
				px2RE = dir2RE.X(); 
				py2RE = dir2RE.Y(); 
				pz2RE = dir2RE.Z(); 

				phiRE = dir1RE.Angle(dir2RE)*180/TMath::Pi();
			}

			tree->Fill();

		} 	
	}

	// cout << "fakeItTillYouMakeItCounter = " << fakeItTillYouMakeItCounter << endl; // these events are skipped in the simulation 
	cout <<" nPassed = " << nPassed << endl;
	cout <<" nPassedFraction = " << nPassedFraction*100 << "%" << endl;

	outFileAngularCorrelation->Write();
	outFileAngularCorrelation->Close();
}

