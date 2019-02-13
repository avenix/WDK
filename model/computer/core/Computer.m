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

    end
    
    methods (Access = protected)
        function sendMsg(obj,data)
            for i = 1 : length(obj.nextComputers)
                Computer.ExecuteChain(obj.nextComputers{i},data);
            end
        end
    end
    
    methods (Static, Access = private)
        
        %returns the loaded data and the first computer in the chain that
        %was not cached
        function [computer, data] = LoadCacheDataFromChain(computer)
            
            cache = Cache.SharedInstance();
            allComputersStack = Stack();
            
            stack = Stack();
            stack.push(computer);
            
            nComputers = Computer.CountComputers(computer);
            stringsStack = cell(1,nComputers);

            count = 1;
            while ~stack.isempty()
                computer = stack.pop();
                allComputersStack.push(computer);
                stringsStack{count} = computer.toString();
                count = count + 1;
                for i = 1 : length(computer.nextComputers)
                    stack.push(computer.nextComputers{i});
                end
            end
            
            data = [];
            while ~allComputersStack.isempty()
                computer = allComputersStack.pop();
                count = count -1;
                stringStackStr = Helper.cellArrayToString(stringsStack(1:count),', ');
                
                if cache.containsVariable(stringStackStr)
                    data = cache.loadVariable(stringStackStr);
                    break;
                end
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
        
        function r = SharedContext()
            persistent currentContext;
            if isempty(currentContext)
                currentContext = containers.Map();
            end
            r = currentContext;
        end
        
        function nComputers = CountComputers(computer)
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
        
        function data = ExecuteChain(computer, data, shouldCache)

            if nargin == 2
                shouldCache = false;
            end
            
            if shouldCache
                [firstComputer, loadedData] = Computer.LoadCacheDataFromChain(computer);
                if ~isempty(loadedData)
                    data = loadedData;
                    computer = firstComputer;
                end
                cache = Cache.SharedInstance();
                
                nComputers = Computer.CountComputers(computer);
                stringsStack = cell(1,nComputers);
            end
            
            
            stack = Stack();
            dataStack = Stack();
            
            stack.push(computer);
            dataStack.push(data);
            
            count = 1;
            
            while ~stack.isempty()
                computer = stack.pop();
                data = dataStack.pop();
                data = computer.compute(data);
                if ~isempty(data)
                    for i = 1 : length(computer.nextComputers)
                        dataStack.push(data);
                        stack.push(computer.nextComputers{i});
                    end
                end
                
                if shouldCache
                    stringsStack{count} = computer.toString();
                    stringStackStr = Helper.cellArrayToString(stringsStack(1:count),', ');
                    count = count + 1;
                    cache.saveVariable(data,stringStackStr);
                end
            end
        end

    end
end