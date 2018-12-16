classdef PreprocessingSegmentsPlotter < handle
    properties (Access = public)
        fontSize = 20;
        plotsOffset = 0.04;
        colorsPerSignal = {[0,0,1,0.3],[1,0,0,0.3],[1,0,1,0.3]};
        sameScale = 1;
    end
    
    properties(Access = private)
        axesHandles;
    end
    
    methods (Access = public)
        
        function obj = PreprocessingSegmentsPlotter()
        end
        
        function plotSegments(obj,groupedSegments,groupNames)
            obj.clearAxes();
            
            nClasses = length(groupedSegments);
            subplotM = ceil(sqrt(nClasses));
            subplotN = ceil(nClasses / subplotM);
            
            for i = 1 : nClasses
                obj.axesHandles(i) = subplot(subplotN,subplotM,i);
                titleStr = groupNames{i};
                title(titleStr,'FontSize',obj.fontSize);
                hold on;
                segmentsCurrentGroup = groupedSegments{i};
                for j = 1 : length(segmentsCurrentGroup)
                    segment = segmentsCurrentGroup(j);
                    data = segment.window;
                    for signal = 1 : min(size(data,2),3)
                        plotHandle = plot(data(:,signal),'Color',obj.colorsPerSignal{signal},'LineWidth',0.4);
                        plotHandle.Color(4) = 0.4;
                    end
                end
                
                subplotAxes = obj.axesHandles(i);
                axesPosition = get(subplotAxes,'Position');
                axesPosition(1) = axesPosition(1) + 0.035;
                set(subplotAxes,'Position',axesPosition);
                axis tight;
                %set(obj.axesHandles(i),'style','tight');
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
            %cla(obj.plotAxes);
        end
        
        %{
function loadPlotAxes(obj)
            
            obj.plotAxes = axes(obj.uiHandles.figure1);
            obj.plotAxes.Units = 'characters';
            obj.plotAxes.Position  = [40.0 12 215 65];
            obj.plotAxes.Visible = 'Off';
                end
        %}
    end
end
