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
    
    methods (Static)
        function computer = CreateComputerWithSequence(sequence)
            if isempty(sequence)
                computer = [];
            else
                for i = 1 : length(sequence)-1
                    sequence{i}.nextComputers = sequence{i+1};
                end
                computer = CompositeComputer(sequence{1});
            end
        end
    end
end
