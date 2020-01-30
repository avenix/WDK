
classdef HistoryComponent < Algorithm
    
    properties (Access = public)
        xLabel = 'Time (s)';
        yLabel = 'Class';
        plotTitle = 'History';
        classification
    end
    
    methods (Access = public)
        function obj = HistoryComponent()
            obj.name = 'historyComponent';
            obj.inputPort = DataType.kAny;
            obj.outputPort = DataType.kAny;
        end
        
        %receives an array of instances of ClassificationResult
        function output = compute(obj,results)
            output = [];
            obj.plotHistory(results);
        end
        
        function plotHistory(obj,results)
            if isa(results,'ClassificationResult')
                obj.plotHistoryClassification(results);
            else
                obj.plotHistoryRegression(results);
            end
        end
        
        function plotHistoryClassification(obj,classificationResults)
            nResults = length(classificationResults);
            
            for i = 1 : nResults
                
                figure();
                classificationResult = classificationResults(i);
                nClasses = length(classificationResult.classNames);
                plot(classificationResult.table.timestamps,classificationResult.predictedClasses,'*','LineWidth',3);
                yticks(0:nClasses);
                yticklabels(classificationResult.classNames);
                xlabel(obj.xLabel);
                ylabel(obj.yLabel);
                title(obj.plotTitle);
                ylim([-1,nClasses]);
                set(gca,'FontSize',22);
                
                figure();
                histogramClasses = categorical(classificationResult.classNames(classificationResult.predictedClasses+1));
                histogram(histogramClasses);
                xlabel(obj.yLabel);
                ylabel('Count');
                title(obj.plotTitle);
                set(gca,'FontSize',22);
            end
            
        end
        
        function plotHistoryRegression(obj,regressionResults)
            nResults = length(regressionResults);
            
            for i = 1 : nResults
                figure();
                regressionResult = regressionResults(i);
                plot(regressionResult.timestamps,regressionResult.predictedResults,'LineWidth',3);
                xlabel(obj.xLabel);
                ylabel(obj.yLabel);
                title(obj.plotTitle);
            end
        end
        
    end
    
end
