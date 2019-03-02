classdef DataAnnotationEventAnnotationsPlotter < handle
    
    properties (Access = public,Constant)
        AnnotationColor = 'red';
        AnnotationFont = 22;
    end
    
    properties (Access = public)
        delegate;
        annotationsMap;
    end
    
    properties (Access = private)
        classesMap;
    end
    
    methods (Access = public)
        function obj = DataAnnotationEventAnnotationsPlotter(classesMap)
            if nargin > 0
                obj.classesMap = classesMap;
            else
                obj.classesMap = ClassesMap();
            end
            obj.initAnnotationsMap();
        end
        
        function plotAnnotations(obj, plotAxes, eventAnnotations, signal)
            for i = 1 : length(eventAnnotations)
                eventAnnotation = eventAnnotations(i);
                x = eventAnnotation.sample;
                y = signal(x);
                class = eventAnnotation.label;
                obj.addAnnotation(plotAxes,x,y,class);
            end
        end
        
        function addAnnotation(obj, plotAxes, x, y, class)
            if ~obj.annotationsMap.isKey(x)
                eventAnnotation = EventAnnotation(x,class);
                [symbolHandle,textHandle] = obj.plotPeak(plotAxes,x,y,class);
                obj.annotationsMap(x) = DataAnnotationEventPlotHandle(eventAnnotation,symbolHandle,textHandle);
            end
        end
                   
        function modifyAnnotationToClass(obj,annotationKey,class)
            if isKey(obj.annotationsMap,annotationKey)
                
                annotation = obj.annotationsMap(annotationKey);
                
                if annotation.annotation.label ~= class
                    color = obj.AnnotationColor;
                    
                    annotation.annotation.label = class;
                    annotation.sampleSymbolUI.Color = color;
                    annotation.textSymbolUI.String = obj.classesMap.stringForClassAtIdx(class);
                end
            end
        end
        
        function deleteAnnotationAtSampleIdx(obj,sampleIdx)
            key = uint32(sampleIdx);
            if obj.annotationsMap.isKey(key)
                plotHandle = obj.annotationsMap(key);
                obj.deletePlotHandle(plotHandle);
                obj.annotationsMap.remove(key);
            end
        end
        
        function clearAnnotations(obj)
            if ~isempty(obj.annotationsMap)
                plotHandles = values(obj.annotationsMap);
                for i = 1 : length(plotHandles)
                    plotHandle = plotHandles{i};
                    obj.deletePlotHandle(plotHandle);
                end
                remove(obj.annotationsMap, keys(obj.annotationsMap));
            end
        end
        
        function annotationsArray = getAnnotations(obj)
            annotationKeys = keys(obj.annotationsMap);
            nAnnotations = length(annotationKeys);
            annotationsArray = repmat(EventAnnotation,1,nAnnotations);
            
            for i = 1 : nAnnotations
                key = annotationKeys{i};
                annotationHandle = obj.annotationsMap(key);
                annotationsArray(i) = annotationHandle.annotation;
            end
        end
        
        function setAnnotationVisibility(obj,visible)
            visibleStr = Helper.GetVisibleStr(visible);
            eventAnnotations = obj.annotationsMap.values;
            
            for i = 1 : length(eventAnnotations)
                eventAnnotation = eventAnnotations{i};
                eventAnnotation.visible = visibleStr;
            end
        end
    end
    
    methods (Access = private)
        
        function handleAnnotationClicked(obj,source,target)
            obj.delegate.handleAnnotationClicked(source,target);
        end
        
        %adds an object so the map knows it's storing these objects
        function initAnnotationsMap(obj)
            eventAnnotation = EventAnnotation(uint32(1),int8(1));
            demoPeak = DataAnnotationEventPlotHandle(eventAnnotation,1,1);
            obj.annotationsMap = containers.Map(uint32(1),demoPeak);
            remove(obj.annotationsMap,1);
        end
        
        function [symbolHandle,textHandle] = plotPeak(obj, plotAxes, x, y, class)
            
            classStr = obj.classesMap.stringForClassAtIdx(class);
            symbolHandle = plot(plotAxes,x,y,'*','Color',obj.AnnotationColor);
            
            textHandle = text(plotAxes,double(x),double(y), classStr,...
                'FontSize',DataAnnotationEventAnnotationsPlotter.AnnotationFont,...
                'Color',obj.AnnotationColor);
            
            set(textHandle, 'Clipping', 'on');
            textHandle.Tag = int2str(x);
            textHandle.ButtonDownFcn = @obj.handleAnnotationClicked;
        end
        
        function deletePlotHandle(~,plotHandle)
            delete(plotHandle.sampleSymbolUI);
            delete(plotHandle.textSymbolUI);
        end
    end
end

