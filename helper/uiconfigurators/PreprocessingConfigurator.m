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
    end
    
    methods (Access = public)
        function obj = PreprocessingConfigurator(signals,signalComputers, signalsList,...
                signalComputersList,signalComputerVariablesTable)
            
            obj.signals = signals;
            obj.signalComputers = signalComputers;
            obj.signalsList = signalsList;
            obj.signalComputersList = signalComputersList;
            obj.signalComputerVariablesTable = signalComputerVariablesTable;
            obj.signalComputersList.ValueChangedFcn = @obj.handleSelectedSignalComputerChanged;
            
            if ~isempty(obj.signalComputersList)
                obj.updateSignalsList();
                obj.fillSignalComputersList();
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
        function fillSignalComputersList(obj)
            obj.signalComputersList.Items = Helper.generateComputerNamesArray(obj.signalComputers);
        end
        
        %handles
        function handleSelectedSignalComputerChanged(obj,~,~)
            obj.updateSelectedSignalComputer();
            obj.updateSignalComputerVariablesTable();
        end
    end
end