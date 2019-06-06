classdef Resampler < Computer
    
    properties (Access = public)
        samplingInterval = 1;
    end
    
    methods (Access = public)
        
        function obj = Resampler(samplingInterval)
            if nargin > 0
                obj.samplingInterval = samplingInterval;
            end
            obj.name = 'resampler';
            obj.inputPort = ComputerDataType.kSignal;
            obj.outputPort = ComputerDataType.kSignal;
        end
        
        function dataFiltered = compute(obj,data)
            dataFiltered = data(1:obj.samplingInterval:end,:);
        end
        
        function str = toString(obj)
            str = sprintf('%s_%d',obj.name,obj.samplingInterval);
        end
        
        function editableProperties = getEditableProperties(obj)
            editableProperties = Property('samplingInterval',obj.samplingInterval,1,100);
        end        
    end
end
