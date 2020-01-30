% Stores the result of a regression algorithm
classdef RegressionResult < Data
    properties (Access = public)
        predictedResults;
        truthResults;
        timestamps;
    end
    
    methods (Access = public)
        function obj = RegressionResult(predictedResults,truthResults,timestamps)
            if nargin > 0
                obj.predictedResults = predictedResults;
                if nargin > 1
                    obj.truthResults = truthResults;
                    if nargin > 2
                        obj.timestamps = timestamps;
                    end
                end
                if isempty(obj.timestamps)
                    obj.timestamps = 1 : length(predictedResults);
                end
            end
            obj.type = DataType.kRegressionResult;
        end
    end
end