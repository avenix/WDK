classdef CompositeComputer < Computer
    
    properties (Access = public)
        root;
        lastComputers;
    end

    properties (Dependent)
        nComputers;
    end
    
    methods
        function n = get.nComputers(obj)
            n = length(obj.allComputers);
        end
    end
    
    methods (Access = public)
        function obj = CompositeComputer(firstElement,lastComputers)

            if nargin > 0
                obj.root = firstElement;
                obj.lastComputers = lastComputers;
            else
                obj.root = NoOp();
                obj.lastComputers = {obj.root};
            end
            
            obj.name = "Composite";
        end
        
        function str = toString(obj)
            
            stack = Stack();
            stack.push(obj.root);
            
            nStrings = Computer.CountComputers(obj.root);
            
            strings = cell(1,nStrings);
            count = 1;
            while ~stack.isempty()
                computer = stack.pop();
                strings{count} = computer.toString();
                count = count + 1;
                for i = 1 : length(computer.nextComputers)
                    stack.push(computer.nextComputers{i});
                end
            end
            
            str = Helper.cellArrayToString(strings,', ');
        end
        
        function dataOut = compute(obj,dataIn)
            dataOut = Computer.ExecuteChain(obj.root,dataIn);
        end
        
        function metrics = computeMetrics(obj,dataIn)
            [~,metrics] = Computer.ExecuteChain(obj.root,dataIn);
        end
        
        function properties = getEditableProperties(obj)
            
            nElements = obj.countElements();
            properties = cell(1,nElements);
            
            stack = Stack();
            stack.push(obj.root);
            
            counter = 1;
            while ~stack.isempty()
                computer = stack.pop();
                properties{counter} = computer.getEditableProperties();
                counter = counter + 1;
                for i = 1 : length(computer.nextComputers)
                    stack.push(computer.nextComputers(i));
                end
            end
        end
    end
    
end
