classdef AnnotationEventAnnotationsPlotter < handle
    
    properties (Access = public,Constant)
        AnnotationColor = Constants.kUIColors{1};
        AnnotationFont = 20;
        AnnotationLabelStairsCount = 10;
        AnnotationLabelStairsYDiff = 0.05;
        AnnotationLineWidth = 3;
    end
    
    properties (Access = public)
        delegate;
        annotationsMap;
        shouldShowAnnotations = true;
        verticalLineYRange = [-1, 1];
    end
    
    properties (Access = private)
        labeling;
        currentLabelStairs = 1;
    end
    
    methods
        function set.shouldShowAnnotations(obj,visible)
            obj.setAnnotationVisibility(visible);
            obj.shouldShowAnnotations = visible;
        end
    end
    
    methods (Access = public)
        function obj = AnnotationEventAnnotationsPlotter(labeling)
            if nargin > 0
                obj.labeling = labeling;
            end
            obj.initAnnotationsMap();
        end
        
        function addAnnotations(obj, plotAxes, eventAnnotations)
            for i = 1 : length(eventAnnotations)
                eventAnnotation = eventAnnotations(i);
                x = eventAnnotation.sample;
                class = eventAnnotation.label;
                obj.addAnnotation(plotAxes,x,class);
            end
            obj.setAnnotationVisibility(obj.shouldShowAnnotations);
        end
        
        function didAddAnnotation = addAnnotation(obj, plotAxes, x, class)
            
            didAddAnnotation = false;
            
            if ~obj.annotationsMap.isKey(x)
                eventAnnotation = EventAnnotation(x,class);
                [symbolHandle,textHandle] = obj.plotLineAndLabel(plotAxes,x,class);
                obj.annotationsMap(x) = AnnotationEventPlotHandle(eventAnnotation,symbolHandle,textHandle);
                
                didAddAnnotation = true;
            end
        end
                   
        function didModifyAnnotation = modifyAnnotationToClass(obj,annotationKey,class)
            
            didModifyAnnotation = false;
            
            if isKey(obj.annotationsMap,annotationKey)
                
                annotation = obj.annotationsMap(annotationKey);
                
                if annotation.annotation.label ~= class
                    color = obj.AnnotationColor;
                    
                    annotation.annotation.label = class;
                    annotation.sampleSymbolUI.Color = color;
                    annotation.textSymbolUI.String = obj.labeling.stringForClassAtIdx(class);
                    
                    didModifyAnnotation = true;
                end
            end
        end
        
        function didDeleteAnnotation = deleteAnnotationAtSampleIdx(obj,sampleIdx)
            
            didDeleteAnnotation = false;
            
            key = uint32(sampleIdx);
            if obj.annotationsMap.isKey(key)
                plotHandle = obj.annotationsMap(key);
                obj.deletePlotHandle(plotHandle);
                obj.annotationsMap.remove(key);
                
                didDeleteAnnotation = true;
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
            demoPeak = AnnotationEventPlotHandle(eventAnnotation,1,1);
            obj.annotationsMap = containers.Map(uint32(1),demoPeak);
            remove(obj.annotationsMap,1);
        end
        
        function [symbolHandle,textHandle] = plotLineAndLabel(obj, plotAxes, x, class)
            
            classStr = obj.labeling.stringForClassAtIdx(class);
            
            %plot line
            symbolHandle = line(plotAxes,[x, x],[obj.verticalLineYRange(1),...
                obj.verticalLineYRange(2)],'LineWidth',obj.AnnotationLineWidth,'Color',obj.AnnotationColor);
            
            %compute label y position
            rangeDiff = obj.verticalLineYRange(2) - obj.verticalLineYRange(1);
            yPosition = obj.verticalLineYRange(2) - obj.currentLabelStairs * AnnotationEventAnnotationsPlotter.AnnotationLabelStairsYDiff * rangeDiff;
            
            %update label y position for next stair
            obj.currentLabelStairs = obj.currentLabelStairs + 1;
            if(obj.currentLabelStairs > AnnotationEventAnnotationsPlotter.AnnotationLabelStairsCount)
                obj.currentLabelStairs = 1;
            end
            
            textHandle = text(plotAxes,double(x),yPosition, classStr,...
                'FontSize',AnnotationEventAnnotationsPlotter.AnnotationFont,...
                'HorizontalAlignment','center','Color',obj.AnnotationColor);
            
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

