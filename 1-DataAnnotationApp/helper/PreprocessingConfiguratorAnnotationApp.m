%this class retrieves a preprocessing algorithm from the UI
%this file duplicats the PreprocessingConfigurator and should be removed as
%soon as Matlab releases support for datacursor mode using App Designer
classdef PreprocessingConfiguratorAnnotationApp < handle

    properties (Access = private)
        %data
        columnNames;
        
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
        function obj = PreprocessingConfiguratorAnnotationApp(signalsList,signalComputersList,signalComputerVariablesTable)
            obj.signalsList = signalsList;
            obj.signalComputersList = signalComputersList;
            obj.signalComputerVariablesTable = signalComputerVariablesTable;
            
            obj.signalComputersList.Callback = @obj.handleSelectedSignalComputerChanged;
            
            obj.loadSignalComputers();
            
            obj.fillSignalComputersList();
            obj.updateSelectedSignalComputer();
            obj.updateSignalComputerVariablesTable();
        end
        
        function setDefaultColumnNames(obj)
            dataLoader = DataLoader();
            dataFiles = Helper.listDataFiles();
            if ~isempty(dataFiles)
                fileName = dataFiles{1};
                [~, obj.columnNames] = dataLoader.loadData(fileName);
            end
            obj.fillSignalsList();
        end
        
        function setColumnNames(obj,columnNames)
            obj.columnNames = columnNames;
            obj.fillSignalsList();
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
            
            computer = SequentialComputer({axisSelector, signalComputer});
        end
        
        function updateSignalsList(obj)
            str = Helper.cellArrayToString(obj.columnNames);
            obj.signalsList.String = str;
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