classdef (Abstract) Computer < handle
    
    properties (Access = public)
        inputPort;
        outputPort;
        name;
        nextComputers;
    end
    
    methods (Abstract)
        computedSignal = compute(obj,signal);
    end
    
    methods (Access = public)
        %do not comment out the obj parameter
        function setProperty(obj, property)
            setExpression = sprintf('obj.%s=%d;',property.name,property.value);
            eval(setExpression);
        end
        
        function str = toString(obj)
            str = sprintf('%s',obj.name);
        end
        
        function editableProperties = getEditableProperties(~)
            editableProperties = [];
        end
    end
    
    methods (Static)
        function var = getSharedContextVariable(variableName)
            dict = Computer.sharedContext();
            var = dict(variableName);
        end
        
        function r = sharedContext(context)
            persistent currentContext;
            if nargin >= 1
                currentContext = context;
            end
            r = currentContext;
        end
        
        function data = computeChain(computer, data)
            stack = Stack();
            stack.push(computer);
            
            while ~stack.isempty()
                computer = stack.pop();
                data = computer.compute(data);
                for i = 1 : length(computer.nextComputers)
                    stack.push(computer.nextComputers(i));
                end
            end
        end
        
        function preprocessingComputers = PreprocessingComputers()
            preprocessingComputers = {NoOp(),...
                LowPassFilter(), HighPassFilter(),...
                S1(),S2(),...
                Magnitude(), MagnitudeSquared()};
        end
        
        function eventDetectionComputers = EventDetectionComputers()
            eventDetectionComputers = {NoOp(), SimplePeakDetector,MatlabPeakDetector};
        end
        
        function segmentationComputers = SegmentationComputers()
            segmentationComputers = {EventSegmentation};
        end
        
        function featureComputers = FeatureComputers()
            featureComputers = {AAV};
        end
        
        function classificationComputers = ClassificationComputers()
            classificationComputers = {};
        end
        
    end
end