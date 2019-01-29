classdef SimplePeakDetector < Computer
    
    properties (Constant)            
        kBestPeakHeight = single(160);
        kBestMinPeakDistance = int32(100);
    end
    
    properties (Access = public)
        minPeakHeight;
        minPeakDistance;
    end
    
    methods  (Access = public)
        
        function obj = SimplePeakDetector()
            obj.name = 'simplePeakDet';
            obj.inputPort = ComputerPort(ComputerPortType.kSignal,'nx1');
            obj.outputPort = ComputerPort(ComputerPortType.kSignal,'event');
        end
        
        function str = toString(obj)
            str = sprintf('%s%d%d',obj.name,obj.minPeakHeight,obj.minPeakDistance);
        end
        
        function editableProperties = getEditableProperties(obj)
            minPeakHeightProperty = Property('minPeakHeight',obj.minPeakHeight,80,180);
            minPeakDistanceProperty = Property('minPeakDistance',obj.minPeakDistance,80,200);
            editableProperties = [minPeakHeightProperty,minPeakDistanceProperty];
        end
        
        function computedSignal = compute(obj,signal)
            eventLocations = obj.detectEvents(signal);
            computedSignal = Helper.CreateEventsWithEventLocations(eventLocations);            
        end
        
        function peakLocations = detectEvents(obj,signal)
            
            WINDOW_SIZE = int32(501);

            signal = single(signal);
            lastPeakLocation = -1000;
            lastPeak = 0;
            
            peakLocations = uint32(zeros(1,floor(length(signal) / obj.minPeakDistance)));

            numPeaks = 0;
            for i = 1: WINDOW_SIZE : length(signal) - WINDOW_SIZE
                window = signal(i : i + WINDOW_SIZE - 1);

                [detectedPeakLocations, lastPeakLocation, lastPeak] = findPeakLocations(window,obj.minPeakHeight,obj.minPeakDistance,lastPeakLocation,lastPeak);
                
                for j = 1 : length(detectedPeakLocations)
                    numPeaks = numPeaks + 1;
                    peak = detectedPeakLocations(j);
                    peakLocations(numPeaks) = peak + int32(i) - 1;
                end

                lastPeakLocation = lastPeakLocation - int32(WINDOW_SIZE);
            end

            peakLocations = peakLocations(1:numPeaks);
        end
    end    
end