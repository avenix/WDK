classdef MatlabPeakDetector < Computer
    
    properties
        minPeakHeight = single(0.5);
        minPeakDistance = int32(400);
    end
    
    methods  (Access = public)
        
        function obj = MatlabPeakDetector()
            obj.name = 'matlabPeakDet';
            obj.inputPort = ComputerPort(ComputerPortType.kSignal);
            obj.outputPort = ComputerPort(ComputerPortType.kEvent);
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
             
        function metrics = computeMetrics(~,input)
            flops = size(input,1) * 10;
            memory = size(input,1);
            outputSize = 0;
            metrics = Metric(flops,memory,outputSize);
        end
    end
end