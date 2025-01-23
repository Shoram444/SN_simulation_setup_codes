// Mi headers
#include "/pbs/home/m/mpetro/PROGRAMS/MiModule/include/MiEvent.h" 
#include "TLatex.h"
#include "TMath.h"

R__LOAD_LIBRARY(/pbs/home/m/mpetro/PROGRAMS/MiModule/lib/libMiModule.so);

/////////////////////////////////////
//////////Function headers

double get_cosTheta(MiEvent*  eve);


/////////////////////////////////////
///////////Main

void Read_job11()
{
    const char* FNAME = "Default.root";

	TH1F*    hAngDist 	= new TH1F("h1", "Angular distribution; cos(theta); count", 50, -1, 1);
	TCanvas* cAngDist   = new TCanvas("c1","c1", 3200, 3200);

	TH2F*    hSpect 	= new TH2F("h2", "Energy SpectrumG0; E_1; E_2",35, 0, 3500, 35, 0, 3500);
	TCanvas* cSpectrum  = new TCanvas("c2","c2", 3200, 3200);


	if(gSystem->AccessPathName(FNAME))
	{
    	cout << "Default.root DOESNT EXIST - PATH: " << FNAME << endl;
    } 
    else 
    {
    	cout << "READING FILE : " << FNAME << endl;

    	TFile* 	   inFile 	= new TFile(FNAME);
		TTree* 		s 		= (TTree*) inFile->Get("Event");
		MiEvent*  eve 		= new MiEvent();
		s->SetBranchAddress("Eventdata", &eve);


    	for(UInt_t i=0; i < s->GetEntries(); i++)	// Loop over events 
		{
			s->GetEntry(i);
			
			double e1 		= eve->getSD()->getpart(0)->getE();
			double e2 		= eve->getSD()->getpart(1)->getE();
			double cosTheta = get_cosTheta(eve);

			hAngDist->Fill(cosTheta);
			hSpect->Fill(e1, e2);
		}	
	}

    TFile* outFileTh1 = new TFile("AngDist.root", "RECREATE");

    cAngDist->cd();
    hAngDist->Draw();
    hAngDist->Write();
	outFileTh1->Close();

    TFile* outFileTh2 = new TFile("Spectrum.root", "RECREATE");

    cSpectrum->cd();
    hSpect->Draw("COLZ");
    hSpect->Write();
    outFileTh2->Close();
}



double get_cosTheta(MiEvent*  eve)
{
	int    	numPart   = eve->getSD()->getpartv()->size();  // get number of particles in SD (should always be 2)

	double pMag1, pMag2;
	double px1, px2;
	double py1, py2;
	double pz1, pz2;

	for(UInt_t p=0; p < numPart; p++)
	{
		MiVector3D*   	particleMomentumVector = eve->getSD()->getpart(p)->getp();

		if(p == 0)
		{
			px1 = particleMomentumVector->getX();
			py1 = particleMomentumVector->getY();
			pz1 = particleMomentumVector->getZ();
			pMag1 = sqrt(px1*px1 + py1*py1 + pz1*pz1);

			px1 = px1/pMag1;
			py1 = py1/pMag1;
			pz1 = pz1/pMag1;
		}
		else
		{
			px2 = particleMomentumVector->getX();
			py2 = particleMomentumVector->getY();
			pz2 = particleMomentumVector->getZ();
			pMag2 = sqrt(px2*px2 + py2*py2 + pz2*pz2);

			px2 = px2/pMag2;
			py2 = py2/pMag2;
			pz2 = pz2/pMag2;	
		}
	}

	double cosTheta = px1*px2 + py1*py2 + pz1*pz2 ;

	return cosTheta ;
}


