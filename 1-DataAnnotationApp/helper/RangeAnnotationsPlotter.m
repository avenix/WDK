classdef RangeAnnotationsPlotter < handle
    
    properties (Access = public,Constant)
        AnnotationColor = 'black';
        LineWidth = 3;
        SegmentHeight = 10;
        FontSize = 18;
        TextSegmentDistance = 10;
    end
    
    properties (Access = public)
        delegate;
    end
    
    properties (Access = private)
        annotationsMap;
        classesMap;
    end
    
    
    methods (Access = public)
        function obj = RangeAnnotationsPlotter(classesMap)
            if nargin > 0
                obj.classesMap = classesMap;
            else
                obj.classesMap = ClassesMap();
            end
            obj.initAnnotationsMap();
        end
        
        function plotAnnotations(obj, plotAxes, rangeAnnotations)
            %TODO
            for i = 1 : length(rangeAnnotations)
                rangeAnnotation = rangeAnnotations(i);
                obj.plotAnnotation(plotAxes,rangeAnnotation);
            end
        end
        
        function plotAnnotation(obj, plotAxes, rangeAnnotation)
            
            classStr = obj.classesMap.stringForClassAtIdx(rangeAnnotation.label);
            color = obj.AnnotationColor;
            
            segmentStartHandle = line(plotAxes,...
                [rangeAnnotation.startSample, rangeAnnotation.startSample],...
                [-obj.SegmentHeight/2 obj.SegmentHeight/2],'Color',color,'LineWidth',obj.LineWidth);
            
            segmentEndHandle = line(plotAxes,...
                [rangeAnnotation.endSample, rangeAnnotation.endSample],...
                [-obj.SegmentHeight/2 obj.SegmentHeight/2],'Color',color,'LineWidth',obj.LineWidth);
            
            segmentMainHandle = line(plotAxes,...
                [rangeAnnotation.startSample, rangeAnnotation.endSample],...
                [0 0],'Color',color,'LineWidth',obj.LineWidth);
            
            textPosition = floor(double(rangeAnnotation.startSample + rangeAnnotation.endSample)/2);
            segmentTextHandle = text(plotAxes,textPosition,-obj.TextSegmentDistance, classStr,'FontSize',obj.FontSize);
            
            set(segmentTextHandle, 'Clipping', 'on');
            segmentTextHandle.Tag = int2str(rangeAnnotation.startSample);
            segmentTextHandle.ButtonDownFcn = @obj.handleAnnotationClicked;
            
            annotationHandle = DataAnnotatorRangePlotHandle(rangeAnnotation,...
                segmentStartHandle,segmentEndHandle,segmentMainHandle,...
                segmentTextHandle);
            
            obj.annotationsMap(rangeAnnotation.startSample) = annotationHandle;
        end
        
        function modifyAnnotationToClass(obj,peakKey,class)
            if isKey(obj.annotationsMap,peakKey)
                
                annotation = obj.annotationsMap(peakKey);
                
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
            delete(annotationHandle.startSegmentUI);
            delete(annotationHandle.endSegmentUI);
            delete(annotationHandle.horizontalSegmentUI);
            delete(annotationHandle.textSymbolUI);
        end
        
        function annotationsArray = getAnnotations(obj)
            annotationKeys = keys(obj.annotationsMap);
            nAnnotations = length(annotationKeys);
            annotationsArray = repmat(RangeAnnotation,1,nAnnotations);
            
            for i = 1 : nAnnotations
                peakKey = annotationKeys{i};
                annotationHandle = obj.annotationsMap(peakKey);
                annotationsArray(i) = annotationHandle.annotation;
            end
        end
    end
    
    methods (Access = private)
        
        function handleAnnotationClicked(obj,source,target)
            obj.delegate.handleAnnotationClicked(source,target);
        end
        
        function initAnnotationsMap(obj)
            rangeAnnotation = RangeAnnotation(uint32(1),uint32(1),uint8(1));
            demoAnnotation = DataAnnotatorRangePlotHandle(rangeAnnotation,1,1,1,1);
            obj.annotationsMap = containers.Map(uint32(1),demoAnnotation);
            remove(obj.annotationsMap,1);
        end
    end
end