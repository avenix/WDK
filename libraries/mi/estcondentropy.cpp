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
//calculate the conditional entropy H(X|Y)
//refined by Hanchuan Peng
//April/2002

#include "miinclude.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  if(nrhs != 2 && nrhs!=1)
    mexErrMsgTxt("Usage [mutual_info] = progname(jointprob_table, marginprob_2). The last two inputs are optional.");
  if(nlhs > 1)
    mexErrMsgTxt("Too many output argument <mutual_info>.");

  //check if parameters are correct

  long i,j;

  double *pab = mxGetPr(prhs[0]);
  long pabhei = mxGetM(prhs[0]);
  long pabwid = mxGetN(prhs[0]);

  double *pb = mxGetPr(prhs[1]);
  long pblen =  mxGetM(prhs[1])*mxGetN(prhs[1]);

  if (pblen!=pabwid)
  {
    mexErrMsgTxt("Unmatched size: length of the second much be the same as the column of the first.");
  }

  double **pab2d = new double * [pabwid];
  for(j=0;j<pabwid;j++)
    pab2d[j] = pab + (long)j*pabhei;

  //calculate the conditional entropy

  double muInf = 0;
  
  muInf = 0.0;
  for (j=0;j<pabwid;j++) // should for pb
  {
    for (i=0;i<pabhei;i++) // should for pa
    {
      if (pab2d[j][i]!=0 && pb[j]!=0)
      {
	muInf += pab2d[j][i] * log(pb[j]/pab2d[j][i]);
// 	printf("%f %fab %fa %fb\n",muInf,pab2d[j][i]/p1[i]/p2[j],p1[i],p2[j]);
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
