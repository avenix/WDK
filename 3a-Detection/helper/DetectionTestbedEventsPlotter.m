classdef DetectionTestbedEventsPlotter < handle
    
    properties (Access = public)
        labelingStrategy;
    end
    
    methods (Access = public)
        function eventHandles = plotEventsInColor(obj,plotAxes,events,color,signal)
            eventHandles = [];
            nEvents = length(events);
            if nEvents > 0
                eventHandles = repmat(DetectionTestbedEventHandle(), 1, nEvents);
                for i = 1 : length(events)
                    event = events(i);
                    eventX = event.sample;
                    eventY = signal(eventX);
                    label = event.label;
                    classStr = obj.labelingStrategy.classNames{label};
                    symbolHandle = plot(plotAxes,eventX,eventY,'*','Color',color);
                    textHandle = text(plotAxes,double(eventX),double(eventY), classStr);
                    set(textHandle, 'Clipping', 'on');
                    
                    eventHandle = DetectionTestbedEventHandle(event,symbolHandle,textHandle);
                    eventHandles(i) = eventHandle;
                end
            end
        end
    end
end