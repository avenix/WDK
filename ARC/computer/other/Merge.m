classdef Merge < Computer

    properties (Access = public)
        numMessages;
    end

    properties (Access = private)
        messageCount;
        partialResult;
    end

    methods (Access = public)

        function obj = Merge(numMessages)
            if nargin > 0
                obj.numMessages = numMessages;
            end
            obj.name = 'Merge';
            obj.inputPort = ComputerPort(ComputerPortType.kAny);
            obj.outputPort = ComputerPort(ComputerPortType.kAny);
            obj.messageCount = 0;
        end
        
        function dataOut = compute(obj,dataIn)
            if obj.messageCount == 0
                obj.partialResult = cell(1,obj.numMessages);
            end
            
            obj.messageCount = obj.messageCount + 1;
            obj.partialResult{obj.messageCount} = dataIn;
            
            if obj.messageCount < obj.numMessages
                dataOut = [];
            else
                dataOut = obj.partialResult;
                obj.messageCount = 0;
            end
        end
        
        function editableProperties = getEditableProperties(obj)
            editableProperties = Property('numMessages',obj.numMessages);
        end
        
        function str = toString(obj)
            str = sprintf("%s_%d",obj.name,obj.numMessages);
        end
        
        function metrics = computeMetrics(obj,input)
            
            memory = 0;
            dataOut = obj.compute(input);
            if ~isempty(dataOut)
                nMessages = length(dataOut);
                for i = 1 : nMessages 
                    data = dataOut{i};
                    n = size(data,1) * size(data,2) * 4;
                    memory = memory + n;
                end
            end
            metrics = Metric(0,memory,memory);
        end
    end
end