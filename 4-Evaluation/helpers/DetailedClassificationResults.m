classdef DetailedClassificationResults < handle
    properties (Access = public)
        fileName; 
        segments;
        predictedClasses;
        truthClasses;
    end
    
    methods (Access = public)
        function obj = DetailedClassificationResults()
        end
    end
end