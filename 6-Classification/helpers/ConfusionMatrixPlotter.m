classdef ConfusionMatrixPlotter < handle
    
    properties (Access  = private)
        plotAxes;
    end
    
    methods (Access = public)
        function obj = ConfusionMatrixPlotter(plotAxes)
            obj.plotAxes = plotAxes;
            axis(obj.plotAxes, 'tight');
        end
        
        function plotConfusionMatrix(obj, confusionMatrix, labels)
            confusionMatrixData = confusionMatrix.data;
            
            confusionMatrixData(isnan(confusionMatrixData)) = 0; % in case there are NaN elements
            numClasses = size(confusionMatrixData, 1); % number of classes
            
            % calculate the percentage accuracies
            confpercent = 100 * confusionMatrixData./repmat(sum(confusionMatrixData, 2)',numClasses,1)';
            
            % plotting the colors
            imagesc(obj.plotAxes,confpercent);
            
            title(obj.plotAxes,sprintf('Accuracy: %.2f%% Recall: %.2f%% Precision: %.2f%%',...
                100 * confusionMatrix.accuracy, 100 * confusionMatrix.recall,...
                100 * confusionMatrix.precision));
            
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
                'XTickLabel',labels,...
                'YTick',1:numClasses,...
                'YTickLabel',labels,...
                'TickLength',[0 0]);
            
        end
        
        function clearPlot(obj)
            cla(obj.plotAxes);
        end
    end
    
end