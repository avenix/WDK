%this class retrieves a post algorithm from the UI
classdef PostprocessingConfigurator < handle
    
    properties (Access = public)
        algorithms;
    end
    
    properties (Access = private)
        uiElements;
        currentAlgorithmProperties;
        labelMappingConfigurator;
    end
    
    methods (Access = public)
        function obj = PostprocessingConfigurator(algorithms,uiElements,labeling)
            obj.algorithms = algorithms;
            obj.uiElements = uiElements;
            
            labelMapping = LabelMapper.CreateLabelMapperWithLabeling(labeling,'labeling');
            obj.labelMappingConfigurator = LabelMappingConfigurator(labelMapping,...
                uiElements.annotationMappingList,uiElements.annotationMappingTable);
            
            obj.uiElements.algorithmsPropertiesTable.CellEditCallback = @obj.handlePropertiesTableEditFinished;
            obj.uiElements.algorithmsList.ValueChangedFcn = @obj.handleSelectionChanged;
            
            if ~isempty(obj.algorithms)
                obj.fillAlgorithmsList();
                obj.reloadUI();
            end
        end
        
        function setCurrentLabeling(obj,labeling)
            
            labelMapping = LabelMapper.CreateLabelMapperWithLabeling(labeling,'labeling');
            obj.labelMappingConfigurator.setLabelings(labelMapping);
        end
        
        function reloadUI(obj)
            if ~isempty(obj.uiElements.algorithmsList.Items)
                if isempty(obj.uiElements.algorithmsList.Value)
                    obj.uiElements.algorithmsList.Value = obj.uiElements.algorithmsList.Items{1};
                end
                algorithmIdx = obj.getSelectedAlgorithmIdx();
                currentAlgorithm = obj.algorithms{algorithmIdx};
                obj.currentAlgorithmProperties = currentAlgorithm.getEditableProperties();
                obj.updatePropertiesTable();
                obj.updatePanelsVisibility(currentAlgorithm);
            end
        end
        
        function algorithm = createAlgorithmWithUIParameters(obj)
            algorithm = obj.getSelectedAlgorithm();
            algorithm = algorithm.copy();
            
            if isa(algorithm,'LabelMapper')
                algorithm = obj.labelMappingConfigurator.createLabelMapperFromUI();
            else
                obj.updateAlgorithmPropertiesWithTable(algorithm);
            end
        end
        
        function idx = getSelectedAlgorithmIdx(obj)
            idxStr = obj.uiElements.algorithmsList.Value;
            [~,idx] = ismember(idxStr,obj.uiElements.algorithmsList.Items);
        end
        
        function algorithm = getSelectedAlgorithm(obj)
            idx = obj.getSelectedAlgorithmIdx();
            algorithm = obj.algorithms{idx};
        end
    end
    
    methods(Access = private)
        
        function b = isLabelMapperMode(obj)
            algorithm = obj.getSelectedAlgorithm();
            b = isa(algorithm,'LabelMapper');
        end
        
        function updateAlgorithmPropertiesWithTable(obj,algorithm)
            data = obj.uiElements.algorithmsPropertiesTable.Data;
            for i = 1 : size(data,1)
                propertyName = data{i,1};
                propertyValue = data{i,2};
                property = Property(propertyName,propertyValue);
                algorithm.setProperty(property);
            end
        end
        
        function handlePropertiesTableEditFinished(obj,~,callbackData)
            if ~obj.isLabelMapperMode()
                row = callbackData.Indices(1);
                algorithm = obj.getSelectedAlgorithm();
                property = obj.currentAlgorithmProperties(row);
                property.value = callbackData.NewData;
                algorithm.setProperty(property);
            end
        end
        
        function handleSelectionChanged(obj,~,~)
            algorithm = obj.getSelectedAlgorithm();
            obj.updatePanelsVisibility(algorithm);
            obj.currentAlgorithmProperties = algorithm.getEditableProperties();
            obj.updatePropertiesTable();
        end
        
        function updatePanelsVisibility(obj,algorithm)
            if isa(algorithm,'LabelMapper')
                obj.uiElements.annotationsPanel.Visible = 'on';
            else
                obj.uiElements.annotationsPanel.Visible = 'off';
            end
        end
        
        function fillAlgorithmsList(obj)
            obj.uiElements.algorithmsList.Items = Helper.generateAlgorithmNamesArray(obj.algorithms);
        end
        
        function updatePropertiesTable(obj)
            obj.uiElements.algorithmsPropertiesTable.ColumnName = {'Algorithm','Variable'};
            obj.uiElements.algorithmsPropertiesTable.Data = Helper.propertyArrayToCellArray(obj.currentAlgorithmProperties);
        end
    end
end