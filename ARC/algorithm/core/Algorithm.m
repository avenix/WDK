classdef (Abstract) Algorithm < matlab.mixin.Copyable

    properties (Access = public)
        inputPort; % describes the type of the input this algorithm takes
        outputPort; % describes the type of the output this algorithm produces
        name;
    end
    
    properties (Access = public)
        nextAlgorithms; % array of algorithms this algorithm is connected to
        tag;
    end
    
    methods (Abstract)
        computedSignal = compute(obj,signal);
    end
    
    methods (Access = public)
        
        function setProperty(obj, property)
            obj.(property.name) = property.value;
        end
        
        function setProperties(obj, properties)
            for i = 1 : length(properties)
                obj.setProperty(properties(i));
            end
        end
        
        function addNextAlgorithm(obj, algorithm)
            obj.nextAlgorithms{end+1} = algorithm;
        end
        
        function addNextAlgorithms(obj, algorithms)
            for i = 1 : length(algorithms)
                obj.addNextAlgorithm(algorithms{i});
            end
        end
        
        function str = toString(obj)
            str = sprintf('%s',obj.name);
        end
        
        function editableProperties = getEditableProperties(~)
            editableProperties = [];
        end
        
        function metrics = computeMetrics(~,~)
            metrics = [];
        end
    end
    
    methods (Static, Access = private)
        
        function algorithms = ListAllAlgorithms(algorithm)
            nAlgorithms = Algorithm.CountAlgorithms(algorithm);
            if nAlgorithms == 0
                algorithms = [];
            else
                stack = Stack();
                stack.push(algorithm);
                
                algorithms = cell(1,nAlgorithms);
                
                count = 1;
                while ~stack.isempty()
                    algorithm = stack.pop();
                    algorithms{count} = algorithm;
                    count = count + 1;
                    for i = 1 : length(algorithm.nextAlgorithms)
                        stack.push(algorithm.nextAlgorithms{i});
                    end
                end
            end
        end
        
        function str = GraphToString(algorithm)
            algorithms = Algorithm.ListAllAlgorithms(algorithm);
            strings = cellfun(@(x) x.toString(),algorithms,'UniformOutput',false);
            str = Helper.cellArrayToString(strings);
        end
        
        function [isDataCached, data, metricSum] = LoadCacheDataForGraphString(graphString)
            cache = Cache.SharedInstance();
            if cache.containsVariable(graphString)
                loadedData = cache.loadVariable(graphString);
                data = loadedData{1};
                metricSum = loadedData{2};
                isDataCached = true;
            else
                isDataCached = false;
                data = [];
                metricSum = [];
            end
        end
        
        function SaveGraphToCache(data,metrics,graphString)
            cache = Cache.SharedInstance();
            cache.saveVariable({data,metrics},graphString);
        end
    end
    
    methods (Static)
        
        function SetSharedContextVariable(variableName,variable)
            dict = Algorithm.SharedContext();
            dict(variableName) = variable;
        end
        
        function var = GetSharedContextVariable(variableName)
            dict = Algorithm.SharedContext();
            if isKey(dict,variableName)
                var = dict(variableName);
            else
                var = [];
            end
        end
        
        function dict = SharedContext()
            persistent currentContext;
            if isempty(currentContext)
                currentContext = containers.Map();
            end
            dict = currentContext;
        end
        
        function nAlgorithms = CountAlgorithms(algorithm)
            if isempty(algorithm)
                nAlgorithms = 0;
            else
                stack = Stack();
                stack.push(algorithm);
                
                nAlgorithms = 0;
                while ~stack.isempty()
                    algorithm = stack.pop();
                    nAlgorithms = nAlgorithms + 1;
                    for i = 1 : length(algorithm.nextAlgorithms)
                        stack.push(algorithm.nextAlgorithms{i});
                    end
                end
            end
        end
        
        %converts composites in flat hierarchy
        function FlattenChain(algorithm)
            stack = Stack();
            
            stack.push(algorithm);
            
            while ~stack.isempty()
                algorithm = stack.pop();
                
                for i = 1 : length(algorithm.nextAlgorithms)
                    nextAlgorithm = algorithm.nextAlgorithms{i};
                    
                    if isa(nextAlgorithm, 'CompositeAlgorithm')
                        algorithm.nextAlgorithms{i} = nextAlgorithm.root;
                        nextAlgorithmIdx = 1;
                        for j = 1 : length(nextAlgorithm.lastAlgorithms{i})
                            nextAlgorithm.lastAlgorithms{i}.nextAlgorithms{j} = nextAlgorithm.nextAlgorithms{nextAlgorithmIdx};
                            nextAlgorithmIdx = nextAlgorithmIdx + 1;
                        end
                        nextAlgorithm = nextAlgorithm.root;
                    end
                    stack.push(nextAlgorithm);
                end
            end
        end
        
        function [data, metricSum, graphString] = ExecuteChain(algorithm, data, shouldCache, dataCacheIdentifier, outputAlgorithm)
            if isempty(algorithm)
                metricSum = [];
            else
                if nargin < 5
                    outputAlgorithm = [];
                    if nargin < 4
                        dataCacheIdentifier = '';
                        if nargin < 3
                            shouldCache = false;
                        end
                    end
                end
                
                isDataLoaded = false;
                if shouldCache
                    graphString = Algorithm.GraphToString(algorithm);
                    graphString = [dataCacheIdentifier graphString];
                    [isDataLoaded, loadedData, metricSum] = Algorithm.LoadCacheDataForGraphString(graphString);
                    
                    if isDataLoaded
                        data = loadedData;
                    end
                else
                    graphString = [];
                end
                
                if ~isDataLoaded
                    [data, metricSum] = Algorithm.ExecuteChainNoCache(algorithm,data,outputAlgorithm);
                    if shouldCache
                        Algorithm.SaveGraphToCache(data,metricSum,graphString);
                    end
                end
            end
        end
        
        function [data, metricSum] = ExecuteChainNoCache(algorithm, data,outputAlgorithm)
            
            Algorithm.ResetAlgorithmTags(algorithm);
            
            stack = Stack();
            dataStack = Stack();
            
            stack.push(algorithm);
            dataStack.push(data);
            
            metricSum = Metric();
            
            while ~stack.isempty()
                algorithm = stack.pop();
                data = dataStack.pop();
                
                metric = computeMetrics(algorithm,data);
                if ~isempty(metric)
                    metricSum.flops = metricSum.flops + metric.flops;
                    if isempty(outputAlgorithm) || algorithm == outputAlgorithm
                        metricSum.outputSize = metric.outputSize;
                    end
                    
                    %count the memory once per algorithm using the tag
                    if isempty(algorithm.tag)
                        metricSum.memory = metricSum.memory + metric.memory;
                        algorithm.tag = true;
                    end
                end
                
                data = algorithm.compute(data);
                
                if ~isempty(data)
                    for i = 1 : length(algorithm.nextAlgorithms)
                        nextAlgorithm = algorithm.nextAlgorithms{i};
                        stack.push(nextAlgorithm);
                        dataStack.push(data);
                    end
                end
            end
            
        end
        
        function ResetAlgorithmTags(algorithm)
            stack = Stack();
            stack.push(algorithm);
                        
            while ~stack.isempty()
                algorithm = stack.pop();
                algorithm.tag = [];
                for i = 1 : length(algorithm.nextAlgorithms)
                    nextAlgorithm = algorithm.nextAlgorithms{i};
                    stack.push(nextAlgorithm);
                end
            end
        end
        
        
        function root = AlgorithmWithFork(algorithms)
            root = NoOp();
            root.nextAlgorithms = algorithms;
        end
        
        function root = AlgorithmWithSequence(sequence)
            if isempty(sequence)
                root = [];
            else
                root = sequence{1};
                for i = 1 : length(sequence)-1
                    sequence{i}.addNextAlgorithm(sequence{i+1});
                end
            end
        end
    end
end
