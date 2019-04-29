classdef AssessmentConfusionMatrixPlotter < handle
    
    properties (Access  = private)
        plotAxes;
    end
    
    methods (Access = public)
        function obj = AssessmentConfusionMatrixPlotter(plotAxes)
            obj.plotAxes = plotAxes;
            axis(obj.plotAxes, 'tight');
        end
        
        function plotConfusionMatrix(obj, confusionMatrix)
            confusionMatrixData = confusionMatrix.confusionMatrixData;
            
            confusionMatrixData(isnan(confusionMatrixData)) = 0; % in case there are NaN elements
            numClasses = size(confusionMatrixData, 1); % number of classes
            
            % calculate the percentage accuracies
            confpercent = 100 * confusionMatrixData./repmat(sum(confusionMatrixData, 2)',numClasses,1)';
            
            % plotting the colors
            imagesc(obj.plotAxes,confpercent);
            
            xlabel(obj.plotAxes,'Predicted Class');
            ylabel(obj.plotAxes,'True Class');
            
            % set the colormap
            colormap(obj.plotAxes,flipud(gray));
            
            % Create strings from the matrix values and remove spaces
            nanIdxs = isnan(confpercent);
            confpercent(nanIdxs) = 0;
            textStrings = num2str([confpercent(:), confusionMatrixData(:)], '%.1f%%\n%d\n');
            textStrings = strtrim(cellstr(textStrings));
            %textStrings(nanIdxs) = '-';
            
            % Create x and y coordinates for the strings and plot them
            [x,y] = meshgrid(1:numClasses);
            hStrings = text(obj.plotAxes,x(:),y(:),textStrings(:), 'HorizontalAlignment','center');
            set(hStrings, 'Clipping', 'on');
            
            % Get the middle value of the color range
            midValue = mean(get(obj.plotAxes,'CLim'));
            
            % Choose white or black for the text color of the strings
            textColors = repmat(confpercent(:) > midValue,1,3);
            set(hStrings,{'Color'},num2cell(textColors,2));
            
            % Setting the axis labels
            set(obj.plotAxes,'XTick',1:numClasses,...
                'XTickLabel',confusionMatrix.classNames,...
                'YTick',1:numClasses,...
                'YTickLabel',confusionMatrix.classNames,...
                'TickLength',[0 0]);
            
        end
        
        function clearPlot(obj)
            cla(obj.plotAxes);
        end
    end
    
end