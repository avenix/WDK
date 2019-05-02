classdef AssessmentClassificationResultsPlotter < handle
    
    properties (Access = public, Constant)
        CorrectColor = 'green';
        WrongColor = 'red';
        MissedColor = 'orange';
        FontSize = 18;
        LineWidth = 2;
        RectangleYPosToDataRatio = 1.03;
        LabelYPosToRectangleRatios = [0.8,0.95];
        RectangleCurvature = 0.1;
    end
    
    properties (Access = public)
        yRange = [];
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
        end
    end
    
    methods (Access = private)
        function plotHandle = plotClassificationResult(obj, segment, segmentEventY, truthClass, predictedClass)
            colorStr = obj.getColorForPrediction(truthClass,predictedClass);
            
            rectangleHeight = (obj.yRange(2) - obj.yRange(1)) * obj.RectangleYPosToDataRatio;
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
                colorStr = AssessmentClassificationResultsPlotter.CorrectColor;
            else
                colorStr = AssessmentClassificationResultsPlotter.WrongColor;
            end
        end
    end
end
