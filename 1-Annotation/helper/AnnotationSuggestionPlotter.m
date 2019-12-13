classdef AnnotationSuggestionPlotter < handle
    
    properties (Access = private,Constant)
        kAnnotationColor = [200,200,200] / 255;
        kAnnotationLineWidth = 2;
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
        function obj = AnnotationSuggestionPlotter(labeling)
            if nargin > 0
                obj.labeling = labeling;
            end
            obj.initAnnotationsMap();
        end
        
        function addAnnotations(obj, plotAxes, rangeAnnotations)
            for i = 1 : length(rangeAnnotations)
                rangeAnnotation = rangeAnnotations(i);
                obj.addAnnotation(plotAxes,rangeAnnotation);
            end
            obj.setAnnotationVisibility(obj.shouldShowAnnotations);
        end

        function addAnnotation(obj, plotAxes, rangeAnnotation)
            %plot rectangle
            rectangleHandle = obj.plotRectangle(plotAxes,rangeAnnotation);
            
            %plot label
            textHandle = obj.plotText(plotAxes,rangeAnnotation);
            
            annotationHandle = AnnotationRangePlotHandle(rangeAnnotation,...
                rectangleHandle,textHandle);
            
            obj.annotationsMap(rangeAnnotation.startSample) = annotationHandle;
        end

        function didModifyAnnotation = modifyAnnotationToClass(obj,key,class)
            
            didModifyAnnotation = false;
            
            if isKey(obj.annotationsMap,key)
                
                annotation = obj.annotationsMap(key);
                
                if annotation.annotation.label ~= class
                    annotation.annotation.label = class;
                    annotation.textSymbolUI.String = obj.labeling.stringForClassAtIdx(class);
                    
                    didModifyAnnotation = true;
                end
            end
        end
        
        function didDeleteAnnotation = deleteAnnotationAtSampleIdx(obj,startSample)
            
            didDeleteAnnotation = false;
            
            annotationKey = uint32(startSample);
            if obj.annotationsMap.isKey(annotationKey)
                plotHandle = obj.annotationsMap(annotationKey);
                obj.deletePlotHandle(plotHandle);
                obj.annotationsMap.remove(annotationKey);
                
                didDeleteAnnotation = true;
            end
        end
        
        function annotations = getAnnotationsWithLabel(obj,label)
            
            values = obj.annotationsMap.values;
            
            nAnnotationsOfClass = obj.countAnnotationsWithLabel(label);
            
            annotations = repmat(RangeAnnotation,1,nAnnotationsOfClass);
            annotationCount = 1;
            
            for i = 1 : length(values)
                annotationHandle = values{i};
                annotation = annotationHandle.annotation;
                if annotation.label == label
                    annotations(annotationCount) = annotation;
                    annotationCount = annotationCount + 1;
                end
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

        
        function setAnnotationVisibility(obj,visible)
            visibleStr = Helper.GetOnOffString(visible);
            plotHandles = obj.annotationsMap.values;
            
            for i = 1 : length(plotHandles)
                plotHandle = plotHandles{i};
                plotHandle.visible = visibleStr;
            end
        end
        
        function annotation = getAnnotationWithKey(obj,key)
            if ~isKey(obj.annotationsMap,key)
                annotation = [];
            else
                annotationHandle = obj.annotationsMap(key);
                annotation = annotationHandle.annotation;
            end
        end
    end
    
    methods (Access = private)
        
        function count = countAnnotationsWithLabel(obj,label)
            count = 0;
            
            values = obj.annotationsMap.values;
            for i = 1 : length(values)
                annotationHandle = values{i};
                annotation = annotationHandle.annotation;
                if annotation.label == label
                    count = count + 1;
                end
            end
        end
        
        function deletePlotHandle(~,annotationHandle)
            delete(annotationHandle.rectangleUI);
            delete(annotationHandle.textSymbolUI);
        end
        
        function rectangleHandle = plotRectangle(obj,plotAxes,rangeAnnotation)
            rectangleHeight = obj.rectanglesYRange(2) - obj.rectanglesYRange(1);
            
            rectangleWidth = single(rangeAnnotation.endSample - rangeAnnotation.startSample);
            
            rectanglePosition = [single(rangeAnnotation.startSample), obj.rectanglesYRange(1),...
                single(rectangleWidth), single(rectangleHeight)];
            
            rectangleHandle = rectangle(plotAxes,'Position',rectanglePosition,'Curvature',...
                [obj.RectangleCurvature obj.RectangleCurvature],'LineWidth',obj.kAnnotationLineWidth,...
                'LineStyle','--','EdgeColor',AnnotationSuggestionPlotter.kAnnotationColor);
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
                'FontSize',obj.FontSize,'HorizontalAlignment','center',...
                'Color',AnnotationSuggestionPlotter.kAnnotationColor);
            
            set(textHandle, 'Clipping', 'on');
            textHandle.Tag = int2str(rangeAnnotation.startSample);
            textHandle.ButtonDownFcn = @obj.handleAnnotationClicked;
        end
        
        function handleAnnotationClicked(obj,source,target)
            if ~isempty(obj.delegate)
                obj.delegate.handleAnnotationClicked(source,target);
            end
        end
        
        function initAnnotationsMap(obj)
            rangeAnnotation = RangeAnnotation(uint32(1),uint32(1),uint8(1));
            demoAnnotation = AnnotationRangePlotHandle(rangeAnnotation,1,1);
            obj.annotationsMap = containers.Map(uint32(1),demoAnnotation);
            remove(obj.annotationsMap,1);
        end
    end
end