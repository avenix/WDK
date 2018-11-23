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
        plotAxes;
        uiHandles;
        axesHandles;
        colorsPerSignal = {[0,0,1,0.3],[1,0,0,0.3],[1,0,1,0.3]};
    end
    
    methods (Access = public)
        function obj = SignalExplorerApp()
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
            
            obj.isManualEventDetector = true;
            
            obj.loadUI();
            obj.resetUI();
        end
        
        function loadUI(obj)
            
            obj.uiHandles = guihandles(signalExplorerUI);
            obj.loadPlotAxes();
            
            obj.uiHandles.createButton.Callback = @obj.handleLoadClicked;
            obj.uiHandles.groupButton.Callback = @obj.handleGroupClicked;
            obj.uiHandles.visualizeButton.Callback = @obj.handleVisualizeClicked;

            obj.uiHandles.manualSegmentationCheckBox.Callback = @obj.handleManualSegmentationCheckBoxChanged;
            obj.uiHandles.automaticSegmentationCheckBox.Callback = @obj.handleAutomaticSegmentationCheckBoxChanged;
            obj.uiHandles.eventDetectorsList.Callback = @obj.handleEventDetectorSelected;
            
            obj.preprocessingConfigurator = PreprocessingConfigurator(...
                obj.uiHandles.preprocessingSignalsList,...
                obj.uiHandles.preprocessingSignalComputerList,...
                obj.uiHandles.preprocessingSignalComputerVariablesTable);
            
            obj.preprocessingConfiguratorVisualization = PreprocessingConfigurator(...
                obj.uiHandles.signalsListVisualization,...
                obj.uiHandles.signalComputersListVisualization,...
                obj.uiHandles.signalComputerVariablesTableVisualization);
            
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
             
            obj.uiHandles.manualSegmentationCheckBox.Value = 1;
            obj.uiHandles.automaticSegmentationCheckBox.Value = 0;
            
            obj.uiHandles.signalComputerVariablesTable.ColumnName = {'Variable','Value'};
            obj.uiHandles.signalComputerVariablesTable.ColumnWidth = {60,40};
            
            obj.uiHandles.preprocessingSignalComputerVariablesTable.ColumnName = {'Variable','Value'};
            obj.uiHandles.preprocessingSignalComputerVariablesTable.ColumnWidth = {60,40};
        end
        
        function loadPlotAxes(obj)
            
            obj.plotAxes = axes(obj.uiHandles.figure1);
            obj.plotAxes.Units = 'characters';
            obj.plotAxes.Position  = [40.0 12 215 65];
            obj.plotAxes.Visible = 'Off';
        end
        
        function plotData(obj)
            obj.clearAxes();
            
            labelingStrategy = obj.labelingConfigurator.getCurrentLabelingStrategy();
            
            nClasses = length(obj.filteredSegments);
            subplotM = ceil(sqrt(nClasses));
            subplotN = ceil(nClasses / subplotM);
            
            for i = 1 : nClasses
                obj.axesHandles(i) = subplot(subplotN,subplotM,i);
                titleStr = labelingStrategy.classNames{i};
                title(titleStr);
                hold on;
                segmentsCurrentGroup = obj.filteredSegments{i};
                for j = 1 : length(segmentsCurrentGroup)
                    segment = segmentsCurrentGroup(j);
                    data = segment.window;
                    for signal = 1 : min(size(data,2),3)
                        plotHandle = plot(data(:,signal),'Color',obj.colorsPerSignal{signal},'LineWidth',0.4);
                        plotHandle.Color(4) = 0.4;
                    end
                end
                
                subplotAxes = obj.axesHandles(i);
                axesPosition = get(subplotAxes,'Position');
                axesPosition(1) = axesPosition(1) + 0.015;
                set(subplotAxes,'Position',axesPosition);
                axis tight;
                %set(obj.axesHandles(i),'style','tight');
            end
            
            if obj.getSameScale() == 1
                linkaxes(obj.axesHandles,'xy');
            end
        end
        
        function clearAxes(obj)
            for i = 1 : length(obj.axesHandles)
                cla(obj.axesHandles(i));
            end
            obj.axesHandles = [];
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
            str = sprintf('%d segments.',length(obj.segments));
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
        
        %methods
        function applySignalComputers(obj)
            
            filterComputer = obj.preprocessingConfiguratorVisualization.createSignalComputerWithUIParameters();
            selectedClassesIdxs = obj.uiHandles.classesList.Value;
            
            nSelectedClasses = length(selectedClassesIdxs);
            
            obj.filteredSegments = cell(1,nSelectedClasses);
            
            for i = 1 : nSelectedClasses
                segmentsCurrentGroup = obj.groupedSegments{i};
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
        
        %handles  
        function handleEventDetectorSelected(obj,~,~)
            obj.updateEventDetectorFromUI();
            obj.updateEventDetectionTables();
        end

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
                obj.plotData();
            end
        end
        
        function handleManualSegmentationCheckBoxChanged(obj,~,~)
            if obj.uiHandles.manualSegmentationCheckBox.Value == 1
                obj.currentSegmentationStrategy = obj.segmentationStrategies{1};
                obj.currentEventDetector = [];
                obj.currentEventDetectorVariables = [];
                obj.isManualEventDetector = true;
                obj.updateEventDetectionTables();
            end
        end
        
        function handleAutomaticSegmentationCheckBoxChanged(obj,~,~)
            if obj.uiHandles.automaticSegmentationCheckBox.Value == 1
                obj.currentSegmentationStrategy = obj.segmentationStrategies{2};
                
                obj.isManualEventDetector = false;
                obj.updateEventDetectionTablesVisibility();
            end
        end
    end
    
end