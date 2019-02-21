classdef SimplePeakDetector < Computer
    
    properties (Access = public)
        minPeakHeight = single(160);
        minPeakDistance  = int32(100);
    end
    
    methods  (Access = public)
        
        function obj = SimplePeakDetector()
            obj.name = 'simplePeakDet';
            obj.inputPort = ComputerPort(ComputerPortType.kSignal);
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
        
        function metrics = computeMetrics(~,input)
            flops = size(input,1) * 3;
            memory = 3 * 4;
            outputSize = 0;
            metrics = Metric(flops,memory,outputSize);
        end
    end
    
    methods (Access = private)
        function peakLocations = detectEvents(obj,signal)
                        
            signal = single(signal);
            lastPeakLocation = -1000;
            lastPeak = 0;
            
            [peakLocations, ~,~] = obj.findPeakLocations(signal,obj.minPeakHeight,obj.minPeakDistance,lastPeakLocation,lastPeak);
            peakLocations = uint32(peakLocations);
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