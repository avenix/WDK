classdef AnnotationRangeAnnotationsPlotter < handle
    
    properties (Access = private,Constant)
        AnnotationColor = 'black';
        kAnnotationLineWidth = 3;
        FontSize = 20;
        RectangleCurvature = 0.1;
        
        AnnotationLabelStairsCount = 10;
        AnnotationLabelStairsYDiff = 0.05;
    end
    
    properties (Access = public)
        delegate;
        rectanglesYRange;
        shouldShowAnnotations = true;
    end
    
    properties (Access = private)
        annotationsMap;
        labeling;
        shouldPlotUpperYLabel = false;
        
        currentAnnotationLabelStairs = 1;
    end
    
    methods
        function set.shouldShowAnnotations(obj,visible)
            obj.setAnnotationVisibility(visible);
            obj.shouldShowAnnotations = visible;
        end
    end
    
    methods (Access = public)
        function obj = AnnotationRangeAnnotationsPlotter(labeling)
            if nargin > 0
                obj.labeling = labeling;
            end
            obj.initAnnotationsMap();
        end
        
        function plotAnnotations(obj, plotAxes, rangeAnnotations)
            for i = 1 : length(rangeAnnotations)
                rangeAnnotation = rangeAnnotations(i);
                obj.plotAnnotation(plotAxes,rangeAnnotation);
            end
            obj.setAnnotationVisibility(obj.shouldShowAnnotations);
        end
        
        function plotAnnotation(obj, plotAxes, rangeAnnotation)
            %plot rectangle
            rectangleHandle = obj.plotRectangle(plotAxes,rangeAnnotation);
            
            %plot label
            textHandle = obj.plotText(plotAxes,rangeAnnotation);
            
            annotationHandle = AnnotationRangePlotHandle(rangeAnnotation,...
                rectangleHandle,textHandle);
            
            obj.annotationsMap(rangeAnnotation.startSample) = annotationHandle;
        end
        
        function rectangleHandle = plotRectangle(obj,plotAxes,rangeAnnotation)
            rectangleHeight = obj.rectanglesYRange(2) - obj.rectanglesYRange(1);
            
            rectangleWidth = single(rangeAnnotation.endSample - rangeAnnotation.startSample);
            
            rectanglePosition = [single(rangeAnnotation.startSample), obj.rectanglesYRange(1),...
                single(rectangleWidth), single(rectangleHeight)];
            
            rectangleHandle = rectangle(plotAxes,'Position',rectanglePosition,'Curvature',...
                [obj.RectangleCurvature obj.RectangleCurvature],'LineWidth',obj.kAnnotationLineWidth);
        end
        
        function textHandle = plotText(obj,plotAxes, rangeAnnotation )
            classStr = obj.labeling.stringForClassAtIdx(rangeAnnotation.label);
            xPosition = (double(rangeAnnotation.startSample) + double(rangeAnnotation.endSample)) / 2;

            %compute y position
            rectangleHeight = obj.rectanglesYRange(2) - obj.rectanglesYRange(1);
            yPosition = obj.rectanglesYRange(1) + ...
                obj.currentAnnotationLabelStairs * AnnotationEventAnnotationsPlotter.AnnotationLabelStairsYDiff * rectangleHeight;
            
            %update label y position for next stair
            obj.currentAnnotationLabelStairs = obj.currentAnnotationLabelStairs + 1;
            if(obj.currentAnnotationLabelStairs > AnnotationEventAnnotationsPlotter.AnnotationLabelStairsCount)
                obj.currentAnnotationLabelStairs = 1;
            end
            
            %plot text label
            textHandle = text(plotAxes,xPosition,yPosition,classStr,...
                'FontSize',obj.FontSize,'HorizontalAlignment','center');
            set(textHandle, 'Clipping', 'on');
            textHandle.Tag = int2str(rangeAnnotation.startSample);
            textHandle.ButtonDownFcn = @obj.handleAnnotationClicked;
        end
        
        function modifyAnnotationToClass(obj,key,class)
            if isKey(obj.annotationsMap,key)
                
                annotation = obj.annotationsMap(key);
                
                if annotation.annotation.label ~= class
                    annotation.annotation.label = class;
                    annotation.textSymbolUI.String = obj.labeling.stringForClassAtIdx(class);
                end
            end
        end
        
        function deleteAnnotationAtSampleIdx(obj,startSample)
            annotationKey = uint32(startSample);
            if obj.annotationsMap.isKey(annotationKey)
                plotHandle = obj.annotationsMap(annotationKey);
                obj.deletePlotHandle(plotHandle);
                obj.annotationsMap.remove(annotationKey);
            end
        end
        
        function clearAnnotations(obj)
            
            plotHandles = values(obj.annotationsMap);
            for i = 1 : length(plotHandles)
                plotHandle = plotHandles{i};
                obj.deletePlotHandle(plotHandle);
            end
            remove(obj.annotationsMap, keys(obj.annotationsMap));
        end
        
        function deletePlotHandle(~,annotationHandle)
            delete(annotationHandle.rectangleUI);
            delete(annotationHandle.textSymbolUI);
        end
        
        function annotationsArray = getAnnotations(obj)
            annotationKeys = keys(obj.annotationsMap);
            nAnnotations = length(annotationKeys);
            annotationsArray = repmat(RangeAnnotation,1,nAnnotations);
            
            for i = 1 : nAnnotations
                key = annotationKeys{i};
                annotationHandle = obj.annotationsMap(key);
                annotationsArray(i) = annotationHandle.annotation;
            end
        end
        
        function setAnnotationVisibility(obj,visible)
            visibleStr = Helper.GetVisibleStr(visible);
            plotHandles = obj.annotationsMap.values;
            
            for i = 1 : length(plotHandles)
                plotHandle = plotHandles{i};
                plotHandle.visible = visibleStr;
            end
        end
        
    end
    
    methods (Access = private)
        
        function handleAnnotationClicked(obj,source,target)
            obj.delegate.handleAnnotationClicked(source,target);
        end
        
        function initAnnotationsMap(obj)
            rangeAnnotation = RangeAnnotation(uint32(1),uint32(1),uint8(1));
            demoAnnotation = AnnotationRangePlotHandle(rangeAnnotation,1,1);
            obj.annotationsMap = containers.Map(uint32(1),demoAnnotation);
            remove(obj.annotationsMap,1);
        end
    end
end