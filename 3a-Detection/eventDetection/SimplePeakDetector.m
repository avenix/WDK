classdef SimplePeakDetector < EventDetector
    
    properties (Constant)            
        kBestPeakHeight = single(160);
        kBestMinPeakDistance = int32(100);
    end
    
    properties
        minPeakHeight;
        minPeakDistance;
    end
    
    methods  (Access = public)
        
        function obj = SimplePeakDetector()
            obj.type = 'simplePeakDet';
            obj.resetVariables();
        end
        
        function resetVariables(obj)
            obj.minPeakHeight = SimplePeakDetector.kBestPeakHeight;
            obj.minPeakDistance = SimplePeakDetector.kBestMinPeakDistance;
        end
        
        function str = toString(obj)
            str = sprintf('%s%d%d',obj.type,obj.minPeakHeight,obj.minPeakDistance);
        end
        
        function editableProperties = getEditableProperties(obj)
            minPeakHeightProperty = Property('minPeakHeight',obj.minPeakHeight);
            minPeakDistanceProperty = Property('minPeakDistance',obj.minPeakDistance);
            editableProperties = [minPeakHeightProperty,minPeakDistanceProperty];
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