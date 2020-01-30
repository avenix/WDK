
classdef ComparisonComponent < Algorithm
    
    properties (Access = public)
        xLabel = 'Space';
        yLabel = 'Performance';
        plotTitle = 'Performance Comparison';
        labels;
        relevantResult;
    end
    
    methods (Access = public)
        function obj = ComparisonComponent(relevantResult)
            obj.relevantResult = relevantResult;
            obj.name = 'comparisonComponent';
            obj.inputPort = DataType.kRegressionResult;
            obj.outputPort = DataType.kAny;
        end
        
        %receives an array of instances of RegressionResults
        function output = compute(obj,results)
            output = [];
            obj.compare(results);
        end
        
        function compare(obj,results)
            obj.plotComparison(results);
            obj.printComparison(results);
        end
        
        function plotComparison(obj,regressionResults)
            
            nResults = length(regressionResults);
            
            for i = 1 : nResults
                figure();
                regressionResult = regressionResults(i);
                b = bar(obj.labels,regressionResult.predictedResults,'FaceColor','flat');

                xlabel(obj.xLabel);
                ylabel(obj.yLabel);
                title(obj.plotTitle);
                ylim([-1,101]);
                b.CData(obj.relevantResult,:) = Constants.kUIColors{1};
            end
        end
        
        
        function printComparison(obj,regressionResults)
            
            nResults = length(regressionResults);
            
            for i = 1 : nResults                
                regressionResult = regressionResults(i);
                performanceRate = regressionResult.predictedResults(1) / regressionResult.predictedResults(2) * 100;
                fprintf('%s achieves %.1f%% the performance of the %s\n',char(obj.labels(1)), performanceRate, char(obj.labels(2)));
            end
        end
    end
    
end
