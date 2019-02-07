%this class retrieves a preprocessing computer from the UI
classdef ComputerConfigurator < handle

    properties (Access = private)
        computersList;
        computersPropertiesTable;
        currentComputerProperties;
        
        propertiesPerComputer;
        propertyMaps;
    end
    
    properties (Access = public)    
        computers;
    end
    
    methods (Access = public)
        function obj = ComputerConfigurator(computers, computersList,computersPropertiesTable)
            obj.computers = computers;
            obj.computersList = computersList;
            obj.computersPropertiesTable = computersPropertiesTable;
            
            obj.computersPropertiesTable.CellEditCallback = @obj.handlePropertiesTableEditFinished;
            obj.computersList.ValueChangedFcn = @obj.handleSelectionChanged;
            
            if ~isempty(obj.computers)
                obj.createPropertiesPerComputer();
                obj.reloadUI();
            end
        end
        
        function reloadUI(obj)
            obj.fillComputersList();
            if (isempty(obj.computersList.Value) && ~isempty(obj.computersList.Items))
                obj.computersList.Value = obj.computersList.Items{1};
                obj.updateSelectedComputer();
                obj.updatePropertiesTable();
            end
        end
        
        function computer = createComputerWithUIParameters(obj)
            computer = obj.getSelectedComputer();
            
            data = obj.computersPropertiesTable.Data;
            for i = 1 : size(data,1)
                propertyName = data{i,1};
                propertyValue = data{i,2};
                property = Property(propertyName,propertyValue);
                computer.setProperty(property);
            end
        end
        
        function idx = getSelectedComputerIdx(obj)
            idxStr = obj.computersList.Value;
            [~,idx] = ismember(idxStr,obj.computersList.Items);
        end

        function computer = getSelectedComputer(obj)
            idx = obj.getSelectedComputerIdx();
            computer = obj.computers{idx};
        end
        
        function addComputer(obj,computer)
            obj.computers{end+1} = computer;
            propertiesCellArray = computer.listAllProperties();
            obj.propertiesPerComputer{end+1} = propertiesCellArray;
            allComputers = computer.listAllComputers();
            obj.propertyMaps{end+1} = obj.createPropertiesMapForPropertiesCellArray(propertiesCellArray,allComputers);
            obj.reloadUI();
        end
        
        function removeSelectedComputer(obj)
            idx = obj.getSelectedComputer;
            obj.computers{idx} = [];
            obj.reloadUI();
        end
    end
    
    methods(Access = private)
        
        function createPropertiesPerComputer(obj)
            nComputers = length(obj.computers);
            obj.propertiesPerComputer = cell(1,nComputers);
            for i = 1 : nComputers
                computer = obj.computers{i};
                propertiesCellArray = computer.listAllProperties();
                obj.propertiesPerComputer{i} = propertiesCellArray;
                allComputers = computer.listAllComputers();
                obj.propertyMaps{i} = obj.createPropertiesMapForPropertiesCellArray(propertiesCellArray,allComputers);
            end
        end
        
        function propertiesMap = createPropertiesMapForPropertiesCellArray(~,propertiesCellArray,allComputers)
            nTotalProperties = cellfun('length',propertiesCellArray);
            nTotalProperties = sum(nTotalProperties);
            
            nCells = length(propertiesCellArray);
            propertiesMap = cell(1,nTotalProperties);
            mappingCounter = 1;
            for i = 1 : nCells
                computerCurrentCell = allComputers{i};
                propertiesCurrentCell = propertiesCellArray{i};
                for j = 1 : length(propertiesCurrentCell)
                    property = propertiesCurrentCell(j);
                    propertiesMap{mappingCounter} = {computerCurrentCell,property};                    
                    mappingCounter = mappingCounter + 1;
                end
            end
        end
        
        function handlePropertiesTableEditFinished(obj,~,callbackData)            
            row = callbackData.Indices(1);
            currentComputerIdx = obj.getSelectedComputerIdx();
            propertiesMap = obj.propertyMaps{currentComputerIdx};
            propertyMapCell = propertiesMap{row};
            computer = propertyMapCell{1};
            property = propertyMapCell{2};            
            property.setValueWithStr(callbackData.NewData);
            computer.setProperty(property);
        end
        
        function handleSelectionChanged(obj,~,~)
            obj.updateSelectedComputer();
            obj.updatePropertiesTable();
        end
        
        function fillComputersList(obj)            
            obj.computersList.Items = Helper.generateComputerNamesArray(obj.computers);
        end
        
        function updateSelectedComputer(obj)
            computerIdx = obj.getSelectedComputerIdx;
            obj.currentComputerProperties = obj.propertiesPerComputer{computerIdx};
        end
        
        function updatePropertiesTable(obj)
            properties = horzcat(obj.currentComputerProperties{:});
            obj.computersPropertiesTable.Data = Helper.propertyArrayToCellArray(properties);
        end
        
        function nProperties = countNProperties(~,propertiesCell)
            nCells = length(propertiesCell);
            nProperties = 0;
            for i = 1 : nCells
                nProperties = nProperties + length(propertiesCell{i});
            end
        end
    end
end