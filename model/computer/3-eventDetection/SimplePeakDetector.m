classdef SimplePeakDetector < Computer
    
    properties (Access = public)
        minPeakHeight = single(160);
        minPeakDistance  = int32(100);
    end
    
    methods  (Access = public)
        
        function obj = SimplePeakDetector()
            obj.name = 'simplePeakDet';
            obj.inputPort = ComputerPort(ComputerPortType.kSignal,ComputerSizeType.kN);
            obj.outputPort = ComputerPort(ComputerPortType.kEvent);
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
        
    end
    
    methods (Access = private)
        function peakLocations = detectEvents(obj,signal)
            
            WINDOW_SIZE = int32(501);
            
            signal = single(signal);
            lastPeakLocation = -1000;
            lastPeak = 0;
            
            peakLocations = uint32(zeros(1,floor(length(signal) / obj.minPeakDistance)));
            
            %iterates block by block to simulate the processing on a device
            %with limited memory
            numPeaks = 0;
            for i = 1: WINDOW_SIZE : length(signal) - WINDOW_SIZE
                window = signal(i : i + WINDOW_SIZE - 1);
                
                [detectedPeakLocations, lastPeakLocation, lastPeak] = obj.findPeakLocations(window,obj.minPeakHeight,obj.minPeakDistance,lastPeakLocation,lastPeak);
                
                for j = 1 : length(detectedPeakLocations)
                    numPeaks = numPeaks + 1;
                    peak = detectedPeakLocations(j);
                    peakLocations(numPeaks) = peak + int32(i) - 1;
                end
                
                lastPeakLocation = lastPeakLocation - int32(WINDOW_SIZE);
            end
            
            peakLocations = peakLocations(1:numPeaks);
        end
        
        function [peakLocations, lastPeakLocation, lastPeakValue] = findPeakLocations(~,magnitude,...
                minPeakHeight, minPeakDistance, lastPeakLocation, lastPeakValue)
            numPeakLocations = uint8(0);
            peakLocations = int32(zeros(1,floor(length(magnitude) / minPeakDistance)));
            
            for i = 1 : length(magnitude)
                sample = magnitude(i);
                
                if sample >= minPeakHeight
                    if sample > lastPeakValue || i >= (lastPeakLocation + minPeakDistance)
                        lastPeakValue = sample;
                        lastPeakLocation = int32(i);
                    end
                end
                
                if lastPeakValue > single(0.00001) && i >= lastPeakLocation + minPeakDistance
                    lastPeakValue = single(0);
                    numPeakLocations = numPeakLocations + 1;
                    peakLocations(numPeakLocations) = lastPeakLocation;
                end
            end
            peakLocations = peakLocations(1:numPeakLocations);
        end
    end
    
end