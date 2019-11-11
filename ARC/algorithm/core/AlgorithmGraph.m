%Represents a directed graph of algorithms
classdef AlgorithmGraph < handle
    properties (GetAccess = public)
        nodes;
        edges;
        nodeNames;
    end
    
    methods (Access = public)
        function obj = AlgorithmGraph(nodes,edges)
            obj.nodes = nodes;
            obj.edges = edges;
            obj.createNodeNames();
        end
    end
    
    methods (Access = private)
        function createNodeNames(obj)
            nAlgorithms = length(obj.nodes);
            obj.nodeNames = cell(1,nAlgorithms);
            for i = 1 : nAlgorithms
                obj.nodeNames{i} = sprintf('%d-%s',i,obj.nodes{i}.toString());
            end
        end
    end
    
    methods (Static, Access = private)
        
        function UntagAlgorithms(algorithm)
            
            stack = Stack();
            stack.push(algorithm);
            while ~stack.isempty()
                algorithm = stack.pop();
                algorithm.tag = [];
                
                for i = 1 : length(algorithm.nextAlgorithms)
                    stack.push(algorithm.nextAlgorithms{i});
                end
            end
        end
        
        function [algorithmCount, edgesCount] = TagAlgorithms(algorithm)
            stack = Stack();
            stack.push(algorithm);
            algorithmCount = 1;
            edgesCount = 0;
            while ~stack.isempty()
                algorithm = stack.pop();
                if isempty(algorithm.tag)
                    algorithm.tag = algorithmCount;
                    algorithmCount = algorithmCount + 1;
                    
                    for i = 1 : length(algorithm.nextAlgorithms)
                        stack.push(algorithm.nextAlgorithms{i});
                        edgesCount = edgesCount + 1;
                    end
                end
            end
            algorithmCount = algorithmCount - 1;
        end
        
    end
    
    methods (Static, Access = public)
        function graph = CreateGraph(algorithm)
            AlgorithmGraph.UntagAlgorithms(algorithm);
            [nAlgorithms, nEdges] = AlgorithmGraph.TagAlgorithms(algorithm);
            
            nodes = cell(1,nAlgorithms);
            edges = repmat(AlgorithmGraphEdge,1,nEdges);
            
            visited = false(1,nAlgorithms);
            
            stack = Stack();
            stack.push(algorithm);
            algorithmCount = 1;
            edgesCount = 1;
            while ~stack.isempty()
                algorithm = stack.pop();
                if ~visited(algorithm.tag)
                    visited(algorithm.tag) = true;
                    nodes{algorithmCount} = algorithm;
                    algorithmCount = algorithmCount + 1;
                    
                    for i = 1 : length(algorithm.nextAlgorithms)
                        nextAlgorithm = algorithm.nextAlgorithms{i};
                        stack.push(nextAlgorithm);
                        edges(edgesCount) = AlgorithmGraphEdge(algorithm.tag,nextAlgorithm.tag);
                        edgesCount = edgesCount + 1;
                    end
                end
            end
            
            graph = AlgorithmGraph(nodes,edges);
        end
    end
end
