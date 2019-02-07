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
        
        function setProperty(obj, property)
            obj.(property.name) = property.value;
        end
        
        function str = toString(obj)
            str = sprintf('%s',obj.name);
        end
        
        function editableProperties = getEditableProperties(~)
            editableProperties = [];
        end
        
        function computers = listAllComputers(obj)
            
            nElements = obj.countElements();
            computers = cell(1,nElements);
            
            stack = Stack();
            stack.push(obj);
            
            counter = 1;
            while ~stack.isempty()
                computer = stack.pop();
                computers{counter} = computer;
                counter = counter + 1;
                for i = 1 : length(computer.nextComputers)
                    stack.push(computer.nextComputers(i));
                end
            end
        end
        
        function properties = listAllProperties(obj)
            
            nElements = obj.countElements();
            properties = cell(1,nElements);
            
            stack = Stack();
            stack.push(obj);
            
            counter = 1;
            while ~stack.isempty()
                computer = stack.pop();
                properties{counter} = computer.getEditableProperties();
                counter = counter + 1;
                for i = 1 : length(computer.nextComputers)
                    stack.push(computer.nextComputers(i));
                end
            end
        end
        
        function n = countElements(obj)
            
            stack = Stack();
            stack.push(obj);
            
            n = 1;
            while ~stack.isempty()
                computer = stack.pop();
                n = n + 1;
                for i = 1 : length(computer.nextComputers)
                    stack.push(computer.nextComputers(i));
                end
            end
        end
    end
    
    methods (Static)
        function var = GetSharedContextVariable(variableName)
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
        
        function data = ExecuteChain(computer, data)
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