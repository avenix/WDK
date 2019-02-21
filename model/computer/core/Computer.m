classdef (Abstract) Computer < matlab.mixin.Copyable
    
    properties (Access = public)
        inputPort;
        outputPort;
        name;
    end
    
    properties (SetAccess = private)
        nextComputers;
    end
    
    methods (Abstract)
        computedSignal = compute(obj,signal);
    end
    
    methods (Access = public)
        
        function setProperty(obj, property)
            obj.(property.name) = property.value;
        end
        
        function addNextComputer(obj,computer)
            obj.nextComputers{end+1} = computer;
        end
        
        function str = toString(obj)
            str = sprintf('%s',obj.name);
        end
        
        function editableProperties = getEditableProperties(~)
            editableProperties = [];
        end
        
        function metrics = computeMetrics(~,~)
            metrics = Metric();
        end
    end
    
    methods (Static, Access = private)
        
        function computers = ListAllComputers(computer)
            
            nComputers = Computer.CountComputers(computer);
            
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
        
        %returns the loaded data and the first computer in the chain that
        %was not cached
        function [computer, data, str] = LoadCacheDataWithComputers(computers)
            
            cache = Cache.SharedInstance();
            
            strings = cellfun(@(x) x.toString(),computers,'UniformOutput',false);
            nComputers = length(computers);
            
            computer = [];
            data = [];
            str = [];
            for i = nComputers : -1 : 1
                computer = computers{i};
                str = Helper.cellArrayToString(strings(1:i),', ');
                
                if cache.containsVariable(str)
                    fprintf('loaded %s\n',str);
                    data = cache.loadVariable(str);
                    break;
                end
            end
            
            if isempty(computer.nextComputers)
                computer = [];
            elseif length(computer.nextComputers) == 1
                computer = computer.nextComputers{1};
            else
                computer = CompositeComputer.CreateComputerWithSequence(computer.nextComputers);
            end
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
        
        function [data, metricSum] = ExecuteChain(computer, data, shouldCache)
            
            if nargin < 3
                shouldCache = false;
            end
            
            metricSum = Metric();
            
            if shouldCache
                computers = Computer.ListAllComputers(computer);
                nComputers = length(computers);
                computerStrings = cell(1,nComputers);
                
                [firstComputer, loadedData, str] = Computer.LoadCacheDataWithComputers(computers);
                clear('computers');
                
                if isempty(loadedData)
                    count = 1;
                else
                    data = loadedData{1};
                    metricSum = loadedData{2};
                    computer = firstComputer;
                    computerStrings{1} = str;
                    count = 2;
                end
                cache = Cache.SharedInstance();
            end
            
            
            if ~isempty(computer)
                stack = Stack();
                dataStack = Stack();
                
                stack.push(computer);
                dataStack.push(data);
                
                while ~stack.isempty()
                    computer = stack.pop();
                    data = dataStack.pop();
                    metric = computer.computeMetrics(data);
                    data = computer.compute(data);
                    
                    metricSum.addMetric(metric);
                    
                    if ~isempty(data)
                        for i = 1 : length(computer.nextComputers)
                            dataStack.push(data);
                            stack.push(computer.nextComputers{i});
                        end
                    end
                    
                    if shouldCache
                        computerStrings{count} = computer.toString();
                        stringStackStr = Helper.cellArrayToString(computerStrings(1:count),', ');
                        count = count + 1;
                        cache.saveVariable({data,metricSum},stringStackStr);
                    end
                end
            end
        end
        
    end
end