classdef DetectionTestbedApp < handle
    
    properties (Constant)
        kMaxFileNameLength = 12;
    end
    
    properties (Access = private)
        
        currentFile;
        currentEventDetector;
        currentEventDetectorVariables;
        
        %data loading
        preprocessedSignalsLoader;
        
        %data
        eventsLoader;
        fileEnergies;
        fileNames;
        
        %group strategies
        groupStrategies;
        currentLabelingStrategy;
            
        %event detection
        eventDetectors;
        eventsPerFile;
        annotationsPerFile;
        eventDetectorVariables;
        
        %results
        resultsComputer;
        resultsPerFile;
                
        %ui state
        showingGoodEvents;
        showingMissedEvents;
        showingBadEvents;
        
        %ui plotting
        preprocessingConfigurator;
        figureHandle;
        plotAxes;
        energyPlotHandle;
        uiHandles;
        axesHandles;
        
        %event handles
        goodEventHandles;
        missedEventHandles;
        badEventHandles;
    end
    
    methods (Access = public)
        function obj = DetectionTestbedApp()
            obj.eventsLoader = EventsLoader();
            obj.resultsComputer = DetectionResultsComputer();
            obj.preprocessedSignalsLoader = PreprocessedSignalsLoader();
            obj.eventsLoader.preprocessedSignalsLoader = obj.preprocessedSignalsLoader;
            
            dataLoader = DataLoader();
            obj.groupStrategies = dataLoader.loadAllLabelingStrategies();
            
            if isempty(obj.groupStrategies)
                fprintf('Error - no labeling strategy available\n');
            else
                obj.currentLabelingStrategy = obj.groupStrategies{1};
                
                obj.showingGoodEvents = true;
                obj.showingMissedEvents = true;
                obj.showingBadEvents = true;
                obj.currentFile = 1;
                
                obj.loadEventDetectors();
                obj.annotationsPerFile = dataLoader.loadAllAnnotations();
                
                %obj.loadAnnotations();
                
                listedFiles = Helper.listDataFiles();
                obj.fileNames = Helper.removeDataFileExtensionForFiles(listedFiles);
                
                obj.loadUI();
                
                obj.currentEventDetector = obj.getSelectedEventDetector();
                
                obj.updateSelectedEventDetector();
                obj.updateVariablesTable();
            end
        end
        
                
        function loadUI(obj)
            obj.uiHandles = guihandles(detectionTestbedUI);
            obj.loadPlotAxes();
            
            obj.uiHandles.computeButton.Callback = @obj.handleComputeButtonClicked;
            obj.uiHandles.saveEventsButton.Callback = @obj.handleSaveEventsButtonClicked;
            obj.uiHandles.visualizeButton.Callback = @obj.handleVisualizeButtonClicked;
            obj.uiHandles.showDetectedCheckbox.Callback = @obj.handleShowDetectedToggled;
            obj.uiHandles.showMissedCheckbox.Callback = @obj.handleShowMissedToggled;
            obj.uiHandles.showBadEventsCheckbox.Callback = @obj.handleShowBadEventsToggled;
            obj.uiHandles.eventDetectionList.Callback = @obj.handleEventDetectionChanged;
            obj.uiHandles.groupStrategiesList.Callback = @obj.handleGroupStrategyChanged;
            
            obj.uiHandles.filesList.String = obj.fileNames;
            
            
            obj.preprocessingConfigurator = PreprocessingConfigurator(...
                obj.uiHandles.signalsList,...
                obj.uiHandles.signalComputersList,...
                obj.uiHandles.signalComputerVariablesTable);
            
            obj.resetUI();
            
            obj.fillLabelingStrategiesList();
            obj.fillEventDetectionList();
        end
        
        function resetUI(obj)
            obj.uiHandles.segmentsDescriptionLabel.String = "";
            obj.uiHandles.classsList.String = [];
            %obj.uiHandles.signalComputersList.Value = [];
            obj.uiHandles.filtersText.String = "";
            obj.uiHandles.perFileResultsText.String = "";
            obj.uiHandles.perClassResultsText.String = "";
            obj.uiHandles.showDetectedCheckbox.Value = 1;
            obj.uiHandles.showMissedCheckbox.Value = 1;
            obj.uiHandles.showBadEventsCheckBox.Value = 1;
            obj.uiHandles.detectionResultsText.String = "";
            obj.uiHandles.signalsLoadedLabel.String = "";
            obj.uiHandles.detectMaxValuesLabel.String = "";
            obj.uiHandles.filesList.Value = 1;
            obj.uiHandles.groupStrategiesList.Value = 1;
            
            obj.uiHandles.variablesTable.ColumnName = {'Variable','Value'};
            obj.uiHandles.variablesTable.ColumnWidth = {100,50};
        end
        
        function loadEventDetectors(obj)
            obj.eventDetectors = {SimplePeakDetector,MatlabPeakDetector};
        end
        
        function loadPreprocessedData(obj)
            signalComputer = obj.preprocessingConfigurator.createSignalComputerWithUIParameters();
            obj.preprocessedSignalsLoader.preprocessor = signalComputer;
            obj.fileEnergies = obj.preprocessedSignalsLoader.loadOrCreateData();
        end
        
        %{
        function loadAnnotations(obj)
            
            obj.annotationFileNames = Helper.listAnnotationFiles();
            nFiles = length(obj.annotationFileNames);
            obj.eventAnnotationsPerFile = cell(1,nFiles);
            dataLoader = DataLoader();
            for fileIdx = 1 : nFiles
                annotationFile = obj.annotationFileNames{fileIdx};
                annotationSet = dataLoader.loadAnnotations(annotationFile);
                
                obj.eventAnnotationsPerFile(fileIdx) = {annotationSet.eventAnnotations};
            end
        end
%}
        function loadPlotAxes(obj)
            obj.plotAxes = axes(obj.uiHandles.figure1);
            obj.plotAxes.Units = 'characters';
            obj.plotAxes.Position  = [40 2 290 30];
            obj.plotAxes.Visible = 'On';
        end
        
        function fillLabelingStrategiesList(obj)
            groupStrategiesCellArray = Helper.listLabelingStrategies();
            obj.uiHandles.groupStrategiesList.String = Helper.cellArrayToString(groupStrategiesCellArray);
        end
        
        function fillEventDetectionList(obj)
            obj.uiHandles.eventDetectionList.String = Helper.generateEventDetectorNames(obj.eventDetectors);
            obj.uiHandles.eventDetectionList.Value = 1;
        end
        
        
        %ui
        function labelingStrategy = getCurrentLabelingStrategy(obj)
            labelingStrategyIdx = obj.getSelectedLabelingIdx();
            labelingStrategy = obj.groupStrategies{labelingStrategyIdx};
        end
        
        function idx = getSelectedLabelingIdx(obj)
            idx = obj.uiHandles.groupStrategiesList.Value;
        end
        
        function updateSelectedEventDetector(obj)
            idx = obj.uiHandles.eventDetectionList.Value;
            obj.currentEventDetector = obj.eventDetectors{idx};
            obj.currentEventDetectorVariables = obj.currentEventDetector.getEditableProperties();
        end
        
        function eventDetector = getSelectedEventDetector(obj)
            idx = obj.uiHandles.eventDetectionList.Value;
            eventDetector = obj.eventDetectors{idx};
        end
        
        function tolerance = getTolerance(obj)
            toleranceStr = obj.uiHandles.toleranceTextBox.String;
            tolerance = str2double(toleranceStr);
        end
                
        function emptyResultLabels(obj)
            obj.uiHandles.fileResultsLabel.String = "";
            obj.uiHandles.classResultsLabel.String = "";
        end
        
        function updateFileResultLabels(obj)
            text = sprintf("%12s|%7s|%6s\n",'File','Good','Bad');
            for i = 1 : length(obj.resultsPerFile)
                fileName = obj.fileNames{i};
                maxFileNameLength = min(length(fileName),DetectionTestbedApp.kMaxFileNameLength);
                fileName = fileName(1:maxFileNameLength);
                fileResults = obj.resultsPerFile(i);
                fileResultsStr = fileResults.toString();
                text = sprintf('%s%12s|%s\n',text,fileName,fileResultsStr);
            end
            
            text = sprintf('%s------------------------------\n',text);
            aggregatedFilesResults = AggregatedDetectionResults.AggregatedDetectionResultsWithDetectionResults(obj.resultsPerFile);
            aggregatedStatisticsStr = aggregatedFilesResults.toString();
            resultstext = sprintf('%12s|%s','Total',aggregatedStatisticsStr);
            text = sprintf('%s%s',text,resultstext);
            obj.uiHandles.perFileResultsText.String = text;
        end
        
        function updateClassResultLabels(obj,classDetectionStatistics)
            text = sprintf("%13s|%s",'Class','Detected');
            
            nGoodEventsDetectedPerClass = classDetectionStatistics.nGoodEventsDetectedPerClass;
            nTotalGoodEventsPerClass = classDetectionStatistics.nGoodEventsPerClass;
            for i = 1 : length(nGoodEventsDetectedPerClass)
                classStr = obj.currentLabelingStrategy.classNames{i};
                detectedPerClass = nGoodEventsDetectedPerClass(i);
                detectionRate = 100 * detectedPerClass / nTotalGoodEventsPerClass(i);
                text = sprintf('%s\n%13s|%d(%3.2f%%)',text,classStr,detectedPerClass,detectionRate);
            end
            text = sprintf('%s\n---------------------------',text);
            totalGoodEventsDetected = sum(nGoodEventsDetectedPerClass);
            totalGoodEvents = sum(nTotalGoodEventsPerClass);
            detectionRate = 100 * totalGoodEventsDetected / totalGoodEvents;
            text = sprintf('%s\n%13s|%d(%3.1f%%)',text,'Total',totalGoodEventsDetected,detectionRate);
            
            obj.uiHandles.perClassResultsText.String = text;
        end
        
        function cleanPlot(obj)
            cla(obj.plotAxes);
            cla(obj.plotAxes,'reset');
            
        end
        
        function updateVariablesTable(obj)
            obj.uiHandles.variablesTable.Data = Helper.propertyArrayToCellArray(obj.currentEventDetectorVariables);
        end
        
        %methods
        function events = loadEvents(obj)
            obj.createEventDetectorWithUIParameters();
            %obj.eventsLoader.signalPreprocessor = obj.preprocessingConfigurator.getCurrentSignalComputer();
            obj.eventsLoader.eventDetector = obj.currentEventDetector;
            events = obj.eventsLoader.loadOrCreateEvents();
        end
        
        function computeDetectionResults(obj,tolerance)
            if ~isempty(obj.eventsPerFile) && ~isempty(obj.annotationsPerFile)
                obj.resultsComputer.tolerance = uint32(tolerance);
                obj.resultsPerFile = obj.resultsComputer.computeDetectionResults(obj.eventsPerFile,obj.annotationsPerFile);
            end
        end
        
        function plotEnergy(obj)
            
            energy = obj.fileEnergies{obj.currentFile};
            obj.energyPlotHandle = plot(obj.plotAxes,energy);
        end
        
        function plotEvents(obj)
            currentFileResults = obj.resultsPerFile(obj.currentFile);
            
            obj.goodEventHandles = obj.plotEventsInColor(currentFileResults.goodEvents,'green');
            obj.missedEventHandles = obj.plotEventsInColor(currentFileResults.missedEvents,[1,0.5,0]);
            obj.badEventHandles = obj.plotEventsInColor(currentFileResults.badEvents,'red');
            
            if ~obj.showingGoodEvents
                obj.toggleEventsVisibility(obj.goodEventHandles,false);
            end
            
            if ~obj.showingMissedEvents
                obj.toggleEventsVisibility(obj.missedEventHandles,false);
            end
            
            if ~obj.showingBadEvents
                obj.toggleEventsVisibility(obj.badEventHandles,false);
            end
        end
        
        function eventHandles = plotEventsInColor(obj,events,color)
            eventHandles = [];
            nEvents = length(events);
            if nEvents > 0
                eventHandles = repmat(SegmentationTestbedEventHandle(), 1, nEvents);
                energy = obj.fileEnergies{obj.currentFile};
                for i = 1 : length(events)
                    event = events(i);
                    eventX = event.sample;
                    eventY = energy(eventX);
                    label = event.label;
                    classStr = obj.currentLabelingStrategy.classNames{label};
                    symbolHandle = plot(obj.plotAxes,eventX,eventY,'*','Color',color);
                    textHandle = text(obj.plotAxes,double(eventX),double(eventY), classStr);
                    eventHandle = SegmentationTestbedEventHandle(symbolHandle,textHandle);
                    eventHandles(i) = eventHandle;
                end
            end
        end
        
        function toggleEventsVisibility(~,eventHandles,visible)
            for i = 1 : length(eventHandles)
                eventHandle = eventHandles(i);
                eventHandle.setVisible(visible);
            end
        end
        
        function fileIdx = getcurrentFile(obj)
            fileIdx = obj.uiHandles.filesList.Value;
        end
        
        function computeDetectionStatistics(obj)
            nClasses = obj.currentLabelingStrategy.numClasses-1;
            aggregatedClassResults = AggregatedDetectionResultsPerClass.computeAggregatedClassStatistics(obj.resultsPerFile,nClasses);
            
            obj.updateFileResultLabels();
            obj.updateClassResultLabels(aggregatedClassResults);
        end
        
        function createEventDetectorWithUIParameters(obj)
            
            data = obj.uiHandles.variablesTable.Data;
            for i = 1 : length(data)
                variableName = data{i,1};
                variableValue = data{i,2};
                setExpression = sprintf('obj.currentEventDetector.%s=%d;',variableName,variableValue);
                eval(setExpression);
            end
        end
        
        function saveEvents(obj)
            events = obj.eventsPerFile{1};
            obj.eventsLoader.saveEvents(events,'events.txt');
        end
        
        
        %handles
        function handleEventDetectionChanged(obj,~,~)
            obj.updateSelectedEventDetector();
            obj.updateVariablesTable();
        end
        
        function handleGroupStrategyChanged(obj,~,~)
            obj.currentLabelingStrategy = obj.getCurrentLabelingStrategy();
            obj.resultsComputer.labelingStrategy = obj.currentLabelingStrategy;
        end
        
        function handleComputeButtonClicked(obj,~,~)
            
            obj.emptyResultLabels();
            obj.cleanPlot();
            
            obj.loadPreprocessedData();
            
            obj.eventsPerFile = obj.loadEvents();
            
            obj.resultsComputer.labelingStrategy = obj.currentLabelingStrategy;
            
            tolerance = obj.getTolerance();
            obj.computeDetectionResults(tolerance);
            obj.computeDetectionStatistics();
        end
        
        
        function handleSaveEventsButtonClicked(obj,~,~)
            obj.saveEvents();
        end
        
        function handleVisualizeButtonClicked(obj,~,~)
            if ~isempty(obj.eventsPerFile)
                obj.currentFile = obj.uiHandles.filesList.Value;
                obj.cleanPlot();
                obj.plotEnergy();
                hold(obj.plotAxes,'on');
                obj.plotEvents();
            end
        end
        
        function handleShowDetectedToggled(obj,~,~)
            obj.showingGoodEvents = ~obj.showingGoodEvents;
            if ~isempty(obj.goodEventHandles)
                obj.toggleEventsVisibility(obj.goodEventHandles,obj.showingGoodEvents);
            end
        end
        
        function handleShowMissedToggled(obj,~,~)
            obj.showingMissedEvents = ~obj.showingMissedEvents;
            if ~isempty(obj.missedEventHandles)
                obj.toggleEventsVisibility(obj.missedEventHandles,obj.showingMissedEvents);
            end
        end
        
        function handleShowBadEventsToggled(obj,~,~)
            obj.showingBadEvents = ~obj.showingBadEvents;
            if ~isempty(obj.badEventHandles)
                obj.toggleEventsVisibility(obj.badEventHandles,obj.showingBadEvents);
            end
        end
        
    end
    
end
