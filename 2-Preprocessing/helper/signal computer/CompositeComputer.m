classdef (Abstract) CompositeComputer < Computer
    
    properties (Constant)
        kMaxSignalLength = 20;
    end
    
    properties (Access = public)
        computers;
    end
    
    properties (Access = public, Abstract) 
        type;
    end
    
    methods (Access = public)
        function obj = CompositeComputer(computers)
            if nargin > 0
                obj.computers = computers;
            end
        end
        
        function str = toString(obj)
            if isempty(obj.computers)
                str = "";
            else
                str = obj.type;
                
                for i = 1 : length(obj.computers)
                    computerStr = obj.computerStringForIdx(i);
                    if ~isequal(computerStr,"")
                        str = sprintf('%s_%s',str,computerStr);
                    end
                end
                
                classStrLength = min(CompositeComputer.kMaxSignalLength,length(str));
                str = str(1:classStrLength);
            end
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