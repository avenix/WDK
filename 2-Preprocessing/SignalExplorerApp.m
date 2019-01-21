classdef SignalExplorerApp < handle

    properties (Access = private)

        %classes
        classesMap;
        annotations;
        
        %data loader
        segmentsLoader;
        segmentsLabeler;
        dataLoader;
        
        %data
        segments;
        groupedSegments;
        filteredSegments;
        columnNames;
        
        %preprocessing
        preprocessingConfigurator;
        
        %detection (only for automatic)
        eventDetectorConfigurator;
        isManualEventDetector;
        
        %segmentation
        segmentationConfigurator;
        currentSegmentationStrategy;
        currentSegmentsCreator;
        
        %labeling
        labelingConfigurator;
        
        %visualisation
        visualizationState;
        preprocessingConfiguratorVisualization;
        
        %ui plotting
        segmentsPlotter;
        uiHandles;
    end
    
    methods (Access = public)
        function obj = SignalExplorerApp()
            clear ClassesMap;
            obj.classesMap = ClassesMap.instance();
            obj.dataLoader = DataLoader();
            
            obj.annotations = obj.dataLoader.loadAllAnnotations();
            
            obj.segmentsLoader = SegmentsLoader();
            obj.currentSegmentsCreator = SegmentsCreator();
            obj.segmentsLoader.segmentsCreator = obj.currentSegmentsCreator;
            
            obj.segmentsLabeler = SegmentsLabeler();
            obj.segmentsLabeler.manualAnnotations = obj.annotations;
            
            
            obj.isManualEventDetector = true;
            obj.visualizationState = SignalExplorerVisualizationState.kOverlappingMode;
            
            obj.loadUI();
            obj.resetUI();
            
            obj.segmentsPlotter = PreprocessingSegmentsPlotter(obj.uiHandles.plotPanel);
        end
        
        function loadUI(obj)
            
            obj.uiHandles = guihandles(signalExplorerUI);
            
            obj.uiHandles.loadButton.Callback = @obj.handleLoadClicked;
            obj.uiHandles.groupButton.Callback = @obj.handleGroupClicked;
            obj.uiHandles.visualizeButton.Callback = @obj.handleVisualizeClicked;

            obj.uiHandles.manualSegmentationRadio.Callback = @obj.handleManualSegmentationRadioChanged;
            obj.uiHandles.automaticSegmentationRadio.Callback = @obj.handleAutomaticSegmentationRadioChanged;
            
            obj.uiHandles.plotStyleButtonGroup.SelectionChangedFcn = @obj.handleVisualizationStateChanged;
            obj.uiHandles.showLinesCheckbox.Callback = @obj.handleShowLinesChanged;
            
            
            obj.preprocessingConfigurator = PreprocessingConfigurator(...
                obj.uiHandles.preprocessingSignalsList,...
                obj.uiHandles.preprocessingSignalComputerList,...
                obj.uiHandles.preprocessingSignalComputerVariablesTable);
            
            obj.preprocessingConfigurator.setDefaultColumnNames();
            
            obj.preprocessingConfiguratorVisualization = PreprocessingConfigurator(...
                obj.uiHandles.signalsListVisualization,...
                obj.uiHandles.signalComputersListVisualization,...
                obj.uiHandles.signalComputerVariablesTableVisualization);
            
            obj.preprocessingConfiguratorVisualization.setDefaultColumnNames();
            
            obj.eventDetectorConfigurator = EventDetectorConfigurator(...
                obj.uiHandles.eventDetectorList...
                ,obj.uiHandles.eventDetectorVariablesTable);
            
            segmentationStrategies = {ManualSegmentation};
            
            obj.segmentationConfigurator = SegmentationConfigurator(...
                segmentationStrategies,...
                obj.uiHandles.segmentationList...
                ,obj.uiHandles.segmentationVariablesTable);
            
            
            obj.labelingConfigurator = LabelingConfigurator(...
                obj.uiHandles.labelingStrategiesList);
                
            obj.updateEventDetectionTablesVisibility();
        end
        
        function resetUI(obj)
            obj.uiHandles.segmentationLabel.String = "";
                          
            obj.uiHandles.groupsLabel.String = "";
            obj.uiHandles.classesList.String = "";
             
            obj.uiHandles.manualSegmentationRadio.Value = 1;
            obj.uiHandles.automaticSegmentationRadio.Value = 0;
            
            obj.uiHandles.signalComputerVariablesTable.ColumnName = {'Variable','Value'};
            obj.uiHandles.signalComputerVariablesTable.ColumnWidth = {70,40};
            
            obj.uiHandles.preprocessingSignalComputerVariablesTable.ColumnName = {'Variable','Value'};
            obj.uiHandles.preprocessingSignalComputerVariablesTable.ColumnWidth = {70,40};
            
            obj.uiHandles.segmentationVariablesTable.ColumnName = {'Variable','Value'};
            obj.uiHandles.segmentationVariablesTable.ColumnWidth = {90,40};
            
            obj.uiHandles.signalComputerVariablesTableVisualization.ColumnName = {'Variable','Value'};
            obj.uiHandles.signalComputerVariablesTableVisualization.ColumnWidth = {70,40};

        end

        function plotData(obj)
            selectedClassesIdxs = obj.getSelectedClasses();
            labelingStrategy = obj.labelingConfigurator.getCurrentLabelingStrategy();
            groupNames = labelingStrategy.classNames(selectedClassesIdxs);
            obj.segmentsPlotter.sameScale = obj.getSameScale();
            if obj.visualizationState == SignalExplorerVisualizationState.kOverlappingMode
                obj.segmentsPlotter.sequentialSegments = false;
            else
                obj.segmentsPlotter.sequentialSegments = true;
            end
            
            obj.segmentsPlotter.plotSegments(obj.filteredSegments,groupNames);
        end

        % ui
        function showLines = getShowLinesCheckbox(obj)
            showLines = obj.uiHandles.showLinesCheckbox.Value;
        end
        
        function includeEvents = getIncludeEvents(obj)
            includeEvents = obj.uiHandles.includeEventsCheckbox.Value;
        end
        
        function includeRanges = getIncludeRanges(obj)
            includeRanges = obj.uiHandles.includeRangesCheckbox.Value;
        end
        
        function resetGroupsLabel(obj)
            obj.uiHandles.groupsLabel.String = "";
        end
        
        function resetSegmentsLabel(obj)
            obj.uiHandles.segmentationLabel.String = "";
        end
        
        function updateGroupsLabel(obj)
            str = sprintf('%d groups.',length(obj.groupedSegments));
            obj.uiHandles.groupsLabel.String = str;
        end
        
        function updateSegmentsLabel(obj)
            str = sprintf('%d files.',length(obj.segments));
            obj.uiHandles.segmentationLabel.String = str;
        end
         
        function leftSize = getLeftSize(obj)
            leftSizeStr = obj.uiHandles.leftTextBox.String;
            leftSize = str2double(leftSizeStr);
        end
        
        function rightSize = getRightSize(obj)
            rightSizeStr = obj.uiHandles.rightTextBox.String;
            rightSize = str2double(rightSizeStr);
        end
        
        function value = getSameScale(obj)
            value = obj.uiHandles.sameScaleCheckBox.Value;
        end
        
        function updateGroupsList(obj)
            labelingStrategy = obj.labelingConfigurator.getCurrentLabelingStrategy();
            classesStr = cell(1,length(obj.groupedSegments));
            
            for i = 1 : length(obj.groupedSegments)
                nSegments = length(obj.groupedSegments{i});
                className = labelingStrategy.classNames{i};
                str = sprintf('%s: %d',className,nSegments);
                classesStr{i} = str;
            end
            obj.uiHandles.classesList.String = classesStr;
            obj.uiHandles.classesList.Value = 1:length(obj.groupedSegments);
        end
        
        function updateEventDetectionTablesVisibility(obj)
            if obj.isManualEventDetector
                obj.uiHandles.detectionLabel.Visible = 'Off';
                obj.uiHandles.preprocessingPanel.Visible = 'Off';
                obj.uiHandles.eventDetectionPanel.Visible = 'Off';
                obj.uiHandles.annotationsPanel.Visible = 'On';
                
            else
                obj.uiHandles.detectionLabel.Visible = 'On';
                obj.uiHandles.preprocessingPanel.Visible = 'On';
                obj.uiHandles.eventDetectionPanel.Visible = 'On';
                obj.uiHandles.annotationsPanel.Visible = 'Off';
            end
        end
        
        function idxs = getSelectedClasses(obj)
            idxs = obj.uiHandles.classesList.Value;
        end
        
        %methods
        function applySignalComputers(obj)
            
            filterComputer = obj.preprocessingConfiguratorVisualization.createSignalComputerWithUIParameters();
            selectedClassesIdxs = obj.getSelectedClasses();
            
            nSelectedClasses = length(selectedClassesIdxs);
            
            obj.filteredSegments = cell(1,nSelectedClasses);
            
            for i = 1 : nSelectedClasses
                currentClassIdx = selectedClassesIdxs(i);
                segmentsCurrentGroup = obj.groupedSegments{currentClassIdx};
                segmentsArray = repmat(Segment(),1,length(segmentsCurrentGroup));

                for j = 1 : length(segmentsArray)
                    segment = segmentsCurrentGroup(j);                    
                    filteredData = filterComputer.compute(segment.window);
                    filteredSegment = Segment(segment.file,filteredData,segment.class,segment.eventIdx);
                    segmentsArray(j) = filteredSegment;
                end
                obj.filteredSegments{i} = segmentsArray;
            end
        end

        function updateCurrentSegmentsCreator(obj)

            obj.currentSegmentsCreator.preprocessedSignalsLoader = PreprocessedSignalsLoader();
            segmentationAlgorithm = obj.segmentationConfigurator.createSegmentationStrategyWithUIParameters();
            
            if obj.isManualEventDetector 
                segmentationAlgorithm.includeEvents = obj.getIncludeEvents();
                segmentationAlgorithm.includeRanges = obj.getIncludeRanges();
                
                segmentationAlgorithm.manualAnnotations = obj.annotations;
                obj.segmentsLoader.segmentsLabeler = [];
            else
                eventDetector = obj.eventDetectorConfigurator.createEventDetectorWithUIParameters();
                segmentationAlgorithm.eventDetector = eventDetector;
                obj.currentSegmentsCreator.preprocessedSignalsLoader.preprocessor = obj.preprocessingConfigurator.createSignalComputerWithUIParameters();
                
                obj.segmentsLabeler.labelingStrategy = obj.labelingConfigurator.getCurrentLabelingStrategy();
                obj.segmentsLoader.segmentsLabeler = obj.segmentsLabeler;
            end
            
            obj.currentSegmentsCreator.segmentationAlgorithm = segmentationAlgorithm;
        end
                
        function loadSegments(obj)
            obj.segments = obj.segmentsLoader.loadOrCreateSegments();
        end
        
        function validData = checkValidComputedSegments(obj)
            validData = true;
            for i = 1 : length(obj.filteredSegments)
                segmentsCurrentPlayer = obj.filteredSegments{i};
                for j = 1 : length(segmentsCurrentPlayer)
                    segment = segmentsCurrentPlayer(j);
                    if isempty(segment) || isempty(segment.window)
                        validData = false;
                        break;
                    end
                end
                if validData == false
                    break;
                end
            end
        end
        
        %handles  
        function handleLoadClicked(obj,~,~)
            if(obj.getIncludeEvents || obj.getIncludeRanges)
                obj.resetSegmentsLabel();
                obj.resetGroupsLabel();
                obj.groupedSegments = [];
                
                obj.updateCurrentSegmentsCreator();

                obj.loadSegments();

                obj.updateSegmentsLabel();
            end
        end
        
        function handleGroupClicked(obj,~,~)
            obj.resetGroupsLabel();
            if ~isempty(obj.segments)
                segmentsGrouper = SegmentsGrouper();
                labelingStrategy = obj.labelingConfigurator.getCurrentLabelingStrategy();
                obj.groupedSegments = segmentsGrouper.groupSegments(obj.segments,labelingStrategy);
                obj.updateGroupsList();
                obj.updateGroupsLabel();
            end
        end
        
        function handleVisualizeClicked(obj,~,~)
            if ~isempty(obj.groupedSegments)
                obj.applySignalComputers();
                validData = obj.checkValidComputedSegments();
                if validData
                    obj.plotData();
                else
                    fprintf('SignalExplorerApp - %s\n',Constants.kInvalidFilterComputedError);
                end
            end
        end
        
        function handleManualSegmentationRadioChanged(obj,~,~)
            if obj.uiHandles.manualSegmentationRadio.Value == 1
                obj.isManualEventDetector = true;
                obj.updateEventDetectionTablesVisibility();
                
                obj.segmentationConfigurator.segmentationStrategies = {ManualSegmentation};
                obj.segmentationConfigurator.reloadUI();
            end
        end
        
        function handleAutomaticSegmentationRadioChanged(obj,~,~)
            if obj.uiHandles.automaticSegmentationRadio.Value == 1
                
                obj.isManualEventDetector = false;
                obj.updateEventDetectionTablesVisibility();
                
                eventDetector = obj.eventDetectorConfigurator.createEventDetectorWithUIParameters();
                segmentationStrategy = EventSegmentation(eventDetector);
                obj.segmentationConfigurator.segmentationStrategies = {segmentationStrategy};
                obj.segmentationConfigurator.reloadUI();
            end
        end
        
        function handleVisualizationStateChanged(obj,~,~)
            
            switch obj.uiHandles.plotStyleButtonGroup.SelectedObject
                case (obj.uiHandles.overlappingPlotRadio)
                    obj.visualizationState = SignalExplorerVisualizationState.kOverlappingMode;
                case (obj.uiHandles.sequentialPlotRadio)
                    obj.visualizationState = SignalExplorerVisualizationState.kSequentialMode;
                
            end
        end
        
        function handleShowLinesChanged(obj,~,~)
            
            obj.segmentsPlotter.showVerticalLines = obj.getShowLinesCheckbox();
        end
    end
    
end