classdef Plotter
    
    properties (Access = public)
        fontSize = 26;
        figureFrame = [500, 500, 700, 700];
        lineWidth = 2;
        currentAxisLimits = 'tight';
    end
    
    methods (Access = public)

        function plotHandles = plotSegment(obj,axis,segment,yRange)
            plotHandles = zeros(1,2);
            
            plotHandles(1) = plot(axis,[segment.startSample segment.startSample],yRange,...
                'Color','black','LineStyle','--','LineWidth',obj.lineWidth);
            
            plotHandles(2) = plot(axis,[segment.endSample segment.endSample],yRange,...
                'Color','black','LineStyle','--','LineWidth',obj.lineWidth);
        end
        
        function plotLines(~,axis,segments,yRange)
            if nargin < 5
                yRange = 20;
            end
            
            hold(axis,'on');
            
            y = [zeros(1,length(segments)) ; ones(1,length(segments))*yRange];
            x = [segments; segments];
            plot(axis,x,y, 'Color','red','LineWidth',obj.lineWidth);
        end
        
        function plotPeaksInColors(~,peakLocations,peakValues,colors)
            for i = 1 : length(peakLocations)
                plot(peakLocations(i),peakValues(i),'*','Color',colors{i},'LineWidth',obj.lineWidth);
            end
        end
        
        function axis = plotPeaks(~,axis,peakLocations,peakValues,color)
            if nargin == 4
                color = 'green';
            end
            plot(axis, peakLocations,peakValues,'*','Color',color,'LineWidth',obj.lineWidth);
        end
        
        function plottedAxis = plotSignal(~,axis,signalX,signalY,color)
            if nargin == 4
                plottedAxis = plot(axis,signalX,signalY);
            elseif nargin == 5
                plottedAxis = plot(axis,signalX,signalY,'Color',color,'LineWidth',obj.lineWidth);
            end
        end
        
        function axis = plot2SignalsTogether(~,signal1,signal2)
            x = 1:length(signal1);
            axis = axes();
            plot(axis,x,signal1,'b',x,signal2,'r');
        end
        
        function plots = plot2SignalsSeparated(~,signal1,signal2)
            
            plots(1) = subplot(2,1,1);
            plot(signal1);
            plots(2) = subplot(2,1,2);
            plot(signal2);
            
            linkaxes(plots,'xy');
        end
        
        function plotHandle = plotSignalBigWithX(obj,x,signal,titleStr,xLabelStr,yLabelStr, frame)
            obj.openFigureWithFrame(frame);
            hold on;
            plotHandle = plot(x,signal,'Color', 'blue','LineWidth',3,'LineWidth',obj.lineWidth);
            obj.setAxisAndTitle(titleStr,xLabelStr,yLabelStr);
        end 
        
        function [figureHandle, plotHandles] = plotSignalBig(obj,signal,titleStr,xLabelStr,yLabelStr,color)
            figureHandle = obj.openDefaultFigure();
            figureAxes = figureHandle.CurrentAxes;

            hold on;
            x = (1 : length(signal));
            if nargin < 6
                color = {'blue'};
            end
            
            nColors = length(color);
            plotHandles = cell(1,nColors);
            for i = 1 : nColors
                plotHandles{i} = plot(figureAxes,x,signal(:,i),'Color', color{i},'LineWidth',obj.lineWidth);
            end
            
            obj.setAxisAndTitle(figureAxes,titleStr,xLabelStr,yLabelStr);
        end 
        
        %plots a signal in different colors. The segments are indicated in
        %the nSamplesPerGroup (array of the amount of samples per group)
        %colors contains a color per segment and labels a string per segment
        function plotDataGrouped(obj,signal,nSamplesPerGroup,colors,labels,titleStr,xLabelStr,yLabelStr)
            obj.openDefaultFigure();
            
            hold on;
            currentIdx = 1;
            nextIdx = 1;
            for i = 1 : length(nSamplesPerGroup)
                nextIdx = nextIdx + nSamplesPerGroup(i) - 1;
                x = (currentIdx : nextIdx);
                plot(x,signal(x),'Color',colors{i},'LineWidth',obj.lineWidth);
                currentIdx = nextIdx;
            end
            obj.setLegend(labels);

            xlabel(xLabelStr,'FontSize', obj.fontSize);
            ylabel(yLabelStr,'FontSize', obj.fontSize);
            title(titleStr,'FontSize', obj.fontSize);
            set(gca,'FontSize',obj.fontSize);
            axis tight;
        end
        
        function plotSpectrogram(obj,signal,titleStr,xLabelStr,yLabelStr)
            obj.openDefaultFigure();
            
            % Parameters
            frequencyLimits = [0 100]/pi; %Normalized frequency (*pi rad/sample)
            leakage = 0.2;
            overlapPercent = 50;
            
            pspectrum(signal, ...
                'spectrogram', ...
                'FrequencyLimits',frequencyLimits, ...
                'Leakage',leakage, ...
                'OverlapPercent',overlapPercent);
            
            obj.setAxisAndTitle(titleStr,xLabelStr,yLabelStr);
        end
        
        function setLegend(obj,labels)    
            [~,legendHandle] = legend(labels,'Location','Northeast','FontSize',obj.fontSize);
            legendLineHandle = findobj(legendHandle,'type','line');  % get the lines, not text
            set(legendLineHandle,'linewidth',6);
            %legendTextHandle = findobj(legendHandle,'type','text');
            %set(legendTextHandle,'FontSize',obj.fontSize);
        end
        
        function setAxisAndTitle(obj,figureAxes,titleStr,xLabelStr,yLabelStr)
            xlabel(figureAxes,xLabelStr,'FontSize', obj.fontSize);
            ylabel(figureAxes,yLabelStr,'FontSize', obj.fontSize);
            title(figureAxes,titleStr,'FontSize', obj.fontSize);
            set(figureAxes,'FontSize',obj.fontSize);
            axis(figureAxes,obj.currentAxisLimits);
        end
        
        function setAxisAndTitle3D(obj,figureAxes,titleStr,xLabelStr,yLabelStr,zLabelStr)
            xlabel(figureAxes,xLabelStr,'FontSize', obj.fontSize);
            ylabel(figureAxes,yLabelStr,'FontSize', obj.fontSize);
            zlabel(figureAxes,zLabelStr,'FontSize', obj.fontSize);
            title(figureAxes,titleStr,'FontSize', obj.fontSize);
            set(figureAxes,'FontSize',obj.fontSize);
            axis(figureAxes,obj.currentAxisLimits);
        end
        
        function figureHandle = openDefaultFigure(obj)
            figureHandle = figure('Position',obj.figureFrame);
            axes(figureHandle);
            obj.setDataCursorModeForFigure(figureHandle);
        end
        
        function openFigureWithFrame(obj,frame)
            figHandle = figure('Position',frame);
            obj.setDataCursorModeForFigure(figHandle);
        end
        
        function plotConfusionMatrix(~,confusionMatrix,labels)
            confmatPlotter = ConfusionMatrixPlotter();
            axis = axes();
            confmatPlotter.plotConfusionMatrix(axis,confusionMatrix,labels);
        end
        
        function savePlotAsPNG(~, fileName)
            print(fileName,'-dpng');
        end
        
        function plotHandle = plotSegmentArray(obj, segments,axisIdx,title)
            plotHandle = obj.openDefaultFigure();
            hold on;
            for i = 1: length(segments)
                segment = segments(i);
                p = plot(segment.window(:,axisIdx),'-','LineWidth',0.2,'Color','black');
                p.Color(4) = 0.10;
            end
            obj.setAxisAndTitle(title,'Samples','Acceleration [g]');
        end
    end
    
    methods (Access = private)
        function setDataCursorModeForFigure(obj, figureHandle)
            dataCursorMode = datacursormode(figureHandle);
            dataCursorMode.SnapToDataVertex = 'on';
            dataCursorMode.Enable = 'on';
            set(dataCursorMode,'UpdateFcn',@obj.handleUserClick);
        end
        
        function [outputTxt] = handleUserClick(~,src,~)
            pos = get(src,'Position');
            x = pos(1);
            y = pos(2);
            xStr = num2str(x,7);
            yStr = num2str(y,7);
            outputTxt = {['X: ',xStr],['Y: ',yStr]};
            fprintf('%d\n',x);
        end
    end
end