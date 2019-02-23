classdef LowPassFilter < Computer
    
    properties (Access = public)
        samplingFrequency = 200;
        order = 1;
        cutoff = 20;
    end
    
    methods (Access = public)
        
        function obj = LowPassFilter(order,cutoff)
            if nargin > 0
                obj.order = order;
                obj.cutoff = cutoff;
            end
            obj.name = 'lowPass';
            obj.inputPort = ComputerPort(ComputerPortType.kSignal);
            obj.outputPort = ComputerPort(ComputerPortType.kSignal);
        end
        
        function dataFiltered = compute(obj,data)
            myFilterParameters = fdesign.lowpass('N,F3dB', obj.order, obj.cutoff, obj.samplingFrequency);
            f = myFilterParameters.design('butter');
            dataFiltered = filter(f,double(data));
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
            flops = obj.order * size(input,1); %assumes filter swipes once the entire signal
            memory = size(input,1) * 4;
            outputSize = size(input,1) * 4;
            metrics = Metric(flops,memory,outputSize);
        end
        
    end
end