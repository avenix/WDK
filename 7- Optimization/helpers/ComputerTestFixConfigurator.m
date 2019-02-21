%this class retrieves a preprocessing computer from the UI
classdef ComputerTestFixConfigurator < handle

    properties (Access = private)
        computersTable;
        computersPropertiesTable;
        currentComputerTestFix;
    end
    
    properties (Access = public)    
        computerTestFixes;
        propertyTestFixes;
    end
    
    methods (Access = public)
        function obj = ComputerTestFixConfigurator(computers, computersTable,computersPropertiesTable)

            obj.computersTable = computersTable;
            obj.computersPropertiesTable = computersPropertiesTable;
            
            obj.computersPropertiesTable.CellEditCallback = @obj.handlePropertiesTableEditFinished;
            obj.computersTable.CellSelectionCallback = @obj.handleSelectionChanged;
            
            if ~isempty(computers)
                obj.createComputerTestFixes(computers);
                obj.fillComputerTestFixesTable(computers);
            end
        end
        
        function testFixes = createComputerTestFixWithUIParameters(obj)
            
            selectedComputers = obj.computersTable.Data{:,2};
            testFixes = obj.computerTestFixes(selectedComputers);
            
            %{
            computer = obj.getSelectedComputer();
            computer = computer.copy();

            data = obj.computersPropertiesTable.Data;
            for i = 1 : size(data,1)
                propertyName = data{i,1};
                minValue = data{i,2};
                interval = data{i,3};
                maxValue = data{i,4};
                property = Property(propertyName,minValue,interval,maxValue);
                computer.setProperty(property);
            end
            %}
        end
        %{
        function idx = getSelectedComputerIdx(obj)
            idxStr = obj.computersTable.Value;
            [~,idx] = ismember(idxStr,obj.computersTable.Items);
        end

        function computer = getSelectedComputer(obj)
            idx = obj.getSelectedComputerIdx();
            computer = obj.computers{idx};
        end
        %}
        
    end
    
    methods(Access = private)

        function createComputerTestFixes(obj,computers)
            nComputers = length(computers);
            obj.computerTestFixes = repmat(ComputerTestFix, 1,nComputers);
            for i = 1 : nComputers
                computer = computers{i};
                testFix = ComputerTestFix(computer);
                obj.computerTestFixes(i) = testFix;
            end
        end
        
        function fillComputerTestFixesTable(obj,computers)
            nComputers = length(computers);
            computerNames = Helper.generateComputerNamesArray(computers);
            obj.computersTable.Data = table(computerNames',true(nComputers,1));
        end

        function handlePropertiesTableEditFinished(obj,~,event)    
            row = event.Indices(1);
            col = event.Indices(2);
            propertyTestFix = obj.currentComputerTestFix.propertyTestFixes(row);
            if col == 2
                propertyTestFix.minValue = event.NewData;
            elseif col == 3
                propertyTestFix.interval = event.NewData;
            else
                propertyTestFix.maxValue = event.NewData;
            end
        end
        
        function handleSelectionChanged(obj,~,event)
            
            idx = event.Indices(1);
            obj.currentComputerTestFix = obj.computerTestFixes(idx);
            
            numProperties = length(obj.currentComputerTestFix.propertyTestFixes);
            cellArray = cell(numProperties,4);
            
            for i = 1 : numProperties
                propertyTestFix = obj.currentComputerTestFix.propertyTestFixes(i);
                cellArray{i,1} = char(propertyTestFix.name);
                cellArray{i,2} = propertyTestFix.minValue;
                cellArray{i,3} = propertyTestFix.interval;
                cellArray{i,4} = propertyTestFix.maxValue;
            end
            
            obj.computersPropertiesTable.Data = cellArray;
        end
    end
end