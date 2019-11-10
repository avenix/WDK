classdef Merger < Algorithm

    properties (Access = public)
        numMessages;
    end

    properties (Access = private)
        messageCount;
        partialResult;
    end

    methods (Access = public)

        function obj = Merger(numMessages)
            if nargin > 0
                obj.numMessages = numMessages;
            end
            obj.name = 'Merger';
            obj.inputPort = DataType.kAny;
            obj.outputPort = DataType.kAny;
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
        
        function metrics = computeMetrics(~,~)
            flops = 1;
            memory = 1;
            outputSize = 1;
            metrics = Metric(flops,memory,outputSize);
        end

    end
end
