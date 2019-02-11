//=========================================================
//
//This is a prog in the MutualInfo 0.9 package written by
// Hanchuan Peng.
//
//Disclaimer: The author of program is Hanchuan Peng
//      at <penghanchuan@yahoo.com> and <phc@cbmv.jhu.edu>.
//
//The CopyRight is reserved by the author.
//
//Last modification: April/19/2002
//
//========================================================
//
//calculate the joint entropy H(X,Y)
//by Hanchuan Peng
//April/2002

#include "miinclude.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  if(nrhs!=1)
    mexErrMsgTxt("Usage [jointentropy] = progname(jointprob_table).");
  if(nlhs > 1)
    mexErrMsgTxt("Too many output argument <jointentropy>.");

  //check if parameters are correct

  long i,j;

  double *pab = mxGetPr(prhs[0]);
  long pabhei = mxGetM(prhs[0]);
  long pabwid = mxGetN(prhs[0]);

  double **pab2d = new double * [pabwid];
  for(j=0;j<pabwid;j++)
    pab2d[j] = pab + (long)j*pabhei;

  //calculate the joint entropy

  double muInf = 0;
  
  muInf = 0.0;
  for (j=0;j<pabwid;j++) // should for pb
  {
    for (i=0;i<pabhei;i++) // should for pa
    {
      if (pab2d[j][i]>0) //!=0
      {
	muInf -= pab2d[j][i] * log(pab2d[j][i]);
      }
    }
  }

  muInf /= log(2.0);

  plhs[0] = mxCreateDoubleMatrix(1,1, mxREAL);
  *mxGetPr(plhs[0]) = muInf;

  //free memory
  if(pab2d){delete []pab2d;}

  return;
}
