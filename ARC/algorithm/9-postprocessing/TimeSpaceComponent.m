
classdef TimeSpaceComponent < Algorithm
    
    properties (Access = public)
        xLabel = 'Time (s)';
        yLabel = 'Class';
        plotTitle = 'Performance Comparison';
        colors = Constants.kUIColors;
        labels;
    end
    
    methods (Access = public)
        function obj = TimeSpaceComponent()
            obj.name = 'timeSpaceComponent';
            obj.inputPort = DataType.kAny;
            obj.outputPort = DataType.kAny;
        end
        
        %receives an array of instances of ClassificationResult
        function output = compute(obj,results)
            output = [];
            obj.plotHistory(results);
        end
        
        function plotComparison(obj,results)
            if ~isempty(results)
                result = results{1};
                if isa(result,'ClassificationResult')
                    obj.plotComparisonClassification(results);
                else
                    obj.plotComparisonRegression(results);
                end
            end
        end
        
        function plotComparisonClassification(obj,classificationResultSets)
            figure();
            hold on;
            for currentResultSet = 1 : length(classificationResultSets)
                classificationResults = classificationResultSets{currentResultSet};
                
                nResults = length(classificationResults);
                
                for i = 1 : nResults
                    classificationResult = classificationResults(i);
                    nClasses = length(classificationResult.classNames);
                    plot(classificationResult.table.timestamps,classificationResult.predictedClasses,'*','Color',obj.colors{currentResultSet});
                    yticks(0:nClasses);
                    yticklabels(classificationResult.classNames);
                    xlabel(obj.xLabel);
                    ylabel(obj.yLabel);
                    title(obj.plotTitle);
                    ylim([-1,nClasses]);
                end
                
            end
            if ~isempty(obj.labels)
                legend(obj.labels);
            end
        end
        
            function plotComparisonRegression(obj,classificationResultSets)
            figure();
            hold on;
            for currentResultSet = 1 : length(classificationResultSets)
                regressionResults = classificationResultSets{currentResultSet};
                
                nResults = length(regressionResults);
                
                for i = 1 : nResults
                    regressionResult = regressionResults(i);
                    plot(regressionResult.timestamps,regressionResult.predictedResults,'Color',obj.colors{currentResultSet},'LineWidth',3);
                    xlabel(obj.xLabel);
                    ylabel(obj.yLabel);
                    title(obj.plotTitle);
                end
                
            end
            
            legend(obj.labels,'Location','southeast');
        end
        
    end
    
end
