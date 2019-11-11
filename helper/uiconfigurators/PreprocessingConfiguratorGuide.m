%this class retrieves a preprocessing algorithm from the UI
%this file duplicats the PreprocessingConfigurator and should be removed as
%soon as Matlab releases support for datacursor mode using App Designer
classdef PreprocessingConfiguratorGuide < handle

    properties (Access = private)
        %data
        columnNames;
        
        %algorithms
        algorithms;
        
        %ui
        signalsList;
        algorithmsList;
        algorithmVariablesTable;
        
        %state
        currentAlgorithmVariables;
    end
    
    methods (Access = public)
        function obj = PreprocessingConfiguratorGuide(algorithms, signalsList,algorithmsList,algorithmVariablesTable)
            obj.algorithms = algorithms;
            obj.signalsList = signalsList;
            obj.algorithmsList = algorithmsList;
            obj.algorithmVariablesTable = algorithmVariablesTable;
            
            obj.algorithmsList.Callback = @obj.handleSelectedAlgorithmChanged;
            
            obj.fillAlgorithmsList();
            obj.updateSelectedAlgorithm();
            obj.updateAlgorithmVariablesTable();
        end
        
        function setDefaultSignals(obj)
            dataLoader = DataLoader();
            dataFiles = Helper.ListDataFiles();
            if ~isempty(dataFiles)
                fileName = dataFiles{1};
                [~, obj.columnNames] = dataLoader.loadData(fileName);
            end
            obj.fillSignalsList();
        end
        
        function setSignals(obj,columnNames)
            obj.columnNames = columnNames;
            obj.fillSignalsList();
        end
        
        function algorithm = getCurrentAlgorithm(obj)
            idx = obj.algorithmsList.Value;
            algorithm = obj.algorithms{idx};
        end
        
        function signalIdxs = getSelectedSignalIdxs(obj)
            signalIdxs = obj.signalsList.Value;
        end
        
        function algorithm = createAlgorithmWithUIParameters(obj)
            algorithm = obj.getCurrentAlgorithm();
            
            data = obj.algorithmVariablesTable.Data;
            for i = 1 : size(data,1)
                variableName = data{i,1};
                variableValue = data{i,2};
                property = Property(variableName,variableValue);
                algorithm.setProperty(property);
            end
            
            selectedSignals = obj.getSelectedSignalIdxs();
            axisSelector = AxisSelector();
            axisSelector.axes = selectedSignals;
            
            axisSelector.addNextAlgorithm(algorithm);
            algorithm = CompositeAlgorithm(axisSelector,{algorithm});
        end
    end
    
    methods (Access = private)
        
        %ui
        function fillAlgorithmsList(obj)
            obj.algorithmsList.String = Helper.GenerateAlgorithmNamesArray(obj.algorithms);
        end
        
        function fillSignalsList(obj)
            obj.signalsList.String = obj.columnNames;
        end
        
        function updateAlgorithmVariablesTable(obj)
            obj.algorithmVariablesTable.Data = Helper.PropertyArrayToCellArray(obj.currentAlgorithmVariables);
        end
        
        function updateSelectedAlgorithm(obj)
            algorithm = obj.getCurrentAlgorithm();
            obj.currentAlgorithmVariables = algorithm.getEditableProperties();
        end
        
        %methods
        
        function fillsignalList(obj)
            obj.signalsList.String = obj.columnNames;
        end        
        
        %handles
        function handleSelectedAlgorithmChanged(obj,~,~)
            obj.updateSelectedAlgorithm();
            obj.updateAlgorithmVariablesTable();
        end
    end
end