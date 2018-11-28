classdef SignalComputer < Computer
    properties
        name;
        functionHandle;
        expectedNumInputSignals;
    end
    
    methods (Access = public)
        
        function obj = SignalComputer(name,functionHandle)
            if nargin > 0
                obj.name = name;
                obj.functionHandle = functionHandle;
            end
            obj.expectedNumInputSignals = [];
        end
        
        function computedSignal = compute(obj,signal)
            numInputSignals = size(signal,2);
            if numInputSignals ~= obj.expectedNumInputSignals
                fprintf('SignalComputer %s - wrong input size: %d, should be: %d\n',...
                    obj.toString(),numInputSignals,obj.expectedNumInputSignals);
                computedSignal = [];
            else
                computedSignal = obj.functionHandle(signal);
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
            energyComputer.expectedNumInputSignals = 3;
        end
             
        function normComputer = NormComputer()
            functionHandle = @(x) abs(x(:,1)) + abs(x(:,2)) + abs(x(:,3));
            normComputer = SignalComputer('Norm',functionHandle);
            normComputer.expectedNumInputSignals = 3;
        end
        
        function signalComputer = NoOpComputer()
            functionHandle = @(x)x;
            signalComputer = SignalComputer('NoOp',functionHandle);
        end
        
        function signalComputer = SubtractionComputer()
            functionHandle = @(x)x(:,2)-x(:,1);
            signalComputer = SignalComputer('Subtraction',functionHandle);
            signalComputer.expectedNumInputSignals = 2;
        end
        
        function signalComputer = AdditionComputer()
            functionHandle = @(x)x(:,2)+x(:,1);
            signalComputer = SignalComputer('Subtraction',functionHandle);
            signalComputer.expectedNumInputSignals = 2;
        end
        
    end
end
