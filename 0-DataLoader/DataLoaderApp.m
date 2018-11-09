classdef DataLoaderApp < handle
    
    properties (Access = public)
        currentFile = 1;
    end
    
    properties (Access = private)
        
        %UI
        uiHandles;
        figureHandle;
        plotHandle;
        plotAxes;
        
        %data
        columnNames;
        data;
        
        %data loader
        dataLoader;
    end
    
    methods (Access = public)
        function obj = DataLoaderApp()
            obj.dataLoader = DataLoader();
            obj.loadUI();
            obj.loadData();
            obj.updateEndText();
            obj.updateVariablesList();
            obj.plotData();
        end
    end
    
    methods (Access = private)
        
        function loadUI(obj)
            
            obj.uiHandles = guihandles(DataLoaderUI);
                        
            obj.uiHandles.fileNamesList.Callback = @obj.handleSelectionChanged;
            obj.uiHandles.loadDataButton.Callback = @obj.handleLoadDataClicked;
            obj.uiHandles.visualizeButton.Callback = @obj.handleVisualizeButtonClicked;
            obj.uiHandles.saveDataButton.Callback = @obj.handleSaveDataClicked;
            obj.uiHandles.saveDataTextButton.Callback = @obj.handleSaveDataTextClicked;
            obj.uiHandles.checkDataLossButton.Callback = @obj.handleCheckDataLossClicked;
            obj.uiHandles.cutDataButton.Callback = @obj.handleCutDataButtonClicked;
            obj.uiHandles.printStatisticsButton.Callback = @obj.handlePrintStatisticsButtonClicked;
            obj.uiHandles.dataLossLabel.String = '';
            
            obj.loadPlotAxes();
            obj.setUserClickHandle();
            obj.populateFileNamesList();
        end
        
        %methods
        function setUserClickHandle(obj)
            dataCursorMode = datacursormode(obj.uiHandles.figure1);
            dataCursorMode.SnapToDataVertex = 'on';
            dataCursorMode.DisplayStyle = 'window';
            dataCursorMode.Enable = 'on';
            set(dataCursorMode,'UpdateFcn',@obj.handleUserClick);
        end
        
        function loadPlotAxes(obj)
            obj.plotAxes = axes(obj.uiHandles.figure1);
            obj.plotAxes.Units = 'characters';
            obj.plotAxes.Position  = [34.0 4 170 54];
            obj.plotAxes.Visible = 'Off';
        end
        
        function loadData(obj)
            fileName = obj.uiHandles.fileNamesList.String{obj.currentFile};
            fileExtension = Helper.getFileExtension(fileName);
            if strcmp(fileExtension, ".mat")
                [obj.data, obj.columnNames] = obj.dataLoader.loadData(fileName);
            elseif strcmp(fileExtension, ".bin")
                fileName = obj.uiHandles.fileNamesList.String{obj.currentFile};
                [obj.data, obj.columnNames] = obj.dataLoader.loadBinaryData(fileName);
            elseif strcmp(fileExtension, ".txt")
                fileName = obj.uiHandles.fileNamesList.String{obj.currentFile};
                [obj.data, obj.columnNames] = obj.dataLoader.loadTextData(fileName);
            end
        end

        function plotData(obj)
            if isempty(obj.data)
                if ~isempty(obj.plotHandle)
                    delete(obj.plotHandle);
                    obj.plotHandle = [];
                    cla(obj.plotHandle);
                end
            else
                selectedIdxs = obj.getSelectedColumnIdxs();
                obj.plotHandle = plot(obj.plotAxes,obj.data(:,selectedIdxs));
            end
        end
        
        function populateFileNamesList(obj)
            files = [dir(fullfile('./data/rawData', '*.mat'));...
                dir(fullfile('./data/rawData', '*.txt'))];
            
            nFiles = length(files);
            filesStr = cell(1,nFiles);
            
            for i = 1 : length(files)
                filesStr{i} = files(i).name;
            end
            
            obj.uiHandles.fileNamesList.String = filesStr;
        end
        
        
        function handleSelectionChanged(obj,~,~)
            obj.updateFileName();
            
        end
        
        
        %ui  
        function updateFileName(obj)
            obj.currentFile = obj.uiHandles.fileNamesList.Value;
        end
        
        function selectedColumnIdxs = getSelectedColumnIdxs(obj)
            selectedColumnIdxs = obj.uiHandles.variablesList.Value;
        end
        
        function value = getTsInterval(obj)
            valueStr = obj.uiHandles.tsIntervalText.String;
            value = str2double(valueStr);
        end
                
        function value = getStartSample(obj)
            valueStr = obj.uiHandles.startText.String;
            value = str2double(valueStr);
        end
        
        function value = getEndSample(obj)
            valueStr = obj.uiHandles.endText.String;
            value = str2double(valueStr);
        end
        
        function updateEndText(obj)
            numSamples = size(obj.data,1);
            valueStr = sprintf('%d',numSamples);
            obj.uiHandles.endText.String = valueStr;
        end
        
        function updateVariablesList(obj)
            str = Helper.cellArrayToString(obj.columnNames);
            obj.uiHandles.variablesList.String = str;
        end
        
        %handles
        function outputTxt = handleUserClick(~,src,~)
            pos = get(src,'Position');
            x = pos(1);
            y = pos(2);
            xStr = num2str(x,7);
            yStr = num2str(y,7);
            outputTxt = {['X: ',xStr],['Y: ',yStr]};
            
            fprintf('%d\n',x);
        end
        
        function handleLoadDataClicked(obj,~,~)
            if ~isempty(obj.data)
                obj.data = [];
                obj.columnNames = [];
            end
            
            obj.loadData();
            obj.updateEndText();
            obj.updateVariablesList();
            obj.plotData();
        end
         
        function handleVisualizeButtonClicked(obj,~,~)
            obj.plotData();
        end
        
        function handleSaveDataClicked(obj,~,~)
            fileName = obj.uiHandles.fileNamesList.String{obj.currentFile};
            dataTable = array2table(obj.data);
            dataTable.Properties.VariableNames = obj.columnNames;
            obj.dataLoader.saveData(dataTable,fileName);
        end
        
        function handleSaveDataTextClicked(obj,~,~)
            fileName = obj.uiHandles.fileNamesList.String{obj.currentFile};
            obj.dataLoader.saveTextData(obj.data,obj.columnNames,fileName);
        end
        
        function handleCheckDataLossClicked(obj,~,~)
            if ~isempty(obj.data)
                selectedSignal = obj.getSelectedColumnIdxs();
                if length(selectedSignal) == 1
                    
                    tsInterval = obj.getTsInterval();
                    if ~isempty(tsInterval)
                        
                        signal = obj.data(:,selectedSignal);
                        
                        validDataLossSignal = issorted(signal);
                        
                        if validDataLossSignal
                            firstSampleTime = signal(1);
                            lastSampleTime = signal(end);
                            expectedSamples = (lastSampleTime - firstSampleTime);
                            
                            nMissingPoints = Helper.countMissingPoints(unique(signal),tsInterval);
                            dataLossPercent = 100 * double(nMissingPoints) / double(expectedSamples);
                            obj.uiHandles.dataLossLabel.String = sprintf('data loss: %.1f%%',dataLossPercent);
                        else
                            obj.uiHandles.dataLossLabel.String = sprintf('invalid signal');
                        end
                    end
                end
            end
        end
        
        function handleCutDataButtonClicked(obj,~,~)
            startSample = obj.getStartSample();
            endSample = obj.getEndSample();
            numSamples = size(obj.data,1);
            if startSample > 0 && startSample < endSample && endSample <= numSamples
                obj.data = obj.data(startSample:endSample,:);
                obj.plotData();
                obj.updateEndText();
            end
        end
        
        function handlePrintStatisticsButtonClicked(obj,~,~)
            nSamples = size(obj.data,1);
            nSeconds = nSamples / 200;
            nMinutes = nSeconds / 60;
            fileName = obj.uiHandles.fileNamesList.String{obj.currentFile};
            fprintf('%s- %d samples (%d minutes)\n',fileName,nSamples,int32(nMinutes));
        end
    end
end
