**********************************************************

To run the mRMR variable/feature selection for discrete 
variables, you need to add the path of mi_0.9 in your 
Matlab path. Then simply run mrmr_mid_d.m or mrmr_miq_d.m 
for your data.

If you have continuous data as input, you need to discretize 
the data first. Simple methods to do this can be thresholding 
at the mean or mean-plus/minus-std. Of course, you may also 
try the MI computation for continuous variables directly, as 
I showed in the my paper (below). However, typically the results 
are not as good as discrete variables.

Note that this version is old and uses double-precision 
in mutual information computation, thus the feature selection
results may be slightly different if you also compare the 
against those produced by the newer C versions downloadable
from our website. The C versions uses single precision for
floating numbers to save some memories.

The codes cannot be re-distributed without permission from 
the author, Hanchuan Peng. 

We hope you cite our work as follows, which you can download 
the paper at Hanchuan Peng's web site http://research.janelia.org/peng
(you may google and find out the latest website).

  Hanchuan Peng, Fuhui Long, and Chris Ding, "Feature selection 
  based on mutual information: criteria of max-dependency, 
  max-relevance, and min-redundancy," IEEE Transactions on 
  Pattern Analysis and Machine Intelligence, Vol. 27, No. 8, 
  pp.1226-1238, 2005.

Should you have any question, please send email to 
hanchuan.peng@gmail.com or pengh@janelia.hhmi.org .

**********************************************************

