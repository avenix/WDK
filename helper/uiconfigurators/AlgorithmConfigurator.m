%this class retrieves a preprocessing algorithm from the UI
classdef AlgorithmConfigurator < handle

    properties (Access = private)
        algorithmsList;
        algorithmsPropertiesTable;
        currentAlgorithmProperties;
    end
    
    properties (Access = public)    
        algorithms;
        delegate;
    end
    
    methods (Access = public)
        function obj = AlgorithmConfigurator(algorithms, algorithmsList,...
                algorithmsPropertiesTable, delegate)
            
            obj.algorithms = algorithms;
            obj.algorithmsList = algorithmsList;
            obj.algorithmsPropertiesTable = algorithmsPropertiesTable;
            
            obj.algorithmsPropertiesTable.CellEditCallback = @obj.handlePropertiesTableEditFinished;
            obj.algorithmsList.ValueChangedFcn = @obj.handleSelectionChanged;
            
            if nargin > 3
                obj.delegate = delegate;
            end
            
            if ~isempty(obj.algorithms)
                obj.reloadUI();
            end
        end
        
        function reloadUI(obj)
            obj.fillAlgorithmsList();
            if ~isempty(obj.algorithmsList.Items)
                if isempty(obj.algorithmsList.Value)
                    obj.algorithmsList.Value = obj.algorithmsList.Items{1};
                end
                algorithmIdx = obj.getSelectedAlgorithmIdx();
                
                obj.currentAlgorithmProperties = obj.algorithms{algorithmIdx}.getEditableProperties();
                obj.updatePropertiesTable();
            end
        end
        
        function algorithm = createAlgorithmWithUIParameters(obj)
            algorithm = obj.getSelectedAlgorithm();
            algorithm = algorithm.copy();

            data = obj.algorithmsPropertiesTable.Data;
            for i = 1 : size(data,1)
                propertyName = data{i,1};
                propertyValue = data{i,2};
                property = Property(propertyName,propertyValue);
                algorithm.setProperty(property);
            end
        end
        
        function idx = getSelectedAlgorithmIdx(obj)
            idxStr = obj.algorithmsList.Value;
            [~,idx] = ismember(idxStr,obj.algorithmsList.Items);
        end

        function algorithm = getSelectedAlgorithm(obj)
            idx = obj.getSelectedAlgorithmIdx();
            if isempty(idx)
                algorithm = [];
            else
                algorithm = obj.algorithms{idx};
            end
        end
        
        function addAlgorithm(obj,algorithm)
            obj.algorithms{end+1} = algorithm;
        end
        
        function removeSelectedAlgorithm(obj)
            idx = obj.getSelectedAlgorithmIdx();
            obj.algorithms{idx} = [];
            obj.reloadUI();
        end
    end
    
    methods(Access = private)
        
        function handlePropertiesTableEditFinished(obj,~,callbackData)            
            row = callbackData.Indices(1);
            algorithm = obj.getSelectedAlgorithm();
            if ~isempty(algorithm)
                property = obj.currentAlgorithmProperties(row);
                property.value = callbackData.NewData;
                algorithm.setProperty(property);
            end
        end
        
        function handleSelectionChanged(obj,~,~)
            algorithm = obj.getSelectedAlgorithm();
            if ~isempty(algorithm)
                obj.currentAlgorithmProperties = algorithm.getEditableProperties();
                obj.updatePropertiesTable();
            end
            obj.delegate.handleAlgorithmChanged(algorithm,obj);
        end
        
        function fillAlgorithmsList(obj)            
            obj.algorithmsList.Items = Helper.generateAlgorithmNamesArray(obj.algorithms);
        end
                
        function updatePropertiesTable(obj)
            obj.algorithmsPropertiesTable.Data = Helper.propertyArrayToCellArray(obj.currentAlgorithmProperties);
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