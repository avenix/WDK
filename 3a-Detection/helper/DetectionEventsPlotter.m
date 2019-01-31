classdef DetectionEventsPlotter < handle
    
    properties (Access = private)
        plotAxes;
        detectedEventHandles;
        missedEventHandles;
        falsePositiveEventHandles;
    end
    
    properties (Access = public)
        labelingStrategy;
        textFontSize = 16;
    end
    
    properties (Access = private)
        showingDetectedEventsPrivate = true;
        showingMissedEventsPrivate = true;
        showingFalsePositiveEventsPrivate = true;
    end
    
    properties (Dependent)
        showingDetectedEvents;
        showingMissedEvents;
        showingFalsePositiveEvents;
    end
    
    methods
        
        function set.showingDetectedEvents(obj,value)
            obj.showingDetectedEventsPrivate = value;
            if ~isempty(obj.detectedEventHandles)
                obj.toggleEventsVisibility(obj.detectedEventHandles,value);
            end
        end
        
        function set.showingMissedEvents(obj,value)
            obj.showingMissedEventsPrivate = value;
            if ~isempty(obj.missedEventHandles)
                obj.toggleEventsVisibility(obj.missedEventHandles,value);
            end
        end
        
        function set.showingFalsePositiveEvents(obj,value)
            obj.showingFalsePositiveEventsPrivate = value;
            if ~isempty(obj.falsePositiveEventHandles)
                obj.toggleEventsVisibility(obj.falsePositiveEventHandles,value);
            end
        end
    end
    
    methods (Access = public)
        function obj = DetectionEventsPlotter(plotAxes)
            obj.plotAxes = plotAxes;
            hold(obj.plotAxes,'on');
        end
        
        function plotResults(obj,currentFileResults,signal)
            
            obj.clearPlot();
            
            plot(obj.plotAxes,signal);
            
            hold(obj.plotAxes,'on');
            
            obj.detectedEventHandles = obj.plotEvents(currentFileResults.goodEvents,signal,'green');
            obj.missedEventHandles = obj.plotEvents(currentFileResults.missedEvents,signal,[1,0.5,0]);
            obj.falsePositiveEventHandles = obj.plotEvents(currentFileResults.badEvents,signal,'red');
            
            if ~obj.showingDetectedEventsPrivate
                obj.toggleEventsVisibility(obj.detectedEventHandles,false);
            end
            
            if ~obj.showingMissedEventsPrivate
                obj.toggleEventsVisibility(obj.missedEventHandles,false);
            end
            
            if ~obj.showingFalsePositiveEventsPrivate
                obj.toggleEventsVisibility(obj.falsePositiveEventHandles,false);
            end
        end
        
        function clearPlot(obj)
            cla(obj.plotAxes);
            cla(obj.plotAxes,'reset');
        end
        
    end
    
    methods (Access = private)
        
        function eventHandles = plotEvents(obj,events,signal,symbolColor)
            eventHandles = [];
            nEvents = length(events);
            if nEvents > 0
                eventHandles = repmat(DetectionEventHandle(), 1, nEvents);
                for i = 1 : length(events)
                    event = events(i);
                    eventX = event.sample;
                    eventY = signal(eventX);
                    label = event.label;
                    if label == ClassesMap.kNullClass
                        classStr = Constants.kNullClassGroupStr;
                    else
                        classStr = obj.labelingStrategy.classNames{label};
                    end
                    
                    symbolHandle = plot(obj.plotAxes,eventX,eventY,'*','Color',symbolColor);
                    textHandle = text(obj.plotAxes,double(eventX),double(eventY), classStr,'FontSize',obj.textFontSize);
                    set(textHandle, 'Clipping', 'on');
                    
                    eventHandle = DetectionEventHandle(event,symbolHandle,textHandle);
                    eventHandles(i) = eventHandle;
                end
            end
        end
        
        function toggleEventsVisibility(~,eventHandles,visible)
            for i = 1 : length(eventHandles)
                eventHandle = eventHandles(i);
                eventHandle.setVisible(visible);
            end
        end
    end
    
end