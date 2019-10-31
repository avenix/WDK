classdef AxisMerger < Computer
    
    properties (Access = public)
        nAxes = 2;
    end
    
    properties (Access = private)
        currentAxis = 0;
        mergedSignal;
    end
    
    methods (Access = public)
        
        function obj = AxisMerger(nAxes)
            if nargin > 0
                obj.nAxes = nAxes;
            end
            obj.name = 'AxisMerger';
            obj.inputPort = DataType.kSignal;
            obj.outputPort = DataType.kSignalN;
        end
        
        function outputSignal = compute(obj,signal)
            
            obj.currentAxis = obj.currentAxis + 1;
            obj.mergedSignal(:,obj.currentAxis) = signal;
            
            if(obj.currentAxis == obj.nAxes)
                outputSignal = obj.mergedSignal;
                obj.mergedSignal = [];
                obj.currentAxis = 0;
            else
                outputSignal = [];
            end
        end
        
        function str = toString(obj)
            str = sprintf('%s%s',obj.name,obj.nAxes);
        end
        
        function editableProperties = getEditableProperties(obj)
            editableProperties = Property('nAxes',obj.nAxes);
            editableProperties.type = PropertyType.kNumber;
        end
        
        function metrics = computeMetrics(obj,input)
            n = size(input,1);
            m = size(input,2);
            flops = 3 * n;
            memory = n * m;
            outputSize = n * m;
            metrics = Metric(flops,memory,outputSize);
        end
    end
end
