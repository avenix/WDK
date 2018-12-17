classdef DetectionTestbedEventsPlotter < handle
    
    properties (Access = public)
        labelingStrategy;
        textFontSize = 14;
        symbolColor;
    end
    
    methods (Access = public)
        function eventHandles = plotEvents(obj,plotAxes,events,signal)
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
                    symbolHandle = plot(plotAxes,eventX,eventY,'*','Color',obj.symbolColor);
                    textHandle = text(plotAxes,double(eventX),double(eventY), classStr,'FontSize',obj.textFontSize);
                    set(textHandle, 'Clipping', 'on');
                    
                    eventHandle = DetectionTestbedEventHandle(event,symbolHandle,textHandle);
                    eventHandles(i) = eventHandle;
                end
            end
        end
    end
end