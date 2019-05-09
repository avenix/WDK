classdef HighPassFilter < Computer
    
    properties (Access = public)    
        samplingFrequency = 200;
        order = 1;
        cutoff = 20;
    end
    
    methods (Access = public)
        function obj = HighPassFilter(order, cutoff)
            if nargin > 0
                obj.order = order;
                obj.cutoff = cutoff;
            end
            obj.name = 'highPass';
            obj.inputPort = ComputerDataType.kSignal;
            obj.outputPort = ComputerDataType.kSignal;
        end
        
        function dataFiltered = compute(obj, data)
            [b, a] = butter(obj.order,obj.cutoff/(obj.samplingFrequency/2),'high');
            dataFiltered = abs(filtfilt(b, a, double(data)));
        end
        
        function str = toString(obj)
            str = sprintf('%s_%d_%d',obj.name,obj.order,obj.cutoff);
        end
        
        function editableProperties = getEditableProperties(obj)
            property1 = Property('order',obj.order,1,4);
            property2 = Property('cutoff',obj.cutoff,1,20);
            editableProperties = [property1,property2];
        end
        
        function metrics = computeMetrics(obj,input)
            n = size(input,1);
            flops = 13 * obj.order * n;
            memory = n * Constants.kSensorDataBytes;
            outputSize = n * Constants.kSensorDataBytes;
            metrics = Metric(flops,memory,outputSize);
        end
    end
end

