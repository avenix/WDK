classdef (Abstract) Computer < matlab.mixin.Copyable

    properties (Access = public)
        inputPort; % describes the type of the input this computer takes
        outputPort; % describes the type of the output this computer produces
        name; 
    end
    
    properties (Access = public)
        nextComputers; % array of computers this computer is connected to
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
        
        function addNextComputer(obj, computer)
            obj.nextComputers{end+1} = computer;
        end
        
        function addNextComputers(obj, computers)
            for i = 1 : length(computers)
                obj.addNextComputer(computers{i});
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
        
        function computers = ListAllComputers(computer)
            nComputers = Computer.CountComputers(computer);
            if nComputers == 0
                computers = [];
            else
                stack = Stack();
                stack.push(computer);
                
                computers = cell(1,nComputers);
                
                count = 1;
                while ~stack.isempty()
                    computer = stack.pop();
                    computers{count} = computer;
                    count = count + 1;
                    for i = 1 : length(computer.nextComputers)
                        stack.push(computer.nextComputers{i});
                    end
                end
            end
        end
        
        function str = GraphToString(computer)
            computers = Computer.ListAllComputers(computer);
            strings = cellfun(@(x) x.toString(),computers,'UniformOutput',false);
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
            dict = Computer.SharedContext();
            dict(variableName) = variable;
        end
        
        function var = GetSharedContextVariable(variableName)
            dict = Computer.SharedContext();
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
        
        function nComputers = CountComputers(computer)
            if isempty(computer)
                nComputers = 0;
            else
                stack = Stack();
                stack.push(computer);
                
                nComputers = 0;
                while ~stack.isempty()
                    computer = stack.pop();
                    nComputers = nComputers + 1;
                    for i = 1 : length(computer.nextComputers)
                        stack.push(computer.nextComputers{i});
                    end
                end
            end
        end
        
        %converts composites in flat hierarchy
        function FlattenChain(computer)
            stack = Stack();
            
            stack.push(computer);
            
            while ~stack.isempty()
                computer = stack.pop();
                
                for i = 1 : length(computer.nextComputers)
                    nextComputer = computer.nextComputers{i};
                    
                    if isa(nextComputer, 'CompositeComputer')
                        computer.nextComputers{i} = nextComputer.root;
                        nextComputerIdx = 1;
                        for j = 1 : length(nextComputer.lastComputers{i})
                            nextComputer.lastComputers{i}.nextComputers{j} = nextComputer.nextComputers{nextComputerIdx};
                            nextComputerIdx = nextComputerIdx + 1;
                        end
                        nextComputer = nextComputer.root;
                    end
                    stack.push(nextComputer);
                end
            end
        end
        
        function [data, metricSum, graphString] = ExecuteChain(computer, data, shouldCache, dataCacheIdentifier, outputComputer)
            if isempty(computer)
                metricSum = [];
            else
                if nargin < 5
                    outputComputer = [];
                    if nargin < 4
                        dataCacheIdentifier = '';
                        if nargin < 3
                            shouldCache = false;
                        end
                    end
                end
                
                isDataLoaded = false;
                if shouldCache
                    graphString = Computer.GraphToString(computer);
                    graphString = [dataCacheIdentifier graphString];
                    [isDataLoaded, loadedData, metricSum] = Computer.LoadCacheDataForGraphString(graphString);
                    if isDataLoaded
                        data = loadedData;
                    end
                else
                    graphString = [];
                end
                
                if ~isDataLoaded
                    [data, metricSum] = Computer.ExecuteChainNoCache(computer,data,outputComputer);
                    if shouldCache
                        Computer.SaveGraphToCache(data,metricSum,graphString);
                    end
                end
            end
        end
        
        function [data, metricSum] = ExecuteChainNoCache(computer, data,outputComputer)
            
            Computer.ResetComputerTags(computer);
            
            stack = Stack();
            dataStack = Stack();
            
            stack.push(computer);
            dataStack.push(data);
            
            metricSum = Metric();
            
            while ~stack.isempty()
                computer = stack.pop();
                data = dataStack.pop();
                
                metric = computeMetrics(computer,data);
                if ~isempty(metric)
                    metricSum.flops = metricSum.flops + metric.flops;
                    if isempty(outputComputer) || computer == outputComputer
                        metricSum.outputSize = metric.outputSize;
                    end
                    
                    %count the memory once per computer using the tag
                    if isempty(computer.tag)
                        metricSum.memory = metricSum.memory + metric.memory;
                        computer.tag = true;
                    end
                end
                
                data = computer.compute(data);
                
                if ~isempty(data)
                    for i = 1 : length(computer.nextComputers)
                        nextComputer = computer.nextComputers{i};
                        stack.push(nextComputer);
                        dataStack.push(data);
                    end
                end
            end
            
        end
        
        function ResetComputerTags(computer)
            stack = Stack();
            stack.push(computer);
                        
            while ~stack.isempty()
                computer = stack.pop();
                computer.tag = [];
                for i = 1 : length(computer.nextComputers)
                    nextComputer = computer.nextComputers{i};
                    stack.push(nextComputer);
                end
            end
        end
        
        
        function root = ComputerWithFork(computers)
            root = NoOp();
            root.nextComputers = computers;
        end
        
        function root = ComputerWithSequence(sequence)
            if isempty(sequence)
                root = [];
            else
                root = sequence{1};
                for i = 1 : length(sequence)-1
                    sequence{i}.addNextComputer(sequence{i+1});
                end
            end
        end
    end
end
