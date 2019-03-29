classdef ComputerGraph < handle
    properties (GetAccess = public)
        nodes;
        edges;
        nodeNames;
    end
    
    methods (Access = public)
        function obj = ComputerGraph(nodes,edges)
            obj.nodes = nodes;
            obj.edges = edges;
            obj.createNodeNames();
        end
    end
    
    methods (Access = private)
        function createNodeNames(obj)
            nComputers = length(obj.nodes);
            obj.nodeNames = cell(1,nComputers);
            for i = 1 : nComputers
                obj.nodeNames{i} = sprintf('%d-%s',i,obj.nodes{i}.toString());
            end
        end
    end
    
    methods (Static, Access = private)
        
        function UntagComputers(computer)
            
            stack = Stack();
            stack.push(computer);
            while ~stack.isempty()
                computer = stack.pop();
                computer.tag = [];
                
                for i = 1 : length(computer.nextComputers)
                    stack.push(computer.nextComputers{i});
                end
            end
        end
        
        function [computerCount, edgesCount] = TagComputers(computer)
            stack = Stack();
            stack.push(computer);
            computerCount = 1;
            edgesCount = 0;
            while ~stack.isempty()
                computer = stack.pop();
                if isempty(computer.tag)
                    computer.tag = computerCount;
                    computerCount = computerCount + 1;
                    
                    for i = 1 : length(computer.nextComputers)
                        stack.push(computer.nextComputers{i});
                        edgesCount = edgesCount + 1;
                    end
                end
            end
            computerCount = computerCount - 1;
        end
        
    end
    
    methods (Static, Access = public)
        function graph = CreateGraph(computer)
            ComputerGraph.UntagComputers(computer);
            [nComputers, nEdges] = ComputerGraph.TagComputers(computer);
            
            nodes = cell(1,nComputers);
            edges = repmat(ComputerGraphEdge,1,nEdges);
            
            visited = false(1,nComputers);
            
            stack = Stack();
            stack.push(computer);
            computerCount = 1;
            edgesCount = 1;
            while ~stack.isempty()
                computer = stack.pop();
                if ~visited(computer.tag)
                    visited(computer.tag) = true;
                    nodes{computerCount} = computer;
                    computerCount = computerCount + 1;
                    
                    for i = 1 : length(computer.nextComputers)
                        nextComputer = computer.nextComputers{i};
                        stack.push(nextComputer);
                        edges(edgesCount) = ComputerGraphEdge(computer.tag,nextComputer.tag);
                        edgesCount = edgesCount + 1;
                    end
                end
            end
            
            graph = ComputerGraph(nodes,edges);
        end
    end
end