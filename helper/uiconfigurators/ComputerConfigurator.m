%this class retrieves a preprocessing computer from the UI
classdef ComputerConfigurator < handle

    properties (Access = private)
        computersList;
        computersPropertiesTable;
        currentComputerProperties;
    end
    
    properties (Access = public)    
        computers;
        delegate;
    end
    
    methods (Access = public)
        function obj = ComputerConfigurator(computers, computersList,...
                computersPropertiesTable, delegate)
            
            obj.computers = computers;
            obj.computersList = computersList;
            obj.computersPropertiesTable = computersPropertiesTable;
            
            obj.computersPropertiesTable.CellEditCallback = @obj.handlePropertiesTableEditFinished;
            obj.computersList.ValueChangedFcn = @obj.handleSelectionChanged;
            
            if nargin > 3
                obj.delegate = delegate;
            end
            
            if ~isempty(obj.computers)
                obj.reloadUI();
            end
        end
        
        function reloadUI(obj)
            obj.fillComputersList();
            if ~isempty(obj.computersList.Items)
                if isempty(obj.computersList.Value)
                    obj.computersList.Value = obj.computersList.Items{1};
                end
                computerIdx = obj.getSelectedComputerIdx();
                
                obj.currentComputerProperties = obj.computers{computerIdx}.getEditableProperties();
                obj.updatePropertiesTable();
            end
        end
        
        function computer = createComputerWithUIParameters(obj)
            computer = obj.getSelectedComputer();
            computer = computer.copy();

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
            if isempty(idx)
                computer = [];
            else
                computer = obj.computers{idx};
            end
        end
        
        function addComputer(obj,computer)
            obj.computers{end+1} = computer;
        end
        
        function removeSelectedComputer(obj)
            idx = obj.getSelectedComputerIdx();
            obj.computers{idx} = [];
            obj.reloadUI();
        end
    end
    
    methods(Access = private)
        
        function handlePropertiesTableEditFinished(obj,~,callbackData)            
            row = callbackData.Indices(1);
            computer = obj.getSelectedComputer();
            if ~isempty(computer)
                property = obj.currentComputerProperties(row);
                property.value = callbackData.NewData;
                computer.setProperty(property);
            end
        end
        
        function handleSelectionChanged(obj,~,~)
            computer = obj.getSelectedComputer();
            if ~isempty(computer)
                obj.currentComputerProperties = computer.getEditableProperties();
                obj.updatePropertiesTable();
            end
            obj.delegate.handleAlgorithmChanged(computer,obj);
        end
        
        function fillComputersList(obj)            
            obj.computersList.Items = Helper.generateComputerNamesArray(obj.computers);
        end
                
        function updatePropertiesTable(obj)
            obj.computersPropertiesTable.Data = Helper.propertyArrayToCellArray(obj.currentComputerProperties);
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