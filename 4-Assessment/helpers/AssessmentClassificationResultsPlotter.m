classdef AssessmentClassificationResultsPlotter < handle
    
    properties (Access = public, Constant)
        FontSize = 18;
        LineWidth = 2;
        MissedEventSymbolSize = 16;
        RectangleYPosToDataRatios = [1.0, 1.05];
        LabelYPosToRectangleRatios = [0.8,0.95];
        RectangleCurvature = 0.1;
    end
    
    properties (Access = public)
        yRange = [];
        missedEvents;
    end
    
    properties (Access = private)
        plotAxes;
        classNames;
        isUpperYPos = false;
    end
    
    methods (Access = public)
        function obj = AssessmentClassificationResultsPlotter(plotAxes,classNames)
            obj.plotAxes = plotAxes;
            obj.classNames = classNames;
        end
        
        function plotClassificationResults(obj, detailedClassificationResults, signal)
            
            nSegments = length(detailedClassificationResults.segments);
            for i = 1 : nSegments
                segment = detailedClassificationResults.segments(i);
                if ~isempty(segment.eventIdx)
                    y = signal(segment.eventIdx);
                else
                    y = [];
                end
                
                truthClass = detailedClassificationResults.classificationResult.truthClasses(i);
                predictedClass = detailedClassificationResults.classificationResult.predictedClasses(i);
                
                if truthClass ~= predictedClass || truthClass ~= ClassesMap.kNullClass
                    obj.plotClassificationResult(segment,y,truthClass,predictedClass);
                end
            end
            
            if ~isempty(obj.missedEvents)
                obj.plotMissedEventAnnotations(signal);
            end
        end
    end
    
    methods (Access = private)
        function plotHandle = plotClassificationResult(obj, segment, segmentEventY, truthClass, predictedClass)
            colorStr = obj.getColorForPrediction(truthClass,predictedClass);
            
            rectangleHeight = (obj.yRange(2) - obj.yRange(1)) * obj.RectangleYPosToDataRatios(obj.isUpperYPos+1);
            yOffset = (rectangleHeight - (obj.yRange(2) - obj.yRange(1))) / 2;
            rectangleWidth = single(segment.endSample - segment.startSample);
            rectanglePosition = [single(segment.startSample), obj.yRange(1) - yOffset, single(rectangleWidth), rectangleHeight];
            rectangleHandle = rectangle('Position',rectanglePosition,'Curvature',[obj.RectangleCurvature obj.RectangleCurvature],'LineWidth',obj.LineWidth, 'EdgeColor',colorStr);
            
            %plot text
            textStr = obj.getTextForPrediction(truthClass,predictedClass);
            xPos = (double(segment.startSample) + double(segment.endSample)) / 2;
            yPos = double(obj.yRange(2)) * obj.LabelYPosToRectangleRatios(obj.isUpperYPos+1);
            textHandle = text(obj.plotAxes,xPos,yPos, textStr,...
                'FontSize',obj.FontSize,'HorizontalAlignment','center','Color',colorStr);
            set(textHandle, 'Clipping', 'on');
            obj.isUpperYPos = ~obj.isUpperYPos;
            
            %plot symbol
            symbolHandle = [];
            if ~isempty(segmentEventY)
                x = segment.eventIdx;
                symbolHandle = plot(obj.plotAxes,x,segmentEventY,'*','Color',colorStr);
            end
            
            plotHandle = AssessmentClassificationResultPlotHandle(rectangleHandle, textHandle, symbolHandle);
        end
        
        function textStr = getTextForPrediction(obj,truthClass,predictedClass)
            predictedClassStr = Helper.StringForClass(predictedClass,obj.classNames);
            
            if truthClass ~= predictedClass
                truthClassStr = Helper.StringForClass(truthClass,obj.classNames);
                textStr = sprintf('%s\n (truth: %s)',predictedClassStr,truthClassStr);
            else
                textStr = predictedClassStr;
            end            
        end
        
        function colorStr = getColorForPrediction(~,truthClass,predictedClass)
            if truthClass == predictedClass
                colorStr = Constants.kCorrectColor;
            else
                colorStr = Constants.kWrongColor;
            end
        end
        
        function plotMissedEventAnnotations(obj,signal)
            for i = 1 : length(obj.missedEvents)
                missedEvent = obj.missedEvents(i);
                if missedEvent.label ~= ClassesMap.kNullClass
                    obj.plotMissedEventAnnotation(missedEvent,signal);
                end
            end
        end
        
        function plotMissedEventAnnotation(obj,event,signal)
            eventX = event.sample;
            eventY = signal(eventX);
            class = event.label;
            
            classStr = Helper.StringForClass(class,obj.classNames);
            
            plot(obj.plotAxes,eventX,eventY,'*','Color',Constants.kMissedEventColor,'LineWidth',AssessmentClassificationResultsPlotter.MissedEventSymbolSize);
            textHandle = text(obj.plotAxes,double(eventX),double(eventY), classStr,'FontSize',AssessmentClassificationResultsPlotter.FontSize);
            set(textHandle, 'Clipping', 'on');
        end
    end
end
