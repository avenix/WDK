classdef PreprocessingSegmentsPlotter < handle
    properties (Access = public)
        fontSize = 20;
        colorsPerSignal = {[0,0,1,0.3],[1,0,0,0.3],[1,0,1,0.3]};
        sameScale = true;
        sequentialSegments = false;
        showVerticalLines = true;
        plotParent;
    end
    
    properties(Access = private)
        axesHandles;
        verticalLines;
    end
    
    methods (Access = public)
        
        function obj = PreprocessingSegmentsPlotter(plotParent)
            obj.plotParent = plotParent;
        end
        
        function plotSegments(obj,groupedSegments,groupNames)
            obj.clearAxes();
            
            nClasses = length(groupedSegments);
            subplotM = ceil(sqrt(nClasses));
            subplotN = ceil(nClasses / subplotM);
            
            for i = 1 : nClasses
                obj.axesHandles(i) = subplot(subplotN,subplotM,i,'Parent',obj.plotParent);
                titleStr = groupNames{i};
                title(titleStr,'FontSize',obj.fontSize);
                hold on;
                segmentsCurrentGroup = groupedSegments{i};
                
                if(obj.sequentialSegments)
                    obj.plotSegmentsSequentially(segmentsCurrentGroup);
                else
                    obj.plotSegmentsOverlapping(segmentsCurrentGroup);
                end
                
                axis tight;
            end
            
            if obj.sameScale == 1
                linkaxes(obj.axesHandles,'xy');
            end
            
        end
        
        function clearAxes(obj)
            for i = 1 : length(obj.axesHandles)
                cla(obj.axesHandles(i));
            end
            obj.axesHandles = [];
            obj.verticalLines = [];
            %cla(obj.plotAxes);
        end
        
        function setShowLines(obj,showLines)
            obj.showVerticalLines = showLines;
            obj.updateLinesVisibility();
        end
    end
    
    methods (Access = private)
        
        function plotSegmentsOverlapping(obj,segments)
            for i = 1 : length(segments)
                segment = segments(i);
                data = segment.window;
                for signal = 1 : min(size(data,2),3)
                    plotHandle = plot(data(:,signal),'Color',obj.colorsPerSignal{signal},'LineWidth',0.4);
                    plotHandle.Color(4) = 0.4;
                end
            end
        end
        
        function plotSegmentsSequentially(obj,segments)
            currentX = 1;
            
            visibleStr = Helper.getOnOffStr(obj.showVerticalLines);
            
            nSegments = length(segments);
            
            obj.verticalLines = gobjects(nSegments);
            
            if (obj.showVerticalLines)
                maxY = obj.getMaxSegmentValue(segments);
                minY = obj.getMinSegmentValue(segments);
            end
                
            for i = 1 : nSegments
                segment = segments(i);
                data = segment.window;
                nSamples = size(data,1);
                newX = currentX + nSamples;
                
                for signal = 1 : min(size(data,2),3)
                    plot(currentX:newX-1,data(:,signal),'Color',obj.colorsPerSignal{signal},'LineWidth',0.4);
                end
                
                lineHandle = line([newX-1,newX-1],[minY,maxY],'Visible',visibleStr);
                obj.verticalLines(i) = lineHandle;
                
                currentX = newX;
            end
        end
        
        function maxValue = getMaxSegmentValue(~,segments)
            maxValue = 0;
            for i = 1 : length(segments)
                currentMax = max(max(segments(i).window));
                if(currentMax > maxValue)
                    maxValue = currentMax;
                end
            end
        end
        
        function minValue = getMinSegmentValue(~,segments)
            minValue = 0;
            for i = 1 : length(segments)
                currentMin = min(min(segments(i).window));
                if(currentMin > minValue)
                    minValue = currentMin;
                end
            end
        end
        
        function updateLinesVisibility(obj)
            visibleStr = Helper.getOnOffStr(obj.showVerticalLines);
            
            for i = 1 : length(obj.verticalLines)
                verticalLine = obj.verticalLines(i);
                verticalLine.Visible = visibleStr;
            end
        end
    end
    
end
