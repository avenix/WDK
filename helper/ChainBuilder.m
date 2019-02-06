classdef ChainBuilder < handle
    properties (SetAccess = private)
        root;
        lastComputer;
    end
    
    methods (Access = public)
        function obj = ChainBuilder(computer)
            if nargin > 0
                obj.addComputer(computer);
            end
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
