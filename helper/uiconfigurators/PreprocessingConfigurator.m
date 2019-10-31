%this class retrieves a preprocessing algorithm from the UI
classdef PreprocessingConfigurator < handle
    
    properties (Access = private)
        %data
        signals;
        
        %computers
        signalComputers;
        signalComputerStrings;
        
        %ui
        signalsList;
        signalComputersList;
        signalComputerVariablesTable;
        
        %state
        currentSignalComputerVariables;
        
        %observer
        delegate;
    end
    
    methods (Access = public)
        function obj = PreprocessingConfigurator(signals,signalComputers, signalsList,...
                signalComputersList,signalComputerVariablesTable,delegate)
            
            obj.signals = signals;
            obj.signalComputers = signalComputers;
            obj.signalsList = signalsList;
            obj.signalComputersList = signalComputersList;
            obj.signalComputerVariablesTable = signalComputerVariablesTable;
            obj.signalsList.ValueChangedFcn = @obj.handleSelectedSignalChanged;
            obj.signalComputersList.ValueChangedFcn = @obj.handleSelectedSignalComputerChanged;
            
            if nargin > 5
                obj.delegate = delegate;
            end
            
            if ~isempty(obj.signalComputersList)
                obj.updateSignalsList();
                obj.updateSignalComputersList();
                obj.selectFirstSignalComputer();
                
                obj.updateSelectedSignalComputer();
                obj.updateSignalComputerVariablesTable();
            end
        end
        
        function setSignals(obj,signals)
            obj.signals = signals;
            obj.updateSignalsList();
        end
        
        function signalComputer = getCurrentSignalComputer(obj)
            idxStr = obj.signalComputersList.Value;
            [~,idx] = ismember(idxStr,obj.signalComputersList.Items);
            if isempty(idx)
                signalComputer = [];
            else
                signalComputer = obj.signalComputers{idx};
            end
        end
        
        function signalIdxs = getSelectedSignalIdxs(obj)
            idxStr = obj.signalsList.Value;
            [~,signalIdxs] = ismember(idxStr,obj.signalsList.Items);
        end
        
        function computer = createPreprocessingComputerWithUIParameters(obj)
            axisSelector = obj.createAxisSelectorWithUIParameters();
            if isempty(axisSelector)
                computer = [];
            else
                signalComputer = obj.createSignalComputerWithUIParameters();
                if isempty(signalComputer)
                    computer = [];
                else
                    axisSelector.addNextComputer(signalComputer);
                    computer = CompositeComputer(axisSelector,{signalComputer});
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
        
        function signalComputer = createSignalComputerWithUIParameters(obj)
            signalComputer = obj.getCurrentSignalComputer();
            if isa(signalComputer,'NoOp')
                signalComputer = [];
            elseif ~isempty(signalComputer)
                signalComputer = signalComputer.copy();
                data = obj.signalComputerVariablesTable.Data;
                for i = 1 : size(data,1)
                    variableName = data{i,1};
                    variableValue = data{i,2};
                    property = Property(variableName,variableValue);
                    signalComputer.setProperty(property);
                end
            end
        end
        
    end
    
    methods (Access = private)
        
        %ui
        function updateSignalsList(obj)
            obj.signalsList.Items = obj.signals;
        end
        
        function signals = getSelectedSignals(obj)
            %returns signals in order
            [~, signalIndices] = ismember(obj.signalsList.Value,obj.signalsList.Items);
            signalIndices = sort(signalIndices);
            signals = obj.signalsList.Items(signalIndices);
        end
        
        function selectFirstSignalComputer(obj)
            obj.signalComputersList.Value = obj.signalComputersList.Items{1};
        end
        
        function selectFirstSignal(obj)
            obj.signalsList.Value = obj.signalsList.Items{1};
        end
        
        function updateSignalComputerVariablesTable(obj)
            obj.signalComputerVariablesTable.Data = Helper.propertyArrayToCellArray(obj.currentSignalComputerVariables);
        end
        
        function updateSelectedSignalComputer(obj)
            signalComputer = obj.getCurrentSignalComputer();
            if isempty(signalComputer)
                obj.currentSignalComputerVariables = [];
            else
                obj.currentSignalComputerVariables = signalComputer.getEditableProperties();
            end
        end
        
        %methods
        function updateSignalComputersList(obj)
            nSelectedSignals = length(obj.signalsList.Value);
            switch nSelectedSignals
                case 1
                    algorithms = Palette.FilterAlgorithmsToInputType(obj.signalComputers, DataType.kSignal);
                case 2
                    algorithms = Palette.FilterAlgorithmsToInputType(obj.signalComputers, DataType.kSignal2);
                case 3
                    algorithms = Palette.FilterAlgorithmsToInputType(obj.signalComputers, DataType.kSignal3);
                otherwise
                    algorithms = Palette.FilterAlgorithmsToInputType(obj.signalComputers, DataType.kSignalN);
            end
            
            obj.signalComputersList.Items = Helper.generateComputerNamesArray(algorithms);
        end
        
        
        %% handles
        function handleSelectedSignalChanged(obj,~,~)
            obj.updateSignalComputersList();
        end
        
        function handleSelectedSignalComputerChanged(obj,~,~)
            obj.updateSelectedSignalComputer();
            obj.updateSignalComputerVariablesTable();
            
            selectedSignalComputer = obj.getCurrentSignalComputer();
            obj.delegate.handlePreprocessingAlgorithmChanged(selectedSignalComputer,obj);
        end
    end
end