classdef SignalComputer < Computer
    properties
        name;
        functionHandle;
        dataColumnRequirement = 1;
    end
    
    methods (Access = public)
        
        function obj = SignalComputer(name,functionHandle)
            if nargin > 0
                obj.name = name;
                obj.functionHandle = functionHandle;
            end
        end
        
        function computedSignal = compute(obj,signal)
            nCols = size(signal,2);
            if isempty(obj.dataColumnRequirement) || (nCols == obj.dataColumnRequirement)
                computedSignal = obj.functionHandle(signal);
            else
                fprintf('Signal Computer %s - Expected %d columns but input data has %d columns\n',obj.toString(), obj.dataColumnRequirement, nCols);
                computedSignal = [];
            end
        end
        
        function str = toString(obj)
            str = sprintf('%s',obj.name);
        end
        
        function editableProperties = getEditableProperties(~)
            editableProperties = [];
        end
        
    end
    
    methods (Static)
        
        function energyComputer = EnergyComputer()
            functionHandle = @(x) x(:,1).^2 + x(:,2).^2 + x(:,3).^2;
            energyComputer = SignalComputer('E',functionHandle);
            energyComputer.dataColumnRequirement = 3;
        end
        
        function signalComputer = NoOpComputer()
            functionHandle = @(x)x;
            signalComputer = SignalComputer('NoOp',functionHandle);
            signalComputer.dataColumnRequirement = [];
        end

    end
end
