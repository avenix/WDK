classdef MatlabPeakDetector < EventDetector
    
    properties (Constant)            
        kBestPeakHeight = single(180);
        kBestMinPeakDistance = int32(400);
    end
    
    properties
        minPeakHeight;
        minPeakDistance;
    end
    
    methods  (Access = public)
        
        function obj = MatlabPeakDetector()
            obj.name = 'matlab';
            obj.resetVariables();
        end
        
        function resetVariables(obj)
            obj.minPeakHeight = MatlabPeakDetector.kBestPeakHeight;
            obj.minPeakDistance = MatlabPeakDetector.kBestMinPeakDistance;
        end
        
        function str = toString(obj)
            str = sprintf('%s%d%d',obj.name,obj.minPeakHeight,obj.minPeakDistance);
        end
        
        function computedSignal = compute(obj,signal)
            eventLocations = obj.detectEvents(signal);
            computedSignal = EventDetector.CreateEventsWithEventLocations(eventLocations);  
        end
        
        function editableProperties = getEditableProperties(obj)
            minPeakHeightProperty = Property('minPeakHeight',obj.minPeakHeight);
            minPeakDistanceProperty = Property('minPeakDistance',obj.minPeakDistance);
            editableProperties = [minPeakHeightProperty,minPeakDistanceProperty];
        end
        
        function peakLocations = detectEvents(obj,signal)
            [~,peakLocations] = findpeaks(signal,'MinPeakHeight',obj.minPeakHeight,'MinPeakDistance',obj.minPeakDistance);
            peakLocations = uint32(peakLocations);
        end
    end
end