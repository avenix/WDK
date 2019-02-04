%this class retrieves a preprocessing algorithm from the UI
classdef AlgorithmConfigurator < handle

    properties (Access = private)
        algorithmsList;
        algorithmsVariablesTable;
        currentAlgorithmVariables;
    end
    
    properties (Access = public)    
        algorithms;
    end
    
    methods (Access = public)
        function obj = AlgorithmConfigurator(algorithms, algorithmsList,algorithmsVariablesTable)
            obj.algorithms = algorithms;
            obj.algorithmsList = algorithmsList;
            obj.algorithmsVariablesTable = algorithmsVariablesTable;
            
            if ~isempty(obj.algorithms)
                obj.reloadUI();
            end
        end
        
        function reloadUI(obj)
            obj.fillAlgorithmsList();
            obj.algorithmsList.Value = obj.algorithmsList.Items{1};
            obj.updateSelectedAlgorithm();
            obj.updateAlgorithmVariablesTable();
        end
        
        function algorithm = createAlgorithmWithUIParameters(obj)
            algorithm = obj.getCurrentAlgorithm();
            
            data = obj.algorithmsVariablesTable.Data;
            for i = 1 : size(data,1)
                variableName = data{i,1};
                variableValue = data{i,2};
                property = Property(variableName,variableValue);
                algorithm.setProperty(property);
            end
        end
    end
    
    methods(Access = private)
        
        function fillAlgorithmsList(obj)            
            obj.algorithmsList.Items = Helper.generateComputerNamesArray(obj.algorithms);
        end

        function algorithm = getCurrentAlgorithm(obj)
            idxStr = obj.algorithmsList.Value;
            [~,idx] = ismember(idxStr,obj.algorithmsList.Items);
            algorithm = obj.algorithms{idx};
        end
        
        function updateSelectedAlgorithm(obj)
            segmentationStrategy = obj.getCurrentAlgorithm();
            obj.currentAlgorithmVariables = segmentationStrategy.getEditableProperties();
        end
        
        function updateAlgorithmVariablesTable(obj)
            obj.algorithmsVariablesTable.Data = Helper.propertyArrayToCellArray(obj.currentAlgorithmVariables);
        end
        
    end
end