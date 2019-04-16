classdef AnnotationRangeAnnotationsPlotter < handle
    
    properties (Access = public,Constant)
        AnnotationColor = 'black';
        LineWidth = 3;
        FontSize = 24;
        RectangleYPosToDataRatio = 1.025;
        LabelYPosToRectangleRatio = 1.05;
        RectangleCurvature = 0.1;
    end
    
    properties (Access = public)
        delegate;
        yRange;
        shouldShowAnnotations = true;
    end
    
    properties (Access = private)
        annotationsMap;
        classesMap;
    end
    
    methods
        function set.shouldShowAnnotations(obj,visible)
            obj.setAnnotationVisibility(visible);
            obj.shouldShowAnnotations = visible;
        end
    end
    
    methods (Access = public)
        function obj = AnnotationRangeAnnotationsPlotter(classesMap)
            if nargin > 0
                obj.classesMap = classesMap;
            else
                obj.classesMap = ClassesMap();
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
            
            classStr = obj.classesMap.stringForClassAtIdx(rangeAnnotation.label);
            
            rectangleHeight = (obj.yRange(2) - obj.yRange(1)) * obj.RectangleYPosToDataRatio;
            yOffset = (rectangleHeight - (obj.yRange(2) - obj.yRange(1))) / 2;
            rectangleWidth = single(rangeAnnotation.endSample - rangeAnnotation.startSample);
            rectanglePosition = [single(rangeAnnotation.startSample), obj.yRange(1) - yOffset, single(rectangleWidth), rectangleHeight];
            
            segmentRectangleHandle = rectangle('Position',rectanglePosition,'Curvature',[obj.RectangleCurvature obj.RectangleCurvature],'LineWidth',obj.LineWidth);

            xPos = (double(rangeAnnotation.startSample) + double(rangeAnnotation.endSample)) / 2;
            yPos = double(obj.yRange(2)) * obj.LabelYPosToRectangleRatio;
            
            segmentTextHandle = text(plotAxes,xPos,yPos, classStr,...
                'FontSize',obj.FontSize,'HorizontalAlignment','center');
            
            set(segmentTextHandle, 'Clipping', 'on');
            segmentTextHandle.Tag = int2str(rangeAnnotation.startSample);
            segmentTextHandle.ButtonDownFcn = @obj.handleAnnotationClicked;
            
            annotationHandle = AnnotationRangePlotHandle(rangeAnnotation,...
                segmentRectangleHandle,segmentTextHandle);
            
            obj.annotationsMap(rangeAnnotation.startSample) = annotationHandle;
        end
        
        function modifyAnnotationToClass(obj,key,class)
            if isKey(obj.annotationsMap,key)
                
                annotation = obj.annotationsMap(key);
                
                if annotation.annotation.label ~= class
                    annotation.annotation.label = class;
                    annotation.textSymbolUI.String = obj.classesMap.stringForClassAtIdx(class);
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