// Mi headers
#include "/pbs/home/m/mpetro/PROGRAMS/MiModule/include/MiEvent.h" 
#include "/pbs/home/m/mpetro/PROGRAMS/MiModule/include/MiSDVisuHit.h" 
#include "/pbs/home/m/mpetro/PROGRAMS/MiModule/include/MiFilters.h"

#include "TLatex.h"
#include "TVector3.h"


#include <string>
#include <iostream>
#include <sstream>
#include <algorithm>

R__LOAD_LIBRARY(/pbs/home/m/mpetro/PROGRAMS/MiModule/lib/libMiModule.so);

////////////// Function used in script
/////////////////////////////////////////////////////////////


TVector3* get_vertex_vector(MiEvent*  _eve, string _position, int _trackID) // returns the step position of the hit_step when it first enters tracking gas
{
	TVector3* vertexVector;
	if ( _position == "calo" )
	{
		for(int j = 0;j < _eve->getPTD()->getpart(_trackID)->getvertexv()->size();j++)
		{
			if(
				_eve->getPTD()->getpart(_trackID)->getvertex(j)->getpos() == "xcalo" || 
				_eve->getPTD()->getpart(_trackID)->getvertex(j)->getpos() == "calo"  ||
				_eve->getPTD()->getpart(_trackID)->getvertex(j)->getpos() == "gveto" 
			)
			{
				vertexVector = new TVector3(
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
				vertexVector = new TVector3(
					_eve->getPTD()->getpart(_trackID)->getvertex(j)->getr()->getX(),
					_eve->getPTD()->getpart(_trackID)->getvertex(j)->getr()->getY(),
					_eve->getPTD()->getpart(_trackID)->getvertex(j)->getr()->getZ()
				);
			}
		}
	}

	return vertexVector; //return -1 if the particle never left source foil (happens when we get "fakeItTillYouMakeIt events")
}


float get_distance(TVector3* v1, TVector3* v2)
{
	float xDifSquared = pow(v1->X() - v2->X(), 2);  // (x1 - x2)^2
	float yDifSquared = pow(v1->Y() - v2->Y(), 2);  // (y1 - y2)^2
	float zDifSquared = pow(v1->Z() - v2->Z(), 2);  // (z1 - z2)^2

	float distance = sqrt( xDifSquared + yDifSquared + zDifSquared );

	return distance; // sqrt( x^2 + y^2 + z^2 )
}

bool is_same_calo_gid(MiGID* cdGID,  MiGID* sdGID )
{
	if(
		cdGID->gettype() ==  sdGID->gettype() &&
		cdGID->getmodule() ==  sdGID->getmodule() &&
		cdGID->getside() ==  sdGID->getside() &&
		cdGID->getwall() ==  sdGID->getwall() &&
		cdGID->getcolumn() ==  sdGID->getcolumn() &&
		cdGID->getrow() ==  sdGID->getrow()
	)
	{
		return true;
	}
	return false;
}


////////////// MAIN BLOCK OF CODE
/////////////////////////////////////////////////////////////
void Job23()
{
////////////// Initialize File names/paths
/////////////////////////////////////////////////////////////
	const char* inFileName                 = "Default.root";													 //FOR TESTING PURPOSES USING ONLY FOLDER 0/
	const char* outPathAngularCorrelation  = "EnePhiDist_Job23.root";
	TFile* 	    outFileAngularCorrelation  = new TFile(outPathAngularCorrelation, "RECREATE");

	int nFiles = 1;

////////////// Initialize variables to be saved
/////////////////////////////////////////////////////////////
	float   phi, p1XEscaped, p1YEscaped, p1ZEscaped, p2XEscaped, p2YEscaped, p2ZEscaped;
	float   x1Reconstructed, y1Reconstructed, z1Reconstructed, x2Reconstructed, y2Reconstructed, z2Reconstructed;


	TVector3 p1Escaped;
	TVector3 p2Escaped;

	float   reconstructedEnergy1, reconstructedEnergy2;
	float   trackLength1, trackLength2;

////////////// Saving Data
/////////////////////////////////////////////////////////////
	TTree* tree 			= new TTree("tree","tree");

	tree->Branch("phi", &phi, "phi/F");

	tree->Branch("reconstructedEnergy1", &reconstructedEnergy1, "reconstructedEnergy1/F");
	tree->Branch("reconstructedEnergy2", &reconstructedEnergy2, "reconstructedEnergy2/F");

	tree->Branch("trackLength1", &trackLength1, "trackLength1/F");
	tree->Branch("trackLength2", &trackLength2, "trackLength2/F");

	tree->Branch("x1Reconstructed", &x1Reconstructed, "x1Reconstructed/F");
	tree->Branch("y1Reconstructed", &y1Reconstructed, "y1Reconstructed/F");
	tree->Branch("z1Reconstructed", &z1Reconstructed, "z1Reconstructed/F");
	tree->Branch("x2Reconstructed", &x2Reconstructed, "x2Reconstructed/F");
	tree->Branch("y2Reconstructed", &y2Reconstructed, "y2Reconstructed/F");
	tree->Branch("z2Reconstructed", &z2Reconstructed, "z2Reconstructed/F");


////////////// Initialize counters
/////////////////////////////////////////////////////////////
	int stepBeforeGas 				= -1;   // Represents the step just before exitting to the tracker gas volume
	int stepBeforeOM 				= -1;

	int nPassed = 0;
	double nPassedFraction = 0.0;

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

			s->SetBranchAddress("Eventdata", &eve);
			int nEntries = s->GetEntries();

	/////////////////////////////////////////////////////////////
			for (int e = 0; e < nEntries; ++e) 
			{ 	
				s->GetEntry(e);
					
				cout << " event number = " << e << endl;

				nPassed += 1;
				nPassedFraction += 1.0/double(nEntries);

				reconstructedEnergy1	= eve->getCD()->getcalohit(0)->getE();
				reconstructedEnergy2	= eve->getCD()->getcalohit(1)->getE();

				TVector3* r1Reconstructed = get_vertex_vector(eve, "source foil", 0);  	// position vector of the foil vertex
				TVector3* r2Reconstructed = get_vertex_vector(eve, "source foil", 1);
				TVector3* r1AtOM = get_vertex_vector(eve, "calo", 0);     			// position vector where electron hits OM. Tracklength is calculated as sqrt(r1Reconstructed^2 + r1AtOM^2)
				TVector3* r2AtOM = get_vertex_vector(eve, "calo", 1);  

				x1Reconstructed = r1Reconstructed->X();
				y1Reconstructed = r1Reconstructed->Y();
				z1Reconstructed = r1Reconstructed->Z();
				x2Reconstructed = r2Reconstructed->X();
				y2Reconstructed = r2Reconstructed->Y();
				z2Reconstructed = r2Reconstructed->Z();


				p1XEscaped = r1AtOM->X() - r1Reconstructed->X(); // x-coordinate of vector pointing in the direction of electron's travel
				p1YEscaped = r1AtOM->Y() - r1Reconstructed->Y();
				p1ZEscaped = r1AtOM->Z() - r1Reconstructed->Z();
				p2XEscaped = r2AtOM->X() - r2Reconstructed->X();
				p2YEscaped = r2AtOM->Y() - r2Reconstructed->Y();
				p2ZEscaped = r2AtOM->Z() - r2Reconstructed->Z();

				p1Escaped = TVector3(p1XEscaped, p1YEscaped, p1ZEscaped);  // This is implemented in MiModule by MP 
				p2Escaped = TVector3(p2XEscaped, p2YEscaped, p2ZEscaped);  // Momentum is returned as TVector3

				phi   = p1Escaped.Angle(p2Escaped)*180/TMath::Pi();

				trackLength1 = get_distance(r1Reconstructed, r1AtOM);
				trackLength2 = get_distance(r2Reconstructed, r2AtOM);

				tree->Fill();

			} 	
		}
	}
	// cout << "fakeItTillYouMakeItCounter = " << fakeItTillYouMakeItCounter << endl; // these events are skipped in the simulation 
	cout <<" nPassed = " << nPassed << endl;
	cout <<" nPassedFraction = " << nPassedFraction*100 << "%" << endl;

	outFileAngularCorrelation->Write();
	outFileAngularCorrelation->Close();
}

