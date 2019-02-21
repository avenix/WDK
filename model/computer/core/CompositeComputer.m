classdef CompositeComputer < Computer
    
    properties (Access = public)
        root;%first element in the flow
    end
    
    properties (Access = private)
        lastComputer;
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
        function obj = CompositeComputer(firstElement)
            
            obj.root = NoOp();
            
            if nargin > 0
                obj.addComputer(firstElement);
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
        
        function addComputer(obj,computer)
            if isempty(obj.root.nextComputers)
                obj.root.addNextComputer(computer);
            end
            
            if ~isempty(obj.lastComputer)
                obj.lastComputer.addNextComputer(computer);
            end
            obj.lastComputer = computer;
        end
        
        function computer = getComputerWithIdx(obj,idx)
            computer = obj.allComputers{idx};
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
    
    methods (Static)
        function computer = CreateComputerWithSequence(sequence)
            if isempty(sequence)
                computer = [];
            else
                computer = CompositeComputer();
                
                for i = 1 : length(sequence)
                    computer.addComputer(sequence{i});
                end
            end
        end
    end
end