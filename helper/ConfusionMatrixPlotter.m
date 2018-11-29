classdef ConfusionMatrixPlotter < handle
    
    methods (Access = public)
        function plotConfusionMatrix(~, confmat,labels)
                        
            confmat(isnan(confmat))=0; % in case there are NaN elements
            numlabels = size(confmat, 1); % number of labels
            
            % calculate the percentage accuracies
            confpercent = 100*confmat./repmat(sum(confmat, 2)',numlabels,1)';
            
            % plotting the colors
            imagesc(confpercent);
            accuracy = 100*trace(confmat)/sum(confmat(:));
            title(sprintf('Accuracy: %.2f%%',accuracy));
            xlabel('Predicted Class'); ylabel('True Class');
            
            % set the colormap
            colormap(flipud(gray));
            
            % Create strings from the matrix values and remove spaces
            nanIdxs = isnan(confpercent);
            confpercent(nanIdxs) = 0;
            textStrings = num2str([confpercent(:), confmat(:)], '%.1f%%\n%d\n');
            textStrings = strtrim(cellstr(textStrings));
            %textStrings(nanIdxs) = '-';
            
            % Create x and y coordinates for the strings and plot them
            [x,y] = meshgrid(1:numlabels);
            hStrings = text(x(:),y(:),textStrings(:), 'HorizontalAlignment','center');
            set(hStrings, 'Clipping', 'on');
            
            % Get the middle value of the color range
            midValue = mean(get(gca,'CLim'));
            
            % Choose white or black for the text color of the strings
            textColors = repmat(confpercent(:) > midValue,1,3);
            set(hStrings,{'Color'},num2cell(textColors,2));
            
            % Setting the axis labels
            set(gca,'XTick',1:numlabels,...
                'XTickLabel',labels,...
                'YTick',1:numlabels,...
                'YTickLabel',labels,...
                'TickLength',[0 0]);
        end
    end
end