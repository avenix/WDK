%UI for creating feature tables, running feature selection, classifying and
%exporting. The entire ARC chain can be selected
classdef ClassiffierApp < handle
    
    properties (Access = private)
        %file names
        fileNames;
        
        %data
        tableSet;
        trainTable;
        testTable;
        filesMap;
        annotations;
        
        %loaders
        segmentsLoader;
        segmentsLabeler;
        dataLoader;
        
        %grouped tables
        groupedTrainTable;
        groupedTestTable;
        
        %preprocessing
        preprocessingConfigurator;
        
        %detection
        eventDetectorConfigurator;
        isManualEventDetector;
        
        %segmentation
        currentSegmentsCreator;
        segmentationStrategies;
        currentSegmentationStrategy;
        
        %labeling
        labelingConfigurator;
        labelingConfiguratorRegrouping;
        defaultLabelingStrategy;
        
        %helpers
        featuresTableLoader;
        featureNormalizer;
        trainer;
        confusionMatrixPlotter;
        tableExporter;
        featureSelector;
        
        %results
        confusionMatrix;
        
        %ui
        uiHandles;
        confusionMatrixAxes;
    end
    
    methods (Access = public)
        function obj = ClassiffierApp()
            
            obj.fileNames = Helper.listDataFiles();
            
            obj.dataLoader = DataLoader();
            obj.annotations = obj.dataLoader.loadAllAnnotations();
            
            obj.defaultLabelingStrategy = ClassLabelingStrategy();
            
            obj.segmentsLoader = SegmentsLoader();
            obj.currentSegmentsCreator = SegmentsCreator();
            obj.segmentsLoader.segmentsCreator = obj.currentSegmentsCreator;
            
            obj.segmentationStrategies = {ManualSegmentation, EventSegmentation};
            obj.currentSegmentationStrategy = obj.segmentationStrategies{1};
            
            obj.segmentsLabeler = SegmentsLabeler();
            obj.segmentsLabeler.manualAnnotations = obj.annotations;
            
            signalComputer = FeatureExtractor2.createDefaultSignalComputer();
            featureComputers = FeatureExtractor2.createDefaultFeatureExtractors();
            featureExtractor = FeatureExtractor2(signalComputer,featureComputers);
            %featureNames = featureExtractor.computeFeatureNames();
            obj.featuresTableLoader = FeaturesTableLoader(featureExtractor);
            
            obj.featuresTableLoader.segmentsLoader = obj.segmentsLoader;
            
            obj.featureNormalizer = FeatureNormalizer();
            obj.featureSelector = FeatureSelector();
            obj.trainer = Trainer();
            obj.confusionMatrixPlotter = ConfusionMatrixPlotter();
            obj.tableExporter = TableExporter();
            obj.filesMap = containers.Map();
            
            obj.isManualEventDetector = true;
            
            obj.loadfilesMap();
            
            obj.loadUI();
            obj.resetUI();
        end
    end
    
    methods (Access = private)

        function loadUI(obj)
            
            obj.uiHandles = guihandles(classifierAppUI);
            obj.loadConfusionMatrixAxes();
            
            %data
            obj.uiHandles.moveFileRightButton.Callback = @obj.handleMoveFileRightClicked;
            obj.uiHandles.moveFileLeftButton.Callback = @obj.handleMoveFileLeftClicked;
            
            %segmentation
            obj.uiHandles.manualSegmentationRadio.Callback = @obj.handleManualSegmentationRadioChanged;
            obj.uiHandles.automaticSegmentationRadio.Callback = @obj.handleAutomaticSegmentationRadioChanged;
            obj.uiHandles.createTableButton.Callback = @obj.handleCreateTablesClicked;
            obj.uiHandles.printTrainTableButton.Callback = @obj.handlePrintTrainTableClicked;
            obj.uiHandles.printTestTableButton.Callback = @obj.handlePrintTestTableClicked;
            
            %grouping
            obj.uiHandles.groupButton.Callback = @obj.handleGroupTableClicked;
            obj.uiHandles.printGroupedTrainTableButton.Callback = @obj.handlePrintGroupedTrainTableClicked;
            obj.uiHandles.printGroupedTestTableButton.Callback = @obj.handlePrintGroupedTestTableClicked;
            
            %features
            obj.uiHandles.findFeaturesButton.Callback = @obj.handleFindFeaturesClicked;
            obj.uiHandles.selectFeaturesButton.Callback = @obj.handleSelectFeaturesClicked;
            obj.uiHandles.printFeatures.Callback = @obj.handlePrintFeaturesClicked;
            
            %classification
            obj.uiHandles.classifyButton.Callback = @obj.handleClassifyClicked;
            obj.uiHandles.regroupButton.Callback = @obj.handleRegroupClicked;
            obj.uiHandles.normalizeButton.Callback = @obj.handleNormalizeClicked;
            
            %deployment
            obj.uiHandles.exportButton.Callback = @obj.handleExportClicked;
            
            obj.preprocessingConfigurator = PreprocessingConfigurator(...
                obj.uiHandles.preprocessingSignalsList,...
                obj.uiHandles.preprocessingSignalComputerList,...
                obj.uiHandles.preprocessingSignalComputerVariablesTable);
            
            obj.preprocessingConfigurator.setDefaultColumnNames();
            
            obj.eventDetectorConfigurator = EventDetectorConfigurator(...
                obj.uiHandles.eventDetectorList...
                ,obj.uiHandles.eventDetectorVariablesTable);
            
            obj.labelingConfigurator = LabelingConfigurator(...
                obj.uiHandles.labelingStrategiesList);
            
            obj.labelingConfiguratorRegrouping = LabelingConfigurator(...
                obj.uiHandles.regroupingLabelingStrategyList);
            
            obj.updateEventDetectionTablesVisibility();
            
        end
                
        function loadConfusionMatrixAxes(obj)
            obj.confusionMatrixAxes = axes(obj.uiHandles.figure1);
            obj.confusionMatrixAxes.Units = 'characters';
            obj.confusionMatrixAxes.Position  = [90 10 117 44];
            obj.confusionMatrixAxes.Visible = 'On';
        end
        
        function loadfilesMap(obj)
            for i = 1 : length(obj.fileNames)
                fileName = obj.fileNames{i};
                obj.filesMap(fileName) = i;
            end
        end
        
        function resetUI(obj)
            obj.uiHandles.trainTableLabel.String = '';
            obj.uiHandles.testTableLabel.String = '';
            
            obj.uiHandles.manualSegmentationRadio.Value = 1;
            obj.uiHandles.automaticSegmentationRadio.Value = 0;
            
            obj.uiHandles.minimalWithPassLabelingRadio.Value = 1;
            
            obj.updateBestFeaturesText();
            obj.populateFilesList();
            
            obj.uiHandles.exportTrainDataCheck.Value = 1;
            obj.uiHandles.exportTestDataCheck.Value = 1;
            obj.uiHandles.exportNormalisationValuesDataCheck.Value = 1;
            obj.uiHandles.exportNormalTableRadio.Value = 0;
            obj.uiHandles.exportGroupedTableRadio.Value = 1;
            
            obj.uiHandles.shouldNormalizeFeaturesCheck.Value = 1;
            
            obj.uiHandles.exportNumericLabelsRadio.Value = 1;
            obj.uiHandles.exportTextLabelsRadio.Value = 0;
            
            obj.updateTrainTableLabel();
            obj.updateTestTableLabel();
            obj.updateGroupedTablesLabels();
            obj.uiHandles.trainList.Value = 1 : length(obj.fileNames)-1;
            obj.uiHandles.testList.Value = 1;
            
            cla(obj.confusionMatrixAxes);
            obj.confusionMatrixAxes.Visible = 'Off';
        end
        
        %% methods
        function populateFilesList(obj)
            obj.uiHandles.trainList.String = obj.fileNames(1:end-1);
            obj.uiHandles.testList.String = obj.fileNames(end);
        end
        
        function [selectedFileStr, list] = popSelectedFileFromList(~,list)
            selectedFileIdxs = list.Value;
            list.Value = [];
            selectedFileStr = list.String(selectedFileIdxs);
            listIndices = setdiff(1:length(list.String),selectedFileIdxs);
            list.String = list.String(listIndices);
        end
        
        function list = pushFileToList(~,fileStr,list)
            list.String = [list.String; fileStr];
        end
        
        function updateSegmentationStrategySegmentSizes(obj)
            
            segmentLeftSize = obj.getLefSegmentSize();
            segmentRightSize = obj.getRightSegmentSize();
            
            obj.currentSegmentationStrategy.segmentSizeLeft = segmentLeftSize;
            obj.currentSegmentationStrategy.segmentSizeRight = segmentRightSize;
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
        
         function table = createTableWithFilesInList(obj,list)
            selectedFileIdxs = list.Value;
            table = [];
            if ~isempty(selectedFileIdxs)
                fileIdxs = obj.getGlobalFileIdxs(list);
                table = obj.tableSet.mergedTableForIndices(fileIdxs);
            end
        end
        
        function fileIdxs = getGlobalFileIdxs(obj,list)
            
            fileIdxs = list.Value;
            for i = 1 : length(fileIdxs)
                fileIdx = fileIdxs(i);
                fileName = list.String{fileIdx};
                fileIdx = obj.filesMap(fileName);
                fileIdxs(i) = fileIdx;
            end
        end
        
        function printTable(obj,table)
            if ~isempty(table)
                printer = StatisticsPrinter();
                printer.printTableStatistics(table, obj.defaultLabelingStrategy, 0);
            end
        end
        
        function printGroupedTable(obj,table)
            if ~isempty(table)
                printer = StatisticsPrinter();
                labelingStrategy = obj.labelingConfigurator.getCurrentLabelingStrategy();
                printer.printTableStatistics(table, labelingStrategy, 0);
            end
        end

        function normalizeGroupedTables(obj)
            %normalise features
            if obj.uiHandles.shouldNormalizeFeaturesCheck.Value == 1 && ~isempty(obj.groupedTrainTable)
                
                obj.featureNormalizer.fit(obj.groupedTrainTable);
                
                %obj.featureNormalizer.fitDefaultValues();
                obj.groupedTrainTable = obj.featureNormalizer.normalize(obj.groupedTrainTable);
            end
            if ~isempty(obj.groupedTestTable)
                obj.groupedTestTable = obj.featureNormalizer.normalize(obj.groupedTestTable);
            end
        end
        
         function groupedConfusionmatrix = groupConfusionMatrix(obj,labelingStrategy)
            numClasses = labelingStrategy.numClasses;
            groupedConfusionmatrix = zeros(numClasses,numClasses);
            for i = 1 : length(obj.confusionMatrix)
                row = labelingStrategy.labelForClass(i);
                for j = 1 : length(obj.confusionMatrix)
                    col = labelingStrategy.labelForClass(j);
                    groupedConfusionmatrix(row,col) = groupedConfusionmatrix(row,col) + obj.confusionMatrix(i,j);
                end
            end
        end
        
        function computeConfusionMatrix(obj,predictedLabels,shouldBeLabels)
            labelingStrategy = obj.labelingConfigurator.getCurrentLabelingStrategy();
            nClasses = labelingStrategy.numClasses;
            obj.confusionMatrix = confusionmat(shouldBeLabels,predictedLabels,'Order',1:nClasses);
        end
        
        function plotConfusionMatrix(obj,confusionMatrix,labelingStrategy)
            obj.confusionMatrixPlotter.plotConfusionMatrix(confusionMatrix,labelingStrategy.classNames);
        end
        
        function exportTrainData(obj)
            table = obj.groupedTrainTable;
            if isempty(table)
                table = obj.trainTable;
            end
            if ~isempty(table)
                tableToExport = ClassiffierApp.convertTableToExport(table);
                obj.exportTable(tableToExport,Constants.kTrainDataFileName);
            end
        end
        
        function exportTestData(obj)
            table = obj.groupedTestTable;
            if isempty(table)
                table = obj.testTable;
            end
            
            if ~isempty(table)
                tableToExport = ClassiffierApp.convertTableToExport(table);
                obj.exportTable(tableToExport,Constants.kTestDataFileName);
            end
        end
        
        function table = convertLabelsToText(obj,table)
            labelingStrategy = obj.labelingConfigurator.getCurrentLabelingStrategy();
            table.label = labelingStrategy.labelsToString(table.label+1)';
        end
        
        function exportTable(obj,table,fileName)
            if ~isempty(table)
                if obj.uiHandles.exportTextLabelsRadio.Value == 1
                    table = obj.convertLabelsToText(table);
                end
                
                if obj.uiHandles.matlabFormatCheckbox.Value == 1
                    obj.dataLoader.saveData(table,fileName);
                else
                    obj.tableExporter.exportTable(table,fileName);
                end
            end
        end
        
        function exportNormalisationValues(obj)
            selectedFeatureIdxs = obj.featureSelector.selectedFeatureIdxs;
            if ~isempty(obj.featureNormalizer.means)
                means = obj.featureNormalizer.means(selectedFeatureIdxs);
                stds = obj.featureNormalizer.stds(selectedFeatureIdxs);
                normalisationValues = array2table([means' stds']);
                
                normalisationValues.Properties.VariableNames = {'means','deviations'};
                normalisationValuesArray = table2array(normalisationValues);
                transposedNormalisationValues = array2table(normalisationValuesArray.');
                transposedNormalisationValues.Properties.RowNames = normalisationValues.Properties.VariableNames;
                
                featureExtractor = obj.featuresTableLoader.featureExtractor;
                transposedNormalisationValues.Properties.VariableNames = featureExtractor.featureNames(selectedFeatureIdxs);
                
                obj.tableExporter.exportTable(transposedNormalisationValues,Constants.kNormalisationFileName);
            end
        end
        
        
        
        %% UI
        function updateEventDetectionTablesVisibility(obj)
            if obj.isManualEventDetector
                obj.uiHandles.detectionPanel.Visible = 'Off';
                obj.uiHandles.preprocessingPanel.Visible = 'Off';
                obj.uiHandles.detectionLabel.Visible = 'Off';
                obj.uiHandles.preprocessingLabel.Visible = 'Off';
                obj.uiHandles.preprocessingSignalComputerVariablesTable.Visible = 'Off';
                obj.uiHandles.preprocessingSignalsList.Visible = 'Off';
                obj.uiHandles.preprocessingSignalComputerList.Visible = 'Off';
                obj.uiHandles.eventDetectorList.Visible = 'Off';
                obj.uiHandles.eventDetectorVariablesTable.Visible = 'Off';
            else
                obj.uiHandles.detectionPanel.Visible = 'On';
                obj.uiHandles.preprocessingPanel.Visible = 'On';
                obj.uiHandles.detectionLabel.Visible = 'On';
                obj.uiHandles.preprocessingLabel.Visible = 'On';
                obj.uiHandles.preprocessingSignalComputerVariablesTable.Visible = 'On';
                obj.uiHandles.preprocessingSignalsList.Visible = 'On';
                obj.uiHandles.preprocessingSignalComputerList.Visible = 'On';
                obj.uiHandles.eventDetectorList.Visible = 'On';
                obj.uiHandles.eventDetectorVariablesTable.Visible = 'On';
            end
        end
        
        function leftSize = getLefSegmentSize(obj)
            leftSizeStr = obj.uiHandles.leftSegmentSizeText.String;
            leftSize = str2double(leftSizeStr);
        end
        
        function rightSize = getRightSegmentSize(obj)
            rightSizeStr = obj.uiHandles.rightSegmentSizeText.String;
            rightSize = str2double(rightSizeStr);
        end
        
        function updateTrainTableLabel(obj)
            if isempty(obj.trainTable)
                obj.uiHandles.trainTableLabel.String = 'train table: empty';
            else
                tableHeight = height(obj.trainTable);
                tableWidth = width(obj.trainTable);
                obj.uiHandles.trainTableLabel.String = sprintf('train table: %dx%d',tableHeight,tableWidth);
            end
        end
        
        function updateTestTableLabel(obj)
            if isempty(obj.testTable)
                obj.uiHandles.testTableLabel.String = 'test table: empty';
            else
                tableHeight = height(obj.testTable);
                tableWidth = width(obj.testTable);
                obj.uiHandles.testTableLabel.String = sprintf('test table: %dx%d',tableHeight,tableWidth);
            end
        end
               
        function idx = getSelectedSegmentLoaderIdx(obj)
            switch obj.uiHandles.segmentationGroup.SelectedObject
                case obj.uiHandles.manualSegmentationRadio
                    idx = 1;
                case obj.uiHandles.simplifiedSegmentationRadio
                    idx = 2;
            end
        end
        
        function updateGroupedTablesLabels(obj)
            labelingStrategy = obj.labelingConfigurator.getCurrentLabelingStrategy();
            obj.uiHandles.groupedTrainTableLabel.String = obj.labelForTable(obj.groupedTrainTable,'train',labelingStrategy);
            obj.uiHandles.groupedTestTableLabel.String = obj.labelForTable(obj.groupedTestTable,'test',labelingStrategy);
        end

        function idx = getSelectedRegroupingLabelingIdx(obj)
            idx = -1;
            switch obj.uiHandles.regroupGroup.SelectedObject
                case obj.uiHandles.regroupingGoodBadLabelingRadio
                    idx = 2;
                case obj.uiHandles.regroupingGroupedLabelingRadio
                    idx = 3;
            end
        end
        
        function nFeatures = getNFeatures(obj)
            nFeaturesStr = get(obj.uiHandles.nFeaturesText,'String');
            nFeatures = str2double(nFeaturesStr);
        end
        
        function updateBestFeaturesText(obj)
            featuresStr = '';
            selectedFeatures = obj.featureSelector.selectedFeatureIdxs;
            for i = 1 : length(selectedFeatures)
                featureIdx = selectedFeatures(i);
                featuresStr = sprintf('%s %d,',featuresStr,featureIdx);
            end
            
            obj.uiHandles.featuresText.String = featuresStr;
        end

        
        %% handles
        function handleMoveFileRightClicked(obj,~,~)
            [selectedFileStr, obj.uiHandles.trainList] = obj.popSelectedFileFromList(obj.uiHandles.trainList);
            obj.uiHandles.testList = obj.pushFileToList(selectedFileStr,obj.uiHandles.testList);
        end
        
        function handleMoveFileLeftClicked(obj,~,~)
            selectedFileStr = obj.popSelectedFileFromList(obj.uiHandles.testList);
            obj.pushFileToList(selectedFileStr,obj.uiHandles.trainList);
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
        
        function handleCreateTablesClicked(obj,~,~)
            
            obj.updateCurrentSegmentsCreator();
            
            obj.tableSet = obj.featuresTableLoader.loadAllTables();
            
            obj.trainTable = obj.createTableWithFilesInList(obj.uiHandles.trainList);
            obj.testTable = obj.createTableWithFilesInList(obj.uiHandles.testList);
            
            obj.updateTrainTableLabel();
            obj.updateTestTableLabel();
        end
        
        function handlePrintTrainTableClicked(obj,~,~)
            obj.printTable(obj.trainTable);
        end
        
        function handlePrintTestTableClicked(obj,~,~)
            obj.printTable(obj.testTable);
        end
        
        function handleGroupTableClicked(obj,~,~)
            
            labelingStrategy = obj.labelingConfigurator.getCurrentLabelingStrategy();
            
            obj.groupedTrainTable = obj.groupTable(obj.trainTable,labelingStrategy);
            obj.groupedTestTable = obj.groupTable(obj.testTable,labelingStrategy);
            
            obj.normalizeGroupedTables();
            obj.updateGroupedTablesLabels();
        end
                
        function handlePrintGroupedTrainTableClicked(obj,~,~)
            obj.printGroupedTable(obj.groupedTrainTable);
        end
        
        function handlePrintGroupedTestTableClicked(obj,~,~)
            obj.printGroupedTable(obj.groupedTestTable);
        end
                
        function handleFindFeaturesClicked(obj,~,~)
            if ~isempty(obj.groupedTrainTable)
                nFeatures = obj.getNFeatures();
                obj.featureSelector.findBestFeaturesForTable(obj.groupedTrainTable,nFeatures);
                obj.updateBestFeaturesText();
            end
        end
     
        function handleSelectFeaturesClicked(obj,~,~)
            if ~isempty(obj.groupedTrainTable)
                obj.groupedTrainTable = obj.featureSelector.selectFeaturesForTable(obj.groupedTrainTable);
                
                if ~isempty(obj.groupedTestTable)
                    obj.groupedTestTable = obj.featureSelector.selectFeaturesForTable(obj.groupedTestTable);
                    
                end
            end
            
            %group labels
            obj.updateGroupedTablesLabels();
        end
        
        function handlePrintFeaturesClicked(obj,~,~)
            
            if ~isempty(obj.groupedTrainTable)
                featureIdxs = obj.featureSelector.bestFeatures;
                for i = 1 : length(featureIdxs)
                    featureIdx = featureIdxs(i);
                    featureName = obj.trainTable.Properties.VariableNames{featureIdx};
                    fprintf('%d - %s\n',featureIdx,featureName);
                end
            end
        end
        
        function handleClassifyClicked(obj,~,~)
            
            if ~isempty(obj.groupedTrainTable) && ~isempty(obj.groupedTestTable)
                
                cla(obj.confusionMatrixAxes);
                
                obj.trainer.train(obj.groupedTrainTable);
                
                predictors = obj.groupedTestTable(:,1:end-1);
                predictedLabels = obj.trainer.test(predictors);
                obj.computeConfusionMatrix(predictedLabels,obj.groupedTestTable.label);
                
                labelingStrategy = obj.labelingConfigurator.getCurrentLabelingStrategy();
                obj.plotConfusionMatrix(obj.confusionMatrix,labelingStrategy);
            end
        end
        
        function handleRegroupClicked(obj,~,~)
            if ~isempty(obj.confusionMatrix)
                cla(obj.confusionMatrixAxes);
                labelingStrategy = obj.labelingConfiguratorRegrouping.getCurrentLabelingStrategy();
                regroupedConfusionMatrix = obj.groupConfusionMatrix(labelingStrategy);
                obj.plotConfusionMatrix(regroupedConfusionMatrix,labelingStrategy);
            end
        end
        
        function handleNormalizeClicked(obj,~,~)
            obj.normalizeGroupedTables();
        end
        
        function handleExportClicked(obj,~,~)
            if obj.uiHandles.exportTrainDataCheck.Value == 1
                obj.exportTrainData();
            end
            
            if obj.uiHandles.exportTestDataCheck.Value == 1
                obj.exportTestData();
            end
            
            if obj.uiHandles.exportNormalisationValuesDataCheck.Value == 1
                obj.exportNormalisationValues();
            end
        end
    end
    
    methods (Static, Access = private)

        function table = groupTable(table,labelingStrategy)
            if ~isempty(table)
                table.label = labelingStrategy.labelsForClasses(table.label);
            end
        end
        
        function labelStr = labelForTable(table,tableTypeStr,labelingStrategy)
            
            if isempty(table)
                labelStr = sprintf('%s table: empty',tableTypeStr);
            else
                tableHeight = height(table);
                tableWidth = width(table);
                
                labelStr = sprintf('%s table: %dx%d (%s)',tableTypeStr,tableHeight,...
                    tableWidth,labelingStrategy.name);
            end
        end
        
        function newTable = convertTableToExport(table)
            newLabels = table.label - 1;
            newTable = table;
            newTable.label = newLabels;
        end
    end
    
end
