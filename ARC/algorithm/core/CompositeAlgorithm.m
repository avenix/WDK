classdef CompositeAlgorithm < Algorithm
    
    properties (Access = public)
        root;
        lastAlgorithms;
    end

    properties (Dependent)
        nAlgorithms;
    end
    
    methods
        function n = get.nAlgorithms(obj)
            n = length(obj.allAlgorithms);
        end
    end
    
    methods (Access = public)
        function obj = CompositeAlgorithm(firstElement,lastAlgorithms)

            if nargin > 0
                obj.root = firstElement;
                obj.lastAlgorithms = lastAlgorithms;
            else
                obj.root = NoOp();
                obj.lastAlgorithms = {obj.root};
            end
            
            obj.name = "Composite";
        end
        
        function str = toString(obj)
            
            stack = Stack();
            stack.push(obj.root);
            
            nStrings = Algorithm.CountAlgorithms(obj.root);
            
            strings = cell(1,nStrings);
            count = 1;
            while ~stack.isempty()
                algorithm = stack.pop();
                strings{count} = algorithm.toString();
                count = count + 1;
                for i = 1 : length(algorithm.nextAlgorithms)
                    stack.push(algorithm.nextAlgorithms{i});
                end
            end
            
            str = Helper.cellArrayToString(strings,', ');
        end
        
        function dataOut = compute(obj,dataIn)
            dataOut = Algorithm.ExecuteChain(obj.root,dataIn);
        end
        
        function metrics = computeMetrics(obj,dataIn)
            [~,metrics] = Algorithm.ExecuteChain(obj.root,dataIn);
        end
        
        function properties = getEditableProperties(obj)
            
            nElements = obj.countElements();
            properties = cell(1,nElements);
            
            stack = Stack();
            stack.push(obj.root);
            
            counter = 1;
            while ~stack.isempty()
                algorithm = stack.pop();
                properties{counter} = algorithm.getEditableProperties();
                counter = counter + 1;
                for i = 1 : length(algorithm.nextAlgorithms)
                    stack.push(algorithm.nextAlgorithms(i));
                end
            end
        end
    end
    
end
