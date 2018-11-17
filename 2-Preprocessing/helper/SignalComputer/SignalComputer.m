classdef SignalComputer < Computer
    properties
        name;
        functionHandle;
    end
    
    methods (Access = public)
        
        function obj = SignalComputer(name,functionHandle)
            if nargin > 0
                obj.name = name;
                obj.functionHandle = functionHandle;
            end
        end
        
        function computedSignal = compute(obj,signal)
            computedSignal = obj.functionHandle(signal);
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
        end
                
        function energyComputer = NoOpComputer()
            functionHandle = @(x)x;
            energyComputer = SignalComputer('NoOp',functionHandle);
        end
        
        function signalComputers = DefaultSignalComputers()
            
            signalNames = {'x','y','z','lax','lay','laz','q0','q1','q2','q3','E','N-1','g0','g1','g2'};
            
            functionHandles = {@(x)x(:,3),@(x)x(:,4),@(x)x(:,5),...
                @(x)x(:,15),@(x)x(:,16),@(x)x(:,17),...
                @(x)x(:,12),@(x)x(:,13),@(x)x(:,14),@(x)x(:,18),...
                @(x)x(:,15).^2+x(:,16).^2 + x(:,17).^2,@(x)x(:,15)+x(:,16)+x(:,17),...
                @(x)x(:,3)/10-x(:,15),@(x)x(:,4)/10-x(:,16),@(x)x(:,5)/10-x(:,17)};
            
            nSignalComputers = length(signalNames);
            
            signalComputers = repmat(SignalComputer(),1,nSignalComputers);
            for i = 1 : nSignalComputers
                signalName = signalNames{i};
                functionHandle = functionHandles{i};
                signalComputers(i) = SignalComputer(signalName,functionHandle);
            end
        end
    end
end
