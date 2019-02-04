classdef (Abstract) CompositeComputer < Computer

    properties (Access = public)
        computers;
    end
    
    methods (Access = public)
        function obj = CompositeComputer(computers)
            if nargin > 0
                obj.computers = computers;
            end
        end
        
        function str = toString(obj)
            str = "";
            if ~isempty(obj.computers)
                
                for i = 1 : length(obj.computers)
                    computerStr = obj.computerStringForIdx(i);
                    if ~isequal(computerStr,"")
                        str = sprintf('%s%s_',str,computerStr);
                    end
                end
            end
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