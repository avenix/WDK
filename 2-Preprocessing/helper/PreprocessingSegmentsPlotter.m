classdef PreprocessingSegmentsPlotter < handle
    properties (Access = public)
        fontSize = 20;
        colorsPerSignal = {[0,0,1,0.3],[1,0,0,0.3],[1,0,1,0.3]};
        lineColor = 'black';
        sameScale = true;
        sequentialSegments = false;
        showVerticalLines = true;
        plotParent;
    end
    
    properties(Access = private)
        axesHandles;
        verticalLines;
        plotAxes;
    end
    
    methods (Access = public)
        
        function obj = PreprocessingSegmentsPlotter(plotParent)
            obj.plotParent = plotParent;
            obj.plotParent.AutoResizeChildren = 'off';
        end
        
        function setZoom(obj,param)
            for i = 1 : length(obj.axesHandles)
                zoom(obj.axesHandles(i),param);
            end
        end
        
        function setPan(obj,param)
            for i = 1 : length(obj.axesHandles)
                pan(obj.axesHandles(i),param);
            end
        end
        
        function plotSegments(obj,groupedSegments,groupNames)
            obj.clearAxes();
            
            nClasses = length(groupedSegments);
            subplotM = ceil(sqrt(nClasses));
            subplotN = ceil(nClasses / subplotM);
            obj.axesHandles = gobjects(1,nClasses);
            
            if(obj.showVerticalLines)
                obj.verticalLines = cell(1,nClasses);
            end
                
            for i = 1 : nClasses
                currentAxes = subplot(subplotN,subplotM,i,'Parent',obj.plotParent);
                
                hold(currentAxes,'on');
                title(currentAxes,groupNames{i},'FontSize',obj.fontSize);
                
                segmentsCurrentGroup = groupedSegments{i};
                
                if(obj.sequentialSegments)
                    verticalLinesCurrentPlot = obj.plotSegmentsSequentially(currentAxes,segmentsCurrentGroup);
                    
                    if(obj.showVerticalLines)
                        obj.verticalLines{i} = verticalLinesCurrentPlot;
                    end
                else
                    obj.plotSegmentsOverlapping(currentAxes,segmentsCurrentGroup);
                end
                
                obj.axesHandles(i) = currentAxes;
            end
            
            obj.updateLinkAxes();
        end
        
        function setSameScale(obj,sameScaleParam)
            obj.sameScale = sameScaleParam;
            obj.updateLinkAxes();
        end
        
        function setShowLines(obj,showLines)
            obj.showVerticalLines = showLines;
            obj.updateLinesVisibility();
        end
          
        function clearAxes(obj)
            for i = 1 : length(obj.axesHandles)
                delete(obj.axesHandles(i));
            end
            
            obj.axesHandles = [];
            obj.verticalLines = [];
        end
    end
    
    methods (Access = private)
        
        function updateLinkAxes(obj)
            if ~isempty(obj.axesHandles)
                if obj.sameScale
                    linkaxes(obj.axesHandles,'xy');
                else
                    linkaxes(obj.axesHandles,'off');
                end
            end
        end
        
        function plotSegmentsOverlapping(obj,plotAxes,segments)
            for i = 1 : length(segments)
                segment = segments(i);
                data = segment.window;
                for signal = 1 : min(size(data,2),3)
                    plotHandle = plot(plotAxes,data(:,signal),'Color',obj.colorsPerSignal{signal},'LineWidth',0.4);
                    plotHandle.Color(4) = 0.4;
                end
            end
        end
        
        function verticalLinesCurrentPlot = plotSegmentsSequentially(obj,plotAxes,segments)
            currentX = 1;
            
            visibleStr = Helper.getOnOffString(obj.showVerticalLines);
            
            nSegments = length(segments);
                        
            verticalLinesCurrentPlot = gobjects(1,nSegments);
            
            maxY = obj.getMaxSegmentValue(segments);
            minY = obj.getMinSegmentValue(segments);
                
            for i = 1 : nSegments
                segment = segments(i);
                data = segment.window;
                nSamples = size(data,1);
                newX = currentX + nSamples;
                
                for signal = 1 : min(size(data,2),3)
                    plot(plotAxes,currentX:newX-1,data(:,signal),'Color',obj.colorsPerSignal{signal});
                end
                
                lineHandle = line(plotAxes,[newX-1,newX-1],[minY,maxY],'Visible',visibleStr,'Color',obj.lineColor,'LineStyle','--');
                verticalLinesCurrentPlot(i) = lineHandle;
                
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
                if(currentMin < minValue)
                    minValue = currentMin;
                end
            end
        end
        
        function updateLinesVisibility(obj)
            visibleStr = Helper.getOnOffString(obj.showVerticalLines);
            
            for i = 1 : length(obj.verticalLines)
                verticalLinesCurrentClass = obj.verticalLines{i};
                for j = 1 : length(verticalLinesCurrentClass)
                    verticalLine = verticalLinesCurrentClass(j);
                    verticalLine.Visible = visibleStr;
                end
            end
        end
    end
    
end
