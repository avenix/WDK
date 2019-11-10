%this class retrieves a preprocessing algorithm from the UI
classdef PreprocessingConfigurator < handle
    
    properties (Access = private)
        %data
        signalNames;
        
        %algorithms
        algorithms;
        currentAlgorithms;
        algorithmStrings;
        
        %ui
        signalsList;
        algorithmsList;
        algorithmVariablesTable;
        
        %state
        currentAlgorithmVariables;
        
        %observer
        delegate;
    end
    
    methods (Access = public)
        function obj = PreprocessingConfigurator(signalNames,algorithms, signalsList,...
                algorithmsList,algorithmVariablesTable,delegate)
            
            obj.signalNames = signalNames;
            obj.algorithms = algorithms;
            obj.signalsList = signalsList;
            obj.algorithmsList = algorithmsList;
            obj.algorithmVariablesTable = algorithmVariablesTable;
            obj.signalsList.ValueChangedFcn = @obj.handleSelectedSignalChanged;
            obj.algorithmsList.ValueChangedFcn = @obj.handleSelectedAlgorithmChanged;
            
            if nargin > 5
                obj.delegate = delegate;
            end
            
            if ~isempty(obj.algorithmsList)
                obj.updateSignalsList();
                obj.updateAlgorithmsList();
                obj.selectFirstAlgorithm();
                
                obj.updateSelectedAlgorithm();
                obj.updateAlgorithmVariablesTable();
            end
        end
        
        function setSignals(obj,signals)
            obj.signalNames = signals;
            obj.updateSignalsList();
        end
        
        function algorithm = getCurrentAlgorithm(obj)
            idxStr = obj.algorithmsList.Value;
            [~,idx] = ismember(idxStr,obj.algorithmsList.Items);
            if isempty(idx)
                algorithm = [];
            else
                algorithm = obj.currentAlgorithms{idx};
            end
        end
        
        function signalIdxs = getSelectedSignalIdxs(obj)
            idxStr = obj.signalsList.Value;
            [~,signalIdxs] = ismember(idxStr,obj.signalsList.Items);
        end
        
        function algorithm = createPreprocessingAlgorithmWithUIParameters(obj)
            axisSelector = obj.createAxisSelectorWithUIParameters();
            if isempty(axisSelector)
                algorithm = [];
            else
                algorithm = obj.createAlgorithmWithUIParameters();
                if isempty(algorithm)
                    algorithm = [];
                else
                    axisSelector.addNextAlgorithm(algorithm);
                    algorithm = CompositeAlgorithm(axisSelector,{algorithm});
                end
            end
        end
        
        function axisSelector = createAxisSelectorWithUIParameters(obj)
            selectedSignalIndices = obj.getSelectedSignalIdxs();
            if isempty(selectedSignalIndices)
                axisSelector = [];
            else
                axisSelector = AxisSelector();
                axisSelector.axes = selectedSignalIndices;
            end
        end
        
        function algorithm = createAlgorithmWithUIParameters(obj)
            algorithm = obj.getCurrentAlgorithm();
            if isa(algorithm,'NoOp')
                algorithm = [];
            elseif ~isempty(algorithm)
                algorithm = algorithm.copy();
                data = obj.algorithmVariablesTable.Data;
                for i = 1 : size(data,1)
                    variableName = data{i,1};
                    variableValue = data{i,2};
                    property = Property(variableName,variableValue);
                    algorithm.setProperty(property);
                end
            end
        end
        
    end
    
    methods (Access = private)
        
        %ui
        function updateSignalsList(obj)
            obj.signalsList.Items = obj.signalNames;
        end
        
        function signals = getSelectedSignals(obj)
            %returns signals in order
            [~, signalIndices] = ismember(obj.signalsList.Value,obj.signalsList.Items);
            signalIndices = sort(signalIndices);
            signals = obj.signalsList.Items(signalIndices);
        end
        
        function selectFirstAlgorithm(obj)
            if ~isempty(obj.algorithmsList.Items)
                obj.algorithmsList.Value = obj.algorithmsList.Items{1};
            end
        end
        
        function selectFirstSignal(obj)
            obj.signalsList.Value = obj.signalsList.Items{1};
        end
        
        function updateAlgorithmVariablesTable(obj)
            obj.algorithmVariablesTable.Data = Helper.propertyArrayToCellArray(obj.currentAlgorithmVariables);
        end
        
        function updateSelectedAlgorithm(obj)
            algorithm = obj.getCurrentAlgorithm();
            if isempty(algorithm)
                obj.currentAlgorithmVariables = [];
            else
                obj.currentAlgorithmVariables = algorithm.getEditableProperties();
            end
        end
        
        %methods
        function updateAlgorithmsList(obj)
            nSelectedSignals = length(obj.signalsList.Value);
            switch nSelectedSignals
                case 1
                    obj.currentAlgorithms = Palette.FilterAlgorithmsToInputType(obj.algorithms, DataType.kSignal);
                case 2
                    obj.currentAlgorithms = Palette.FilterAlgorithmsToInputType(obj.algorithms, DataType.kSignal2);
                case 3
                    obj.currentAlgorithms = Palette.FilterAlgorithmsToInputType(obj.algorithms, DataType.kSignal3);
                otherwise
                    obj.currentAlgorithms = Palette.FilterAlgorithmsToInputType(obj.algorithms, DataType.kSignalN);
            end
            
            obj.algorithmsList.Items = Helper.generateAlgorithmNamesArray(obj.currentAlgorithms);
        end
        
        
        %% handles
        function handleSelectedSignalChanged(obj,~,~)
            obj.updateAlgorithmsList();
        end
        
        function handleSelectedAlgorithmChanged(obj,~,~)
            obj.updateSelectedAlgorithm();
            obj.updateAlgorithmVariablesTable();
            
            selectedAlgorithm = obj.getCurrentAlgorithm();
            if ~isempty(obj.delegate)
                obj.delegate.handlePreprocessingAlgorithmChanged(selectedAlgorithm,obj);
            end
        end
    end
end