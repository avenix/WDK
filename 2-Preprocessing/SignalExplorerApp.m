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
        currentSegmentsCreator;
        segmentationStrategies;
        currentSegmentationStrategy;
        
        %labeling
        labelingConfigurator;
        
        %visualisation
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
            
            obj.segmentationStrategies = {ManualSegmentation, EventSegmentation};
            obj.currentSegmentationStrategy = obj.segmentationStrategies{1};

            obj.segmentsLabeler = SegmentsLabeler();
            obj.segmentsLabeler.manualAnnotations = obj.annotations;
            
            obj.segmentsPlotter = PreprocessingSegmentsPlotter();
            
            obj.isManualEventDetector = true;
            
            obj.loadUI();
            obj.resetUI();
        end
        
        function loadUI(obj)
            
            obj.uiHandles = guihandles(signalExplorerUI);
            
            obj.uiHandles.createButton.Callback = @obj.handleLoadClicked;
            obj.uiHandles.groupButton.Callback = @obj.handleGroupClicked;
            obj.uiHandles.visualizeButton.Callback = @obj.handleVisualizeClicked;

            obj.uiHandles.manualSegmentationRadio.Callback = @obj.handleManualSegmentationRadioChanged;
            obj.uiHandles.automaticSegmentationRadio.Callback = @obj.handleAutomaticSegmentationRadioChanged;
            
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
            
            obj.labelingConfigurator = LabelingConfigurator(...
                obj.uiHandles.labelingStrategiesList);
                
            obj.updateEventDetectionTablesVisibility();
            
        end
        
        function resetUI(obj)
            obj.uiHandles.segmentsDescriptionLabel.String = "";
                          
            obj.uiHandles.groupsLabel.String = "";
            obj.uiHandles.classesList.String = "";
             
            obj.uiHandles.manualSegmentationRadio.Value = 1;
            obj.uiHandles.automaticSegmentationRadio.Value = 0;
            
            obj.uiHandles.signalComputerVariablesTable.ColumnName = {'Variable','Value'};
            obj.uiHandles.signalComputerVariablesTable.ColumnWidth = {60,40};
            
            obj.uiHandles.preprocessingSignalComputerVariablesTable.ColumnName = {'Variable','Value'};
            obj.uiHandles.preprocessingSignalComputerVariablesTable.ColumnWidth = {60,40};
            
            obj.uiHandles.signalComputerVariablesTableVisualization.ColumnName = {'Variable','Value'};
            obj.uiHandles.signalComputerVariablesTableVisualization.ColumnWidth = {60,40};
        end

        function plotData(obj)
            
            selectedClassesIdxs = obj.getSelectedClasses();
            labelingStrategy = obj.labelingConfigurator.getCurrentLabelingStrategy();
            groupNames = labelingStrategy.classNames(selectedClassesIdxs);
            obj.segmentsPlotter.sameScale = obj.getSameScale();
            obj.segmentsPlotter.plotSegments(obj.filteredSegments,groupNames);
        end

        
        % ui
        function resetGroupsLabel(obj)
            obj.uiHandles.groupsLabel.String = "";
        end
        
        function resetSegmentsLabel(obj)
            obj.uiHandles.segmentsDescriptionLabel.String = "";
        end
        
        function updateGroupsLabel(obj)
            str = sprintf('%d groups.',length(obj.groupedSegments));
            obj.uiHandles.groupsLabel.String = str;
        end
        
        function updateSegmentsLabel(obj)
            str = sprintf('%d files.',length(obj.segments));
            obj.uiHandles.segmentsDescriptionLabel.String = str;
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
                obj.uiHandles.preprocessingLabel.Visible = 'Off';
                obj.uiHandles.preprocessingSignalComputerVariablesTable.Visible = 'Off';
                obj.uiHandles.preprocessingSignalsList.Visible = 'Off';
                obj.uiHandles.preprocessingSignalComputerList.Visible = 'Off';
                obj.uiHandles.eventDetectorList.Visible = 'Off';
                obj.uiHandles.eventDetectorVariablesTable.Visible = 'Off';
            else
                obj.uiHandles.detectionLabel.Visible = 'On';
                obj.uiHandles.preprocessingLabel.Visible = 'On';
                obj.uiHandles.preprocessingSignalComputerVariablesTable.Visible = 'On';
                obj.uiHandles.preprocessingSignalsList.Visible = 'On';
                obj.uiHandles.preprocessingSignalComputerList.Visible = 'On';
                obj.uiHandles.eventDetectorList.Visible = 'On';
                obj.uiHandles.eventDetectorVariablesTable.Visible = 'On';
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
            
            obj.updateSegmentationStrategySegmentSizes();
            
            obj.currentSegmentsCreator.preprocessedSignalsLoader = PreprocessedSignalsLoader();
            if isa(obj.currentSegmentationStrategy,'EventSegmentation')
                eventDetector = obj.eventDetectorConfigurator.createEventDetectorWithUIParameters();
                obj.currentSegmentationStrategy.eventDetector = eventDetector;
                obj.currentSegmentsCreator.preprocessedSignalsLoader.preprocessor = obj.preprocessingConfigurator.createSignalComputerWithUIParameters();
                
                obj.segmentsLabeler.labelingStrategy = obj.labelingConfigurator.getCurrentLabelingStrategy();
                obj.segmentsLoader.segmentsLabeler = obj.segmentsLabeler;
            else
                obj.currentSegmentationStrategy.manualAnnotations = obj.annotations;
                obj.segmentsLoader.segmentsLabeler = [];
            end
            
            obj.currentSegmentsCreator.segmentationAlgorithm = obj.currentSegmentationStrategy;
        end
        
        function updateSegmentationStrategySegmentSizes(obj)
            
            segmentLeftSize = obj.getLeftSize();
            segmentRightSize = obj.getRightSize();
            
            obj.currentSegmentationStrategy.segmentSizeLeft = segmentLeftSize;
            obj.currentSegmentationStrategy.segmentSizeRight = segmentRightSize;
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
            obj.resetSegmentsLabel();
            obj.resetGroupsLabel();
            
            obj.updateCurrentSegmentsCreator();
            obj.loadSegments();
            
            obj.updateSegmentsLabel();
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
                obj.currentSegmentationStrategy = obj.segmentationStrategies{1};
                obj.isManualEventDetector = true;
                obj.updateEventDetectionTablesVisibility();
            end
        end
        
        function handleAutomaticSegmentationRadioChanged(obj,~,~)
            if obj.uiHandles.automaticSegmentationRadio.Value == 1
                obj.currentSegmentationStrategy = obj.segmentationStrategies{2};
                
                obj.isManualEventDetector = false;
                obj.updateEventDetectionTablesVisibility();
            end
        end
    end
    
end