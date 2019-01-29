classdef MatlabPeakDetector < Computer
    
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
            obj.inputPort = ComputerPort(ComputerPortType.kSignal,'nx1');
            obj.outputPort = ComputerPort(ComputerPortType.kSignal,'event');
        end
        
        function str = toString(obj)
            str = sprintf('%s%d%d',obj.name,obj.minPeakHeight,obj.minPeakDistance);
        end
        
        function computedSignal = compute(obj,signal)
            eventLocations = obj.detectEvents(signal);
            computedSignal = Helper.CreateEventsWithEventLocations(eventLocations);
        end
        
        function editableProperties = getEditableProperties(obj)
            minPeakHeightProperty = Property('minPeakHeight',obj.minPeakHeight,80,180);
            minPeakDistanceProperty = Property('minPeakDistance',obj.minPeakDistance,80,200);
            editableProperties = [minPeakHeightProperty,minPeakDistanceProperty];
        end
        
        function peakLocations = detectEvents(obj,signal)
            [~,peakLocations] = findpeaks(signal,'MinPeakHeight',obj.minPeakHeight,'MinPeakDistance',obj.minPeakDistance);
            peakLocations = uint32(peakLocations);
        end
    end
end