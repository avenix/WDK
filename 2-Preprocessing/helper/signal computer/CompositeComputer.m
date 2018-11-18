classdef CompositeComputer < Computer
    
    properties (Constant)
        kMaxSignalLength = 20;
    end
    
    properties (Access = public)
        computers;
    end
    
    methods (Access = public)
        function obj = CompositeComputer(computers)
            if nargin > 0
                obj.computers = computers;
            end
        end
        
        function signal = compute(obj,signal)
            for i = 1 : length(obj.computers)
                signal = obj.computers{i}.compute(signal);
            end
        end
        
        function str = toString(obj)
            str = obj.computerStringForIdx(1);
            
            for i = 2 : length(obj.computers)
                computerStr = obj.computerStringForIdx(i);
                if ~isequal(computerStr,"")
                    str = sprintf('%s_%s',str,computerStr);
                end
            end
            
            classStrLength = min(CompositeComputer.kMaxSignalLength,length(str));
            str = str(1:classStrLength);
        end
        
        function editableProperties = getEditableProperties(~)
            editableProperties = [];
        end
    end
    
    methods (Access = private)
        function computerStr = computerStringForIdx(obj,idx)
            computer = obj.computers{idx};
            computerStr = computer.toString();
            if isequal(computerStr,'NoOp')
                computerStr = "";
            end
        end
    end
end