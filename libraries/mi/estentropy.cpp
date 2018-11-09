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
//calculate the entropy of a scalar variable 
//by Hanchuan Peng
//April/2002

#include "miinclude.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  if(nrhs!=1)
    mexErrMsgTxt("Usage [entropy] = progname(marginprob). .");
  if(nlhs > 1)
    mexErrMsgTxt("Too many output argument <entropy>.");

  double *pa = mxGetPr(prhs[0]);
  long totaln = (long)mxGetM(prhs[0])*mxGetN(prhs[0]);

  double sum = 0.0;
  double entropy = 0.0;
  for (long i=0;i<totaln;i++)
  {
    double curp = pa[i];
    if (curp<0) {printf("Negative Probability!! Wrong data.\n");}
    sum += curp;
    if (curp!=0) {entropy -= curp*log(curp);}
  }

  if (sum-1>1e-10)
  {
    printf("Dubious data! Sum is not 1.\n");
  }

  entropy /= log(2.0);

  plhs[0] = mxCreateDoubleMatrix(1,1, mxREAL);
  *mxGetPr(plhs[0]) = entropy;

  return;
}

