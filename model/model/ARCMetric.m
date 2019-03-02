classdef ARCMetric < handle
   properties (Access = public)
       detectionf1Score;
   end
     
   methods (Access = public)
       function obj = ARCMetric(detectionf1Score)
           if nargin > 0
               obj.detectionf1Score = detectionf1Score;
           end
       end
   end
end