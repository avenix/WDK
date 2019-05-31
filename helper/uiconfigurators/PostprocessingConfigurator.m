%this class retrieves a post computer from the UI
classdef PostprocessingConfigurator < handle
    
    properties (Access = public)
        computers;
    end
    
    properties (Access = private)
        uiElements;
        currentComputerProperties;
        labelMappingConfigurator;
    end
    
    methods (Access = public)
        function obj = PostprocessingConfigurator(computers,uiElements,labeling)
            obj.computers = computers;
            obj.uiElements = uiElements;
            
            labelMapping = LabelMapper.CreateLabelMapperWithLabeling(labeling,'labeling');
            obj.labelMappingConfigurator = LabelMappingConfigurator(labelMapping,...
                uiElements.annotationMappingList,uiElements.annotationMappingTable);
            
            obj.uiElements.computersPropertiesTable.CellEditCallback = @obj.handlePropertiesTableEditFinished;
            obj.uiElements.computersList.ValueChangedFcn = @obj.handleSelectionChanged;
            
            if ~isempty(obj.computers)
                obj.fillComputersList();
                obj.reloadUI();
            end
        end
        
        function setCurrentLabeling(obj,labeling)
            
            labelMapping = LabelMapper.CreateLabelMapperWithLabeling(labeling,'labeling');
            obj.labelMappingConfigurator.setLabelings(labelMapping);
        end
        
        function reloadUI(obj)
            if ~isempty(obj.uiElements.computersList.Items)
                if isempty(obj.uiElements.computersList.Value)
                    obj.uiElements.computersList.Value = obj.uiElements.computersList.Items{1};
                end
                computerIdx = obj.getSelectedComputerIdx();
                currentComputer = obj.computers{computerIdx};
                obj.currentComputerProperties = currentComputer.getEditableProperties();
                obj.updatePropertiesTable();
                obj.updatePanelsVisibility(currentComputer);
            end
        end
        
        function computer = createComputerWithUIParameters(obj)
            computer = obj.getSelectedComputer();
            computer = computer.copy();
            
            if isa(computer,'LabelMapper')
                computer = obj.labelMappingConfigurator.createLabelMapperFromUI();
            else
                obj.updateComputerPropertiesWithTable(computer);
            end
        end
        
        function idx = getSelectedComputerIdx(obj)
            idxStr = obj.uiElements.computersList.Value;
            [~,idx] = ismember(idxStr,obj.uiElements.computersList.Items);
        end
        
        function computer = getSelectedComputer(obj)
            idx = obj.getSelectedComputerIdx();
            computer = obj.computers{idx};
        end
    end
    
    methods(Access = private)
        
        function b = isLabelMapperMode(obj)
            computer = obj.getSelectedComputer();
            b = isa(computer,'LabelMapper');
        end
        
        function updateComputerPropertiesWithTable(obj,computer)
            data = obj.uiElements.computersPropertiesTable.Data;
            for i = 1 : size(data,1)
                propertyName = data{i,1};
                propertyValue = data{i,2};
                property = Property(propertyName,propertyValue);
                computer.setProperty(property);
            end
        end
        
        function handlePropertiesTableEditFinished(obj,~,callbackData)
            if ~obj.isLabelMapperMode()
                row = callbackData.Indices(1);
                computer = obj.getSelectedComputer();
                property = obj.currentComputerProperties(row);
                property.value = callbackData.NewData;
                computer.setProperty(property);
            end
        end
        
        function handleSelectionChanged(obj,~,~)
            computer = obj.getSelectedComputer();
            obj.updatePanelsVisibility(computer);
            obj.currentComputerProperties = computer.getEditableProperties();
            obj.updatePropertiesTable();
        end
        
        function updatePanelsVisibility(obj,computer)
            if isa(computer,'LabelMapper')
                obj.uiElements.annotationsPanel.Visible = 'on';
            else
                obj.uiElements.annotationsPanel.Visible = 'off';
            end
        end
        
        function fillComputersList(obj)
            obj.uiElements.computersList.Items = Helper.generateComputerNamesArray(obj.computers);
        end
        
        function updatePropertiesTable(obj)
            obj.uiElements.computersPropertiesTable.ColumnName = {'Computer','Variable'};
            obj.uiElements.computersPropertiesTable.Data = Helper.propertyArrayToCellArray(obj.currentComputerProperties);
        end
    end
end