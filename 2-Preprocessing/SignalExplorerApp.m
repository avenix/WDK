classdef SignalExplorerApp < handle
    
    properties (Access = private)
        
        %classes
        classesMap;
        annotations;
        
        %data loader
        preprocessedSignalsLoader;
        segmentsLoader;
        segmentsLabeler;
        
        %data
        segments;
        groupedSegments;
        filteredSegments;
        
        %preprocessing
        signals;
        signalComputers;
        signalComputerStrings;
        currentSignalComputerVariables;
        
        %detection (only for automatic)
        isManualEventDetector;
        eventDetectors;
        currentEventDetector;
        currentEventDetectorVariables;
        
        %segmentation
        currentSegmentsCreator;
        segmentationStrategies;
        currentSegmentationStrategy;
                
        %group
        groupStrings = {'default','good/bad','grouped'};
        groupStrategies;
        currentGroup = 2;
        
        %ui plotting
        plotAxes;
        uiHandles;
        axesHandles;
        colorsPerSignal = {[0,0,1,0.3],[1,0,0,0.3],[1,0,1,0.3]};
    end
    
    methods (Access = public)
        function obj = SignalExplorerApp()
            obj.classesMap = ClassesMap();
            dataLoader = DataLoader();
            obj.annotations = dataLoader.loadAllAnnotations();
                        
            obj.preprocessedSignalsLoader = PreprocessedSignalsLoader();
            obj.segmentsLoader = SegmentsLoader();
            obj.currentSegmentsCreator = SegmentsCreator();
            obj.segmentsLoader.segmentsCreator = obj.currentSegmentsCreator;
            
            obj.segmentationStrategies = {ManualSegmentation, EventSegmentation};
            obj.currentSegmentationStrategy = obj.segmentationStrategies{1};

            obj.groupStrategies = dataLoader.loadAllLabelingStrategies();
            
            obj.segmentsLabeler = SegmentsLabeler();
            obj.segmentsLabeler.manualAnnotations = obj.annotations;
            
            obj.isManualEventDetector = true;
            
            obj.loadSignalComputers();
            obj.loadEventDetectors();
            obj.loadUI();
            obj.resetUI();
        end
        
        function loadUI(obj)
            
            obj.uiHandles = guihandles(signalExplorerUI);
            obj.loadPlotAxes();
            
            obj.uiHandles.createButton.Callback = @obj.handleLoadClicked;
            obj.uiHandles.groupButton.Callback = @obj.handleGroupClicked;
            obj.uiHandles.visualizeButton.Callback = @obj.handleVisualizeClicked;
            obj.uiHandles.signalComputersList.Callback = @obj.handleSelectedSignalComputerChanged;
            
            obj.uiHandles.manualSegmentationCheckBox.Callback = @obj.handleManualSegmentationCheckBoxChanged;
            obj.uiHandles.automaticSegmentationCheckBox.Callback = @obj.handleAutomaticSegmentationCheckBoxChanged;
            obj.uiHandles.eventDetectorsList.Callback = @obj.handleEventDetectorSelected;
            
            obj.fillLabelingStrategiesList();
            obj.fillSignalComputersList();
            obj.updateEventDetectorsList();
            
            obj.updateSignalComputerVariablesTable();
            obj.updateEventDetectionTables();
        end
        
        function resetUI(obj)
            obj.uiHandles.segmentsDescriptionLabel.String = "";
            obj.uiHandles.signalsList.String = "";
            obj.uiHandles.groupsLabel.String = "";
            obj.uiHandles.classesList.String = "";
             
            obj.uiHandles.manualSegmentationCheckBox.Value = 1;
            obj.uiHandles.automaticSegmentationCheckBox.Value = 0;
            
            obj.uiHandles.signalComputerVariablesTable.ColumnName = {'Variable','Value'};
            obj.uiHandles.signalComputerVariablesTable.ColumnWidth = {60,40};
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
        
        function loadEventDetectors(obj)
            simplePeakDetector = SimplePeakDetector();
            obj.eventDetectors = {simplePeakDetector};
        end
        
        function loadPlotAxes(obj)
            
            obj.plotAxes = axes(obj.uiHandles.figure1);
            obj.plotAxes.Units = 'characters';
            obj.plotAxes.Position  = [40.0 12 215 65];
            obj.plotAxes.Visible = 'Off';
        end
        
        function fillLabelingStrategiesList(obj)
            groupStrategiesCellArray = Helper.listLabelingStrategies();
            obj.uiHandles.groupStrategiesList.String = Helper.cellArrayToString(groupStrategiesCellArray);
        end
        
        function fillSignalComputersList(obj)
            obj.uiHandles.signalComputersList.String = obj.signalComputerStrings;
        end
        
        function fillSignalsList(obj)
            obj.uiHandles.signalsList.String = Helper.arrayToString(obj.signals);
        end
        
        function plotData(obj)
            obj.clearAxes();
            
            labelingStrategy = obj.getCurrentLabelingStrategy();
            
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
        function updateSignalComputerVariablesTable(obj)
            obj.uiHandles.signalComputerVariablesTable.Data = Helper.propertyArrayToCellArray(obj.currentSignalComputerVariables);
        end
        
        function updateEventSelectionVariablesTable(obj)
            obj.uiHandles.eventDetectorVariablesTable.Data = Helper.propertyArrayToCellArray(obj.currentEventDetectorVariables);
        end
        
        function signalComputer = getCurrentSignalComputer(obj)
            idx = obj.uiHandles.signalComputersList.Value;
            signalComputer = obj.signalComputers{idx};
        end
        
        function eventDetector = getCurrentEventDetector(obj)
            idx = obj.uiHandles.eventDetectorsList.Value;
            eventDetector = obj.eventDetectors{idx};
        end
        
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
        
        function labelingStrategy = getCurrentLabelingStrategy(obj)
            labelingStrategyIdx = obj.getSelectedLabelingIdx();
            labelingStrategy = obj.groupStrategies{labelingStrategyIdx};
        end
        
        function idx = getSelectedLabelingIdx(obj)
            idx = obj.uiHandles.groupStrategiesList.Value;
        end
        
        function value = getSameScale(obj)
            value = obj.uiHandles.sameScaleCheckBox.Value;
        end
        
        function signalIdxs = getSelectedSignalIdxs(obj)
            signalIdxs = obj.uiHandles.signalsList.Value;
        end
        
        function updateGroupsList(obj)
            labelingStrategy = obj.getCurrentLabelingStrategy();
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
        
        function updateEventDetectionTables(obj)
            if obj.isManualEventDetector
                obj.uiHandles.eventDetectorsList.Visible = 'Off';
                obj.uiHandles.eventDetectorVariablesTable.Visible = 'Off';
            else
                obj.uiHandles.eventDetectorsList.Visible = 'On';
                obj.uiHandles.eventDetectorVariablesTable.Visible = 'On';
                obj.updateEventDetectorFromUI();
                obj.updateEventSelectionVariablesTable();
            end
        end
        
        function updateSelectedSignalComputer(obj)
            signalComputer = obj.getCurrentSignalComputer();
            obj.currentSignalComputerVariables = signalComputer.getEditableProperties();
        end
        
        function updateEventDetectorsList(obj)
            obj.uiHandles.eventDetectorsList.String = Helper.generatePeakDetectorNames(obj.eventDetectors);
            obj.uiHandles.eventDetectorsList.Value = 1;
        end
        
        %methods
        function signalComputer = createSignalComputerWithUIParameters(obj)
            signalComputer = obj.getCurrentSignalComputer();
            
            data = obj.uiHandles.signalComputerVariablesTable.Data;
            for i = 1 : size(data,1)
                variableName = data{i,1};
                variableValue = data{i,2};
                property = Property(variableName,variableValue);
                signalComputer.setProperty(property);
            end
        end
        
        function applySignalComputers(obj)
            
            filterComputer = obj.createSignalComputerWithUIParameters();
            selectedClassesIdxs = obj.uiHandles.classesList.Value;
            selectedSignals = obj.getSelectedSignalIdxs();
            
            nSelectedClasses = length(selectedClassesIdxs);
            
            obj.filteredSegments = cell(1,nSelectedClasses);
            
            for i = 1 : nSelectedClasses
                segmentsCurrentGroup = obj.groupedSegments{i};
                segmentsArray = repmat(Segment(),1,length(segmentsCurrentGroup));

                for j = 1 : length(segmentsArray)
                    segment = segmentsCurrentGroup(j);
                    data = segment.window;
                    
                    signal = data(:,selectedSignals);
                    filteredData = filterComputer.compute(signal);
                    
                    filteredSegment = Segment(segment.file,filteredData,segment.class,segment.eventIdx);
                    segmentsArray(j) = filteredSegment;
                end
                obj.filteredSegments{i} = segmentsArray;
            end
        end
        
        function updateEventDetectorFromUI(obj)
            obj.currentEventDetector = obj.getCurrentEventDetector();
            obj.currentEventDetectorVariables = obj.currentEventDetector.getEditableProperties();
        end
        
        function updateSignalsList(obj)
            if ~isempty(obj.segments)
                segmentsFirstPlayer = obj.segments{1};
                if ~isempty(segmentsFirstPlayer)
                    firstSegment = segmentsFirstPlayer(1);
                    obj.signals = 1:size(firstSegment.window,2);
                end
            end
        end
        
        %TODO refactor this to not use hardcoded positions 15 16 17
        function compositeComputer = getDefaultAutomaticSegmentationPreprocessor(~)
            compositeComputer = CompositeComputer();
            
            axisSelector = AxisSelectorComputer();
            axisSelector.axis = [15 16 17];
            energyComputer = SignalComputer.EnergyComputer();
            
            compositeComputer.computers = {axisSelector, energyComputer};
        end

        function updateCurrentSegmentsCreator(obj)
            
            obj.updateSegmentationStrategySegmentSizes();
            
            if isa(obj.currentSegmentationStrategy,'EventSegmentation')

                obj.currentSegmentationStrategy.eventDetector = obj.currentEventDetector;
                
                obj.currentSegmentationStrategy.signalComputer = obj.getDefaultAutomaticSegmentationPreprocessor();
                obj.segmentsLabeler.labelingStrategy = obj.getCurrentLabelingStrategy();
                obj.segmentsLoader.segmentsLabeler = obj.segmentsLabeler;

            else
                
                obj.currentSegmentationStrategy.manualAnnotations = obj.annotations;
                obj.segmentsLoader.segmentsLabeler = [];
            end
            
            obj.currentSegmentsCreator.preprocessedSignalsLoader = PreprocessedSignalsLoader();
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
            obj.updateSignalsList();
            obj.fillSignalsList();
        end
        
        function handleGroupClicked(obj,~,~)
            obj.resetGroupsLabel();
            if ~isempty(obj.segments)
                segmentsGrouper = SegmentsGrouper();
                segmentsGrouper.classesMap = obj.classesMap;
                labelingStrategy = obj.getCurrentLabelingStrategy();

                obj.groupedSegments = segmentsGrouper.groupSegments(obj.segments,labelingStrategy);
                obj.updateGroupsList();
                obj.updateGroupsLabel();
            end
        end
        
        function handleVisualizeClicked(obj,~,~)
            obj.applySignalComputers();
            obj.plotData();
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
                obj.updateEventDetectionTables();
            end
        end
        
        function handleSelectedSignalComputerChanged(obj,~,~)
            obj.updateSelectedSignalComputer();
            obj.updateSignalComputerVariablesTable();
        end
    end
    
end