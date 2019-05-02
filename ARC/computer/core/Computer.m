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
            var = dict(variableName);
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
        
        function [data, metricSum, graphString] = ExecuteChain(computer, data, shouldCache, dataCacheIdentifier)
            if isempty(computer)
                metricSum = [];
            else
                if nargin < 4
                    dataCacheIdentifier = '';
                    if nargin < 3
                        shouldCache = false;
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
                end
                
                if ~isDataLoaded
                    [data, metricSum] = Computer.ExecuteChainNoCache(computer,data);
                    if shouldCache
                        Computer.SaveGraphToCache(data,metricSum,graphString);
                    end
                end
            end
        end
        
        function [data, metricSum] = ExecuteChainNoCache(computer, data)
            stack = Stack();
            dataStack = Stack();
            
            stack.push(computer);
            dataStack.push(data);
            
            metricSum = Metric();
            
            while ~stack.isempty()
                computer = stack.pop();
                data = dataStack.pop();
                
                metric = computeMetrics(computer,data);
                metricSum.addMetrics(metric);
                
                data = computer.compute(data);
                
                if ~isempty(data)
                    for i = 1 : length(computer.nextComputers)
                        dataStack.push(data);
                        stack.push(computer.nextComputers{i});
                    end
                end
            end
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
