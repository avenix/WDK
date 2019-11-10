classdef SimplePeakDetector < Algorithm
    
    properties (Access = public)
        minPeakHeight = single(0.8);
        minPeakDistance  = int32(100);
    end
    
    methods  (Access = public)
        
        function obj = SimplePeakDetector(minPeakHeight, minPeakDistance)
            if nargin > 0
                obj.minPeakHeight = minPeakHeight;
                obj.minPeakDistance = minPeakDistance;
            end
            obj.name = 'simplePeakDet';
            obj.inputPort = DataType.kSignal;
            obj.outputPort = DataType.kEvent;
        end
        
        function str = toString(obj)
            str = sprintf('%s_%.3f_%d',obj.name,obj.minPeakHeight,obj.minPeakDistance);
        end
        
        function editableProperties = getEditableProperties(obj)
            minPeakHeightProperty = Property('minPeakHeight',obj.minPeakHeight,0,1);
            minPeakDistanceProperty = Property('minPeakDistance',obj.minPeakDistance,50,200);
            editableProperties = [minPeakHeightProperty,minPeakDistanceProperty];
        end
        
        function events = compute(obj,signal)
            eventLocations = obj.detectEvents(signal);
            events = Helper.CreateEventsWithEventLocations(eventLocations);
        end
        
        function metrics = computeMetrics(~,input)
            flops = size(input,1) * 4;
            memory = 1;
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
