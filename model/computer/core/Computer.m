classdef (Abstract) Computer < matlab.mixin.Copyable
    
    properties (Access = public)
        inputPort;
        outputPort;
        name;
    end
    
    properties (SetAccess = private)    
        nextComputers;
    end

    methods (Abstract)
        computedSignal = compute(obj,signal);
    end
    
    methods (Access = public)
        
        function setProperty(obj, property)
            obj.(property.name) = property.value;
        end
        
        function addNextComputer(obj,computer)
            obj.nextComputers{end+1} = computer;
        end
        
        function str = toString(obj)
            str = sprintf('%s',obj.name);
        end
        
        function editableProperties = getEditableProperties(~)
            editableProperties = [];
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
            dataStack = Stack();
            
            stack.push(computer);
            dataStack.push(data);
            
            while ~stack.isempty()
                computer = stack.pop();
                data = dataStack.pop();
                data = computer.compute(data);
                if ~isempty(data)
                    for i = 1 : length(computer.nextComputers)
                        dataStack.push(data);
                        stack.push(computer.nextComputers{i});
                    end
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
        
        function classificationComputers = ClassificationComputers()
            classificationComputers = {};
        end
        
    end
end