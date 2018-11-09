classdef EventAnnotationsPlotter < handle
    
    properties (Access = public,Constant)
        AnnotationColor = 'blue';
    end
    
    properties (Access = public)
        delegate;
        annotationsMap;
    end
    
    properties (Access = private)
        classesMap;
    end
    
    methods (Access = public)
        function obj = EventAnnotationsPlotter(classesMap)
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
                peakX = eventAnnotation.sample;
                peakY = signal(peakX);
                peakClass = eventAnnotation.label;
                obj.addAnnotation(plotAxes,peakX,peakY,peakClass);
            end
        end
        
        function addAnnotation(obj, plotAxes, peakX, peakY, class)
            if ~obj.annotationsMap.isKey(peakX)
                eventAnnotation = EventAnnotation(peakX,class);
                [peakSymbolHandle,peakTextHandle] = obj.plotPeak(plotAxes,peakX,peakY,class);
                obj.annotationsMap(peakX) = DataAnnotatorPeakPlotHandle(eventAnnotation,peakSymbolHandle,peakTextHandle);
            end
        end
                   
        function modifyAnnotationToClass(obj,peakKey,class)
            if isKey(obj.annotationsMap,peakKey)
                
                annotation = obj.annotationsMap(peakKey);
                
                if annotation.annotation.label ~= class
                    color = obj.AnnotationColor;
                    
                    annotation.annotation.label = class;
                    annotation.peakSymbolUI.Color = color;
                    annotation.textSymbolUI.String = obj.classesMap.stringForClassAtIdx(class);
                end
            end
        end
        
        function deleteAnnotationAtSampleIdx(obj,peakTs)
            peakKey = uint32(peakTs);
            if obj.annotationsMap.isKey(peakKey)
                peakPlotHandle = obj.annotationsMap(peakKey);
                obj.deletePeakPlotHandle(peakPlotHandle);
                obj.annotationsMap.remove(peakKey);
            end
        end
        
        function clearAnnotations(obj)
            if ~isempty(obj.annotationsMap)
                peakPlotHandles = values(obj.annotationsMap);
                for i = 1 : length(peakPlotHandles)
                    peakPlotHandle = peakPlotHandles{i};
                    obj.deletePeakPlotHandle(peakPlotHandle);
                end
                remove(obj.annotationsMap, keys(obj.annotationsMap));
            end
        end
        
        function annotationsArray = getAnnotations(obj)
            annotationKeys = keys(obj.annotationsMap);
            nAnnotations = length(annotationKeys);
            annotationsArray = repmat(EventAnnotation,1,nAnnotations);
            
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
        
        %adds an object so the map knows it's storing these objects
        function initAnnotationsMap(obj)
            eventAnnotation = EventAnnotation(uint32(1),uint8(1));
            demoPeak = DataAnnotatorPeakPlotHandle(eventAnnotation,1,1);
            obj.annotationsMap = containers.Map(uint32(1),demoPeak);
            remove(obj.annotationsMap,1);
        end
        
        function [peakSymbolHandle,peakTextHandle] = plotPeak(obj, plotAxes, peakX, peakY, class)
            
            classStr = obj.classesMap.stringForClassAtIdx(class);
            color = obj.AnnotationColor;
            peakSymbolHandle = plot(plotAxes,peakX,peakY,'*','Color',color);
            peakTextHandle = text(plotAxes,double(peakX),double(peakY), classStr);
            set(peakTextHandle, 'Clipping', 'on');
            peakTextHandle.Tag = int2str(peakX);
            peakTextHandle.ButtonDownFcn = @obj.handleAnnotationClicked;
        end
        
        function deletePeakPlotHandle(~,peakPlotHandle)
            delete(peakPlotHandle.peakSymbolUI);
            delete(peakPlotHandle.textSymbolUI);
        end
    end
end

