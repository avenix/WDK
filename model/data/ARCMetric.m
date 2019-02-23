classdef ARCMetric < handle
   properties (Access = public)
       goodEventRate = 0;
       badEventRate = 0;
   end
   
   methods (Access = public)
       function obj = ARCMetric(goodEventRate,badEventRate)
           if nargin > 0
               obj.goodEventRate = goodEventRate;
               obj.badEventRate = badEventRate;
           end
       end
   end
end