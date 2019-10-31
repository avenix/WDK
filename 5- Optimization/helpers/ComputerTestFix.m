classdef ComputerTestFix <  handle
    properties (Access = public)
        computer;
        propertyTestFixes;
    end
    
    properties (Dependent)
        nCombinations;
    end
    
    methods
        function n = get.nCombinations(obj)
            n = 1;
            for i = 1 : length(obj.propertyTestFixes)
                propertyTestFix = obj.propertyTestFixes(i);
                n = n * propertyTestFix.nCombinations;
            end
        end
    end
    
    methods (Access = public)
        function obj = ComputerTestFix(computer)
            if nargin > 0
                obj.computer = computer;
                obj.createDefaultPropertyTestFixes();
            end
        end
        
        function computers = generateCombinations(obj)
            if isempty(obj.propertyTestFixes)
                computers = {obj.computer.copy()};
            else
                computers = cell(1,obj.nCombinations);
                nProperties = length(obj.propertyTestFixes);
                computerCount = 1;
                
                stack = Stack();
                stack.push({[],0});
                
                while ~stack.isempty()
                    currentElement = stack.pop();
                    currentElementProperties = currentElement{1};
                    propertyCount = currentElement{2} + 1;
                    
                    if propertyCount > nProperties
                        newComputer = obj.computer.copy();
                        newComputer.setProperties(currentElementProperties);
                        computers{computerCount} = newComputer;
                        computerCount = computerCount + 1;
                    else
                        propertyTestFix = obj.propertyTestFixes(propertyCount);
                        properties = propertyTestFix.generateCombinations();
                        
                        for i = length(properties) : -1 : 1
                            property = properties(i);
                            stack.push({[currentElementProperties,property],propertyCount});
                        end
                    end
                end
            end
        end
    end
    
    methods (Access = private)
        
        function createDefaultPropertyTestFixes(obj)
            
            properties = obj.computer.getEditableProperties();
            nProperties = length(properties);
            obj.propertyTestFixes = repmat(PropertyTestFix,1,nProperties);
            
            for i = 1 : nProperties
                property = properties(i);
                testFix = PropertyTestFix(property.name);
                testFix.minValue = property.minValue;
                testFix.maxValue = property.maxValue;
                obj.propertyTestFixes(i) = testFix;
            end
        end
    end
    
    methods (Static)
        function n = CountNCombinations(testFixes)
            n = 0;
            for i = 1 : length(testFixes)
                testFix = testFixes(i);
                n = n + testFix.nCombinations;
            end
        end
    end
end