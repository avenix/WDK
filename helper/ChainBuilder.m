classdef ChainBuilder < handle
    properties (Access = private)
        root;
        lastComputer;
    end
    
    methods (Access = public)
        
        function chain = getRoot(obj)
            chain = obj.root;
        end
        
        function addComputer(obj, computer)
            if isempty(obj.root)
                obj.root = computer;
            end
            if ~isempty(obj.lastComputer)
                obj.lastComputer.nextComputers = computer;
            end
            obj.lastComputer = computer;
        end
    end
end
