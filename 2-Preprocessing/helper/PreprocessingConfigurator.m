%this class retrieves a preprocessing algorithm from the UI
classdef PreprocessingConfigurator < handle
    
    properties (Access = public)
        signalComputers;
        signalComputerStrings;
    end
    
    properties (Access = private)
        columnNames;
        
        %ui
        signalsList;
        signalComputersList;
        signalComputerVariablesTable;
        
        %state
        currentSignalComputerVariables;
    end
    
    methods (Access = public)
        function obj = PreprocessingConfigurator(signalsList,signalComputersList,signalComputerVariablesTable)
            obj.signalsList = signalsList;
            obj.signalComputersList = signalComputersList;
            obj.signalComputerVariablesTable = signalComputerVariablesTable;
            
            obj.signalComputersList.Callback = @obj.handleSelectedSignalComputerChanged;
            
            obj.loadColumnNames();
            obj.loadSignalComputers();
            
            obj.fillSignalsList();
            obj.fillSignalComputersList();
            obj.updateSignalComputerVariablesTable();
        end
        
        function signalComputer = getCurrentSignalComputer(obj)
            idx = obj.signalComputersList.Value;
            signalComputer = obj.signalComputers{idx};
        end
        
        function signalIdxs = getSelectedSignalIdxs(obj)
            signalIdxs = obj.signalsList.Value;
        end
        
        function computer = createSignalComputerWithUIParameters(obj)
            signalComputer = obj.getCurrentSignalComputer();
            
            data = obj.signalComputerVariablesTable.Data;
            for i = 1 : size(data,1)
                variableName = data{i,1};
                variableValue = data{i,2};
                property = Property(variableName,variableValue);
                signalComputer.setProperty(property);
            end
            
            selectedSignals = obj.getSelectedSignalIdxs();
            axisSelector = AxisSelectorComputer();
            axisSelector.axes = selectedSignals;
            
            computer = CompositeComputer({axisSelector, signalComputer});
        end
    end
    
    methods (Access = private)
        
        %ui
        function fillSignalComputersList(obj)
            obj.signalComputersList.String = obj.signalComputerStrings;
        end
        
        function fillSignalsList(obj)
            obj.signalsList.String = obj.columnNames;
        end
        
        function updateSignalComputerVariablesTable(obj)
            obj.signalComputerVariablesTable.Data = Helper.propertyArrayToCellArray(obj.currentSignalComputerVariables);
        end
        
        function updateSelectedSignalComputer(obj)
            signalComputer = obj.getCurrentSignalComputer();
            obj.currentSignalComputerVariables = signalComputer.getEditableProperties();
        end
        
        %methods
        function fillsignalComputersList(obj)
            obj.signalComputersList.String = obj.signalComputerStrings;
        end
        
        function fillsignalList(obj)
            obj.signalsList.String = obj.columnNames;
        end
        
        function loadColumnNames(obj)
            dataLoader = DataLoader();
            dataFiles = Helper.listDataFiles();
            if ~isempty(dataFiles)
                fileName = dataFiles{1};
                [~, obj.columnNames] = dataLoader.loadData(fileName);
            end
        end
        
        function loadSignalComputers(obj)
            
            lowPassFilter = LowPassFilter(1,1);
            highPassFilter = HighPassFilter(1,1);
            
            lowPassFilterComputer = FilterComputer(lowPassFilter);
            highPassFilterComputer = FilterComputer(highPassFilter);
            
            s1computer = S1Computer(30);
            s2computer = S2Computer(30);
            
            obj.signalComputers = {SignalComputer.NoOpComputer(),...
                lowPassFilterComputer, ...
                highPassFilterComputer,...
                s1computer,s2computer,SignalComputer.EnergyComputer()};
            
            obj.signalComputerStrings = {'NoOpComputer',...
                'LowPassFilter',...
                'HighPassFilter','S1','S2','E'};
        end
        
        %handles
        function handleSelectedSignalComputerChanged(obj,~,~)
            obj.updateSelectedSignalComputer();
            obj.updateSignalComputerVariablesTable();
        end
    end
end