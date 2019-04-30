%this class retrieves a preprocessing computer from the UI
classdef PostprocessingConfigurator < handle
        
    properties (Access = public)
        computers;
    end
    
    properties (Access = private)
        computersList;
        computersPropertiesTable;
        currentComputerProperties;
        currentLabelGrouping;
    end
   
    methods (Access = public)
        function obj = PostprocessingConfigurator(computers,computersList,computersPropertiesTable,currentLabelGrouping)
            obj.computers = computers;
            obj.computersList = computersList;
            obj.computersPropertiesTable = computersPropertiesTable;
            obj.currentLabelGrouping = currentLabelGrouping;

            obj.computersPropertiesTable.CellEditCallback = @obj.handlePropertiesTableEditFinished;
            obj.computersList.ValueChangedFcn = @obj.handleSelectionChanged;
            
            if ~isempty(obj.computers)
                obj.fillComputersList();
                obj.reloadUI();
            end
        end
        
        function setCurrentLabelGrouping(obj,labelGrouping)
            obj.currentLabelGrouping = labelGrouping;
            
            if obj.isLabelMapperMode()
                obj.updatePropertiesTableWithLabelGrouping();
            end
        end
        
        function reloadUI(obj)
            if ~isempty(obj.computersList.Items)
                if isempty(obj.computersList.Value)
                    obj.computersList.Value = obj.computersList.Items{1};
                end
                computerIdx = obj.getSelectedComputerIdx();
                currentComputer = obj.computers{computerIdx};
                obj.currentComputerProperties = currentComputer.getEditableProperties();
                obj.updatePropertiesTable(currentComputer);
            end
        end
        
        function computer = createComputerWithUIParameters(obj)
            computer = obj.getSelectedComputer();
            computer = computer.copy();
            
            if isa(computer,'LabelMapper')
                obj.setLabelMapperProperties(computer);
            else
                obj.updateComputerPropertieFromsInTable(computer);
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
    end
    
    methods(Access = private)
        
        function b = isLabelMapperMode(obj)
            computer = obj.getSelectedComputer();
            b = isa(computer,'LabelMapper');
        end
        
        function setLabelMapperProperties(obj,labelMapper)
            targetClassesMap = containers.Map();
            data = obj.computersPropertiesTable.Data;
            
            nSourceClasses = size(data,1);
            labelMapper.classNames = cell(1,nSourceClasses);
            
            %maps target class strings to integers
            targetClassCount = 0;
            for sourceClass = 1 : nSourceClasses
                targetClassStr = data{sourceClass,2};
                if ~strcmp(targetClassStr, Constants.kNullClassGroupStr) && ~isKey(targetClassesMap,targetClassStr)
                    targetClassCount = targetClassCount + 1;
                    targetClassesMap(targetClassStr) = targetClassCount;
                    labelMapper.classNames{targetClassCount} = targetClassStr;
                end
            end
            targetClassesMap(Constants.kNullClassGroupStr) = ClassesMap.kNullClass;
            labelMapper.classNames = labelMapper.classNames(1:targetClassCount);
            
            %adds mapings to labelMapper
            for sourceClass = 1 : nSourceClasses
                targetClassStr = data{sourceClass,2};
                targetClass = targetClassesMap(targetClassStr);
                labelMapper.addMapping(sourceClass,targetClass);
            end
        end
        
        function updateComputerPropertieFromsInTable(obj,computer)
            data = obj.computersPropertiesTable.Data;
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
            
            obj.currentComputerProperties = computer.getEditableProperties();
            obj.updatePropertiesTable();
        end
        
        function fillComputersList(obj)
            obj.computersList.Items = Helper.generateComputerNamesArray(obj.computers);
        end
        
        function updatePropertiesTable(obj,currentComputer)
            if isa(currentComputer,'LabelMapper')
                obj.updatePropertiesTableWithLabelGrouping();
            else
                obj.computersPropertiesTable.ColumnName = {'Computer','Variable'};
                obj.computersPropertiesTable.Data = Helper.propertyArrayToCellArray(obj.currentComputerProperties);
            end
        end
        
        function updatePropertiesTableWithLabelGrouping(obj)
            numClasses = obj.currentLabelGrouping.numClasses;
            data = cell(numClasses,2);
            obj.computersPropertiesTable.ColumnName = {'Source Classes','Target Classes'};
            data(:,1) = obj.currentLabelGrouping.classNames;
            data(:,2) = obj.currentLabelGrouping.classNames;
            obj.computersPropertiesTable.Data = data;
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