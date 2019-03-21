classdef VisualizationSegmentsPlotter < handle
    properties (Access = public)
        fontSize = 24;
        colorsPerSignal = {[0,0,1,0.3],[1,0,0,0.3],[1,0,1,0.3]};
        paddingX = 80;
        lineColor = 'black';
        separatorLineFontSize = 20;
        
        sameScale = true;
        sequentialSegments = false;        
        plotParent;
    end
    
    properties(Access = private)
        axesHandles;
        plotAxes;
        isZoom = false;
        minSegmentValue;
        maxSegmentValue;
    end
    
    methods (Access = public)
        
        function obj = VisualizationSegmentsPlotter(plotParent)
            obj.plotParent = plotParent;
            obj.plotParent.AutoResizeChildren = 'off';
        end
        
        function setZoom(obj,b)
            str = Helper.getOnOffStringLowerCase(b);
            for i = 1 : length(obj.axesHandles)
                zoom(obj.axesHandles(i),str);
            end
            obj.isZoom = true;
        end
        
        function resetZoom(obj)
            str = Helper.getOnOffStringLowerCase(false);
            for i = 1 : length(obj.axesHandles)
                zoom(obj.axesHandles(i),str);
                obj.axesHandles(i).XLimMode = 'auto';
            end
            
            obj.setAxesLimits();
            
            if obj.isZoom
                obj.setZoom(obj.isZoom);
            end
        end
        
        function setPan(obj,b)
            str = Helper.getOnOffStringLowerCase(b);
            for i = 1 : length(obj.axesHandles)
                pan(obj.axesHandles(i),str);
            end
            obj.isZoom = false;
        end
        
        function plotSegments(obj,groupedSegments,groupNames)
            obj.clearAxes();
            
            nClasses = length(groupedSegments);
            subplotM = ceil(sqrt(nClasses));
            subplotN = ceil(nClasses / subplotM);
            obj.axesHandles = gobjects(1,nClasses);
            
            obj.findSegmentsLimits(groupedSegments);
            
            for i = 1 : nClasses
                currentAxes = subplot(subplotN,subplotM,i,'Parent',obj.plotParent);
                
                hold(currentAxes,'on');
                title(currentAxes,groupNames{i},'FontSize',obj.fontSize);
                
                segmentsCurrentGroup = groupedSegments{i};
                
                if(obj.sequentialSegments)
                    obj.plotSegmentsSequentially(currentAxes,segmentsCurrentGroup);
                else
                    obj.plotSegmentsOverlapping(currentAxes,segmentsCurrentGroup);
                end
                
                obj.axesHandles(i) = currentAxes;
            end
            
            obj.setAxesLimits();
            obj.updateLinkAxes();
            
            if obj.isZoom
                obj.setZoom(true);
            else
                obj.setPan(true);
            end
        end
        
        function setSameScale(obj,sameScaleParam)
            obj.sameScale = sameScaleParam;
            obj.updateLinkAxes();
        end
        
          
        function clearAxes(obj)
            for i = 1 : length(obj.axesHandles)
                delete(obj.axesHandles(i));
            end
            obj.axesHandles = [];
        end
    end
    
    methods (Access = private)
        
        function setAxesLimits(obj)
            
             height = obj.maxSegmentValue - obj.minSegmentValue;
            for i = 1 : length(obj.axesHandles)
                ylim(obj.axesHandles(i),[obj.minSegmentValue - height * 0.1, obj.maxSegmentValue + height * 0.1]);
            end
        end
        
        function findSegmentsLimits(obj, groupedSegments)
            obj.minSegmentValue = Inf;
            obj.maxSegmentValue = -Inf;
            for i = 1 : length(groupedSegments)
                segments = groupedSegments{i};
                obj.minSegmentValue = min(obj.minSegmentValue,obj.getMinSegmentValue(segments));
                obj.maxSegmentValue = max(obj.maxSegmentValue, obj.getMaxSegmentValue(segments));
            end
        end
        
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
                data = segment.data;
                for signal = 1 : min(size(data,2),3)
                    plotHandle = plot(plotAxes,data(:,signal),'Color',obj.colorsPerSignal{signal},'LineWidth',0.4);
                    plotHandle.Color(4) = 0.4;
                end
            end
        end
        
        function plotSegmentsSequentially(obj,plotAxes,segments)
            currentX = 1;

            nSegments = length(segments);
            lastFileName = '';
            
            for i = 1 : nSegments
                
                segment = segments(i);
                data = segment.data;
                nSamples = size(data,1);
                newX = currentX + nSamples;
                
                for signal = 1 : min(size(data,2),3)
                    plot(plotAxes,currentX:newX-1,data(:,signal),'Color',obj.colorsPerSignal{signal});
                end
                
                if ~strcmp(lastFileName,segment.file)
                                        
                    height = obj.maxSegmentValue - obj.minSegmentValue;

                    line(plotAxes,[currentX, currentX],...
                        [obj.minSegmentValue - 0.05 * height, obj.maxSegmentValue + 0.05 * height],...
                        'LineWidth',2,'Color',obj.lineColor);
                    
                    textHandle = text(plotAxes,currentX, double(obj.maxSegmentValue + 0.05 * height),...
                        segment.file,'FontSize',obj.separatorLineFontSize);
                    
                    set(textHandle, 'Clipping', 'on');
                    
                    lastFileName = segment.file;
                end
                
                currentX = newX + obj.paddingX;
            end
            
        end
        
        function maxValue = getMaxSegmentValue(~,segments)
            maxValue = 0;
            for i = 1 : length(segments)
                currentMax = max(max(segments(i).data));
                if(currentMax > maxValue)
                    maxValue = currentMax;
                end
            end
        end
        
        function minValue = getMinSegmentValue(~,segments)
            minValue = 0;
            for i = 1 : length(segments)
                currentMin = min(min(segments(i).data));
                if(currentMin < minValue)
                    minValue = currentMin;
                end
            end
        end
    end
    
end
