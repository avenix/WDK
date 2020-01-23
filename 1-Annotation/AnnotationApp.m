classdef AnnotationApp < handle
    
    properties (Constant)
        FindPeaksRadius = 50;
        AutoFindPeakRadius = 100;
        SamplingFrequency = 200;
        SegmentHeight = 30;
        AxisToDataRatio = 1.3;
        PlotLineWidth = 2;
        kToolWidth = 64;
        kToolPadding = 35;
        kVideoTimelineLineWidth = 4;
        kTimelineColor = [1,0,0];
        kRangeAnnotationRectangleYPosToDataRatio = 1.03;
        kMaxPlots = 6;
        kLegendFontSize = 14;
    end
    
    properties (Access = private)
        
        %class management
        labeling;
        
        %data loading
        currentFile = 1;
        videoPlayer;
        videoFileNames;
        videoFileNamesNoExtension;
        
        %data
        dataFile;
        preprocessedSignals;
        preprocessingAlgorithms;
        
        %synchronization
        synchronizationFile;
        
        %annotations
        annotationSet;
        eventAnnotationsPlotter;
        rangeAnnotationsPlotter;
        
        %auto annotate
        shouldSuggestAnnotations = false;
        shouldScanUntilTimeline = false;
        autoAnnotateDialog;
        suggestedAnnotationPlotter;
        suggestedClustersPlotter;
        annotationSuggester;
        
        %markers
        markers;
        markerHandles;
        markersPlotter;
        
        %timestamp
        timeLineMarker;
        timeLineMarkerHandle;
        
        %state
        didAnnotationsChange; %indicates whether there were changes to the annotations
        
        %ui
        uiImages;
        preprocessingDialog;
        videoSynchronizationDialog;
        videoFigure;
        plottedSignalYRange;
        state;
        uiHandles;
        plotAxes;
        rangeSelectionAxis = [];
        rangeSelection = [];
        plotHandles;
        
        %ui state
        isSelectingPeaks = 0;
    end
    
    methods (Access = public)
        
        function obj =  AnnotationApp()
            close all;
            
            obj.setupPath();
                        
            obj.state = AnnotationState.kSetTimelineState;
            obj.loadLabeling();
            
            obj.videoFileNames = Helper.ListVideoFiles();
            obj.videoFileNamesNoExtension = Helper.RemoveVideoExtensionForFiles(obj.videoFileNames);
            
            obj.markersPlotter = AnnotationMarkersPlotter();
            
            obj.eventAnnotationsPlotter = AnnotationEventAnnotationsPlotter(obj.labeling);
            obj.eventAnnotationsPlotter.delegate = obj;
            
            obj.rangeAnnotationsPlotter = AnnotationRangeAnnotationsPlotter(obj.labeling);
            obj.rangeAnnotationsPlotter.delegate = obj;
            
            
            obj.suggestedAnnotationPlotter = AnnotationSuggestionPlotter(obj.labeling);
            obj.suggestedAnnotationPlotter.delegate = obj;
            
            clusterLabeling = obj.generateClusterLabeling();
            obj.suggestedClustersPlotter = AnnotationSuggestionPlotter(clusterLabeling);
            obj.suggestedClustersPlotter.delegate = obj;
            
            obj.annotationSuggester = AnnotationsSuggester();
            
            obj.loadUI();
        end
        
        %% annotation plotter delegate
        function handleAnnotationClicked(obj,source,~)
            tag = str2double(source.Tag);
            
            if obj.state == AnnotationState.kDeleteAnnotationState
                
                didDeleteRangeAnnotation = obj.eventAnnotationsPlotter.deleteAnnotationAtSampleIdx(tag);
                didDeleteEventAnnotation = obj.rangeAnnotationsPlotter.deleteAnnotationAtSampleIdx(tag);
                obj.suggestedAnnotationPlotter.deleteAnnotationAtSampleIdx(tag);
                obj.suggestedClustersPlotter.deleteAnnotationAtSampleIdx(tag);
                
                obj.didAnnotationsChange = (didDeleteRangeAnnotation || didDeleteEventAnnotation);
                
            elseif obj.state == AnnotationState.kModifyAnnotationState
                
                currentClass = obj.uiHandles.classesList.Value;
                didModifyRangeAnnotation = obj.eventAnnotationsPlotter.modifyAnnotationToClass(uint32(tag),currentClass);
                didModifyEventAnnotation = obj.rangeAnnotationsPlotter.modifyAnnotationToClass(uint32(tag),currentClass);
                
                obj.confirmSuggestedAnnotationAtSampleIdx(uint32(tag),obj.suggestedAnnotationPlotter);
                obj.modifyAnnotationClusters(uint32(tag));
                
                obj.didAnnotationsChange = (didModifyRangeAnnotation || didModifyEventAnnotation);
            else
                
                obj.confirmSuggestedAnnotationAtSampleIdx(uint32(tag),obj.suggestedAnnotationPlotter);
                obj.confirmSuggestedAnnotationAtSampleIdx(uint32(tag),obj.suggestedClustersPlotter);
                
            end
        end

        %% automatic annotation delegate
        function handleDidChangeSuggestAnnotations(obj,shouldSuggestAnnotations)
            obj.shouldSuggestAnnotations = shouldSuggestAnnotations;
        end
        
        function handleDidChangeScanUntilTimelineMarker(obj,shouldScanUntilTimeline)
            obj.shouldScanUntilTimeline = shouldScanUntilTimeline;
        end
        
        function handleAutoAnnotationDesiredSuggestionsChanged(obj,numSuggestions)
            obj.annotationSuggester.desiredNumberAnnotationSuggestions = numSuggestions;
        end
        
        function handleAnnotationClustersClicked(obj,annotationClusterer)
            annotationClusters = annotationClusterer.clusterAnnotations(obj.dataFile);
            obj.plotAnnotationClusters(annotationClusters);
        end
        
        function handleAutoAnnotationsReseted(obj)
            obj.suggestedAnnotationPlotter.clearAnnotations();
            obj.suggestedClustersPlotter.clearAnnotations();
        end
        
        function handleAutoAnnotateDialogClosed(obj)
            delete(obj.autoAnnotateDialog);
            obj.autoAnnotateDialog = [];
            figure(obj.uiHandles.mainFigure);
        end
        
        %% video player delegate
        function handleVideoPlayerFrameChanged(obj,~,~)
            if obj.getShouldSynchronizeVideo() && ~isempty(obj.synchronizationFile)
                obj.timeLineMarker = obj.synchronizationFile.videoFrameToSample(obj.videoPlayer.currentFrame);
                if ~isempty(obj.timeLineMarkerHandle)
                    obj.updateTimelineMarker();
                end
            end
        end
        
        function handleVideoPlayerWindowClosed(obj,~)
            obj.deleteVideoPlayer();
            
            obj.disableVideoSynchronizationButton();
            figure(obj.uiHandles.mainFigure);%set focus to current figure
        end
        
        %% preprocessing dialog delegate
        function handlePreprocessedSignalsComputed(obj,preprocessingAlgorithms,~)
            obj.preprocessingAlgorithms = preprocessingAlgorithms;
            obj.updateSignalsTable();
        end
        
        function handlePreprocessingDialogClosed(obj,~)
            delete(obj.preprocessingDialog);
            obj.uiHandles.addSignalsButton.enable = 'on';
            obj.preprocessingDialog = [];
            figure(obj.uiHandles.mainFigure);
        end
        
        %% synchronization dialog delegate
        function handleSynchronizationPointAdded(obj,~)
            sample = obj.timeLineMarker;
            frame = obj.videoPlayer.currentFrame;
            obj.videoSynchronizationDialog.addSynchronizationPoint(sample,frame);
        end
        
        function handleSynchronizationDialogClosed(obj,~)
            delete(obj.videoSynchronizationDialog);
            
            obj.videoSynchronizationDialog = [];
            figure(obj.uiHandles.mainFigure);
            
            if ~isempty(obj.videoPlayer)
                obj.videoPlayer.makeForeGround();
            end
        end
        
    end
    
    methods (Access = private)
        
        %% Setup path 
        % checks that the Annotation App is run from the root WDK directory
        % which it adds to Matlab's path
        function setupPath(~)
            fullPath = pwd;
            directories = split(fullPath,'/');
            if(strcmp('1-Annotation',directories{end}))
                cd ..;
            end
            addpath(genpath('./'));
        end
        
        %% Load UI
        function loadUI(obj)
            obj.uiHandles = guihandles(AnnotationUI);
            
            obj.loadPlotAxes();
            obj.loadUIImages();
            obj.setUIImages();
            
            %configure figure
            set(obj.uiHandles.mainFigure,'defaultLegendAutoUpdate','off')
            obj.uiHandles.mainFigure.Visible = false;
            movegui(obj.uiHandles.mainFigure,'center');
            obj.uiHandles.mainFigure.Visible = true;
            
            %callbacks
            obj.uiHandles.fileNamesList.Callback = @obj.handleSelectionChanged;
            obj.uiHandles.loadDataButton.Callback = @obj.handleLoadDataClicked;
            obj.uiHandles.visualizeButton.Callback = @obj.handleVisualizeClicked;
            obj.uiHandles.showMarkersCheckBox.Callback = @obj.handleShowMarkersToggled;
            obj.uiHandles.showEventsCheckBox.Callback = @obj.handleShowEventsToggled;
            obj.uiHandles.showRangesCheckBox.Callback = @obj.handleShowRangesToggled;
            obj.uiHandles.addSignalButton.Callback = @obj.handleAddSignalsClicked;
            obj.uiHandles.autoAnnotateButton.Callback = @obj.handleAutoAnnotateClicked;
            obj.uiHandles.videoSynchronizationButton.Callback = @obj.handleVideoSynchronizationClicked;
            obj.uiHandles.selectAllCheckBox.Callback = @obj.handleSelectAllToggled;
            obj.uiHandles.stateButtonGroup.SelectionChangedFcn = @obj.handleStateChanged;
            obj.uiHandles.saveButton.Callback = @obj.handleSaveClicked;
            obj.uiHandles.resetButton.Callback = @obj.handleResetButtonClicked;
            
            obj.uiHandles.mainFigure.CloseRequestFcn = @obj.handleWindowCloseRequested;
            obj.plotAxes.ButtonDownFcn = @obj.handleFigureClick;
            %obj.uiHandles.mainFigure.KeyPressFcn = @obj.handleKeyPress;
            
            obj.resetUI();
            obj.setUserClickHandle();
            obj.populateFileNamesList();
            obj.populateClassesList();
        end
        
        function loadUIImages(obj)
            fileNames = {{'zoomIn','zoomInSelected'},{'zoomOut','zoomOutSelected'},...
                {'pan','panSelected'},{'setTimeline','setTimelineSelected'},...
                {'addEvent','addEventSelected'},{'addRange','addRangeSelected'},...
                {'modifyAnnotation','modifyAnnotationSelected'}, {'deleteAnnotation','deleteAnnotationSelected'}};
            
            nImages = size(fileNames,2);
            obj.uiImages = cell(nImages,2);
            
            for i = 1 : nImages
                fileName = strcat('resources/',fileNames{i}{1},'.png');
                obj.uiImages{i,1} = imread(fileName);
                fileName = strcat('resources/',fileNames{i}{2},'.png');
                obj.uiImages{i,2} = imread(fileName);
            end
        end
        
        function setUIImages(obj)
            
            uiObjects = {obj.uiHandles.zoomInRadio,obj.uiHandles.zoomOutRadio,...
                obj.uiHandles.panRadio,obj.uiHandles.setTimelineRadio,...
                obj.uiHandles.addEventRadio, obj.uiHandles.addRangeRadio,...
                obj.uiHandles.modifyAnnotationRadio, obj.uiHandles.deleteAnnotationRadio};
            
            obj.layoutTools(uiObjects);
            
            obj.layoutToolLabels(uiObjects);
            obj.enableSetTimelineMode();
        end
        
        function layoutTools(obj,uiObjects)
            nObjects = length(uiObjects);
            
            for i = 1 : nObjects
                object = uiObjects{i};
                object.CData = obj.uiImages{i,1};
                object.Units = 'pixels';
                object.Position(2) = 15;
                object.Position(3) = AnnotationApp.kToolWidth;
                object.Position(4)= AnnotationApp.kToolWidth;
            end
            
            for i = 2 : nObjects
                object = uiObjects{i};
                prevObject = uiObjects{i-1};
                object.Position(1) = prevObject.Position(1) + AnnotationApp.kToolWidth + AnnotationApp.kToolPadding;
            end
        end
        
        function layoutToolLabels(obj,uiObjects)
            uiLabels = {obj.uiHandles.zoomInLabel,obj.uiHandles.zoomOutLabel,...
                obj.uiHandles.panLabel,obj.uiHandles.selectSamplesLabel,...
                obj.uiHandles.addEventLabel, obj.uiHandles.addRangeLabel,...
                obj.uiHandles.modifyAnnotationsLabel, obj.uiHandles.deleteAnnotationsLabel};
            
            nObjects = length(uiObjects);
            
            for i = 1 : nObjects
                object = uiObjects{i};
                label = uiLabels{i};
                label.Position(1) = object.Position(1) - 15;
            end
        end
        
        function resetUI(obj)
            
            obj.uiHandles.setTimelineRadio.Value = true;
            
            obj.uiHandles.loadVideoCheckBox.Value = true;
            
            obj.uiHandles.signalsTable.Data = [];
                        
            obj.uiHandles.currentSampleText.String = '';
            
            obj.disableVideoSynchronizationButton();
            obj.disableAddSignalButton();
            
            obj.uiHandles.loadDataTextbox.String = "";
            obj.uiHandles.showMarkersCheckBox.Value = true;
            obj.uiHandles.showEventsCheckBox.Value = true;
            obj.uiHandles.showRangesCheckBox.Value = true;
            obj.updateSelectingPeaksCheckBox();
        end
        
        function populateFileNamesList(obj)
            extensions = {'*.mat','*.txt'};
            files = Helper.ListDataFiles(extensions);
            if isempty(files)
                fprintf('%s - AnnotationApp',Constants.kNoDataFileFoundWarning);
            else
                obj.uiHandles.fileNamesList.String = files;
            end
        end
        
        %% Loading
        function loadAll(obj)
            obj.loadData();
            if (~isempty(obj.labeling.numClasses) && obj.labeling.numClasses > 0) && ~isempty(obj.dataFile)
                obj.timeLineMarker = 1;
                obj.loadAnnotations();
                obj.loadSynchronizationFile();
                obj.loadMarkers();
                if obj.getShouldLoadVideo()
                    obj.loadVideo();
                end
                obj.uiHandles.addSignalButton.Enable = 'on';
            end
        end
        
        function loadLabeling(obj)
            classesList = DataLoader.LoadLabelsFile();
            obj.labeling = Labeling(classesList);
        end
        
        function loadPlotAxes(obj)
            obj.plotAxes = obj.uiHandles.plotAxes;
            obj.plotAxes.Units = 'characters';
            obj.plotAxes.Visible = 'On';
            obj.plotAxes.Box = 'off';
        end
        
        function setUserClickHandle(obj)
            dataCursorMode = datacursormode(obj.uiHandles.mainFigure);
            dataCursorMode.SnapToDataVertex = 'on';
            dataCursorMode.DisplayStyle = 'window';
            set(dataCursorMode,'UpdateFcn',@obj.handleUserClick);
        end
        
        
        %% Timeline marker
        function plotTimelineMarker(obj)
            if ~isempty(obj.timeLineMarker)
                obj.timeLineMarkerHandle = line(obj.plotAxes,[obj.timeLineMarker, obj.timeLineMarker],...
                    [obj.plotAxes.YLim(1), obj.plotAxes.YLim(2)],...
                    'Color',AnnotationApp.kTimelineColor,'LineWidth',...
                    AnnotationApp.kVideoTimelineLineWidth,'LineStyle','-');
            end
        end
        
        function updateTimelineMarker(obj)
            if ~isempty(obj.timeLineMarkerHandle) && isvalid(obj.timeLineMarkerHandle)
                obj.setCurrentSampleTextToSample(obj.timeLineMarker);
                set(obj.timeLineMarkerHandle,'XData',[obj.timeLineMarker, obj.timeLineMarker]);
                drawnow;
            end
        end
        
        function deleteTimelineMarker(obj)
            obj.timeLineMarker = [];
            delete(obj.timeLineMarkerHandle);
            obj.timeLineMarkerHandle = [];
        end
        
        
        %% UI
        function selectedSignals = getSelectedSignals(obj)
            selectedSignals = cell2mat(obj.uiHandles.signalsTable.Data(:,2));
        end
        
        %% Data
        function loadData(obj)
            fileName = obj.getCurrentFileName();
            if ~isempty(fileName)
                obj.dataFile = DataLoader.LoadDataFile(fileName);
            end
        end
        
        function isDataPlotted = plotData(obj)
            isDataPlotted = false;
            if ~isempty(obj.dataFile)
                hold(obj.plotAxes,'on');
                
                signalsSelected = obj.getSelectedSignals();
                
                %allocate plot handles
                nSignals = sum(signalsSelected);
                
                if nSignals > 0
                    nSignals = min(nSignals,AnnotationApp.kMaxPlots);
                    
                    isDataPlotted = true;
                    obj.plotHandles = gobjects(1,nSignals);
                    
                    nRawSignals = size(obj.dataFile.data,2);
                    
                    signalCount = 0;
                    for i = 1 : length(signalsSelected)
                        if signalsSelected(i)
                            signalCount = signalCount + 1;
                            if i <= nRawSignals
                                obj.plotHandles(signalCount) = plot(obj.plotAxes,...
                                    obj.dataFile.data(:,i),...
                                    'LineWidth', AnnotationApp.PlotLineWidth,...
                                    'Color', Constants.kPlotColors{signalCount});
                            else
                                obj.plotHandles(signalCount) = plot(obj.plotAxes,...
                                    obj.preprocessedSignals{i - nRawSignals},...
                                    'LineWidth', AnnotationApp.PlotLineWidth,...
                                    'Color', Constants.kPlotColors{signalCount});
                            end
                            if signalCount >= AnnotationApp.kMaxPlots
                                break;
                            end
                        end
                    end
                end
            end
        end
        
        function fileName = getCurrentFileName(obj)
            if isempty(obj.uiHandles.fileNamesList.String)
                fileName = [];
            else
                fileName = obj.uiHandles.fileNamesList.String{obj.currentFile};
            end
        end
        
        function fileName = getCurrentFileNameNoExtension(obj)
            dataFileName = obj.getCurrentFileName();
            fileName = Helper.RemoveFileExtension(dataFileName);
        end
        
        function setPlotLegend(obj)
            signalsSelected = obj.getSelectedSignals();
            labels = obj.uiHandles.signalsTable.Data(signalsSelected,1);
            legendHandle = legend(obj.plotHandles,labels,'Location','northeast');
            legendHandle.FontSize = AnnotationApp.kLegendFontSize;
        end
        
        function setPlotAxes(obj)
            nSamples = size(obj.dataFile.data,1);
            axis(obj.plotAxes,[1,nSamples,obj.plottedSignalYRange(1) * AnnotationApp.AxisToDataRatio, obj.plottedSignalYRange(2) * AnnotationApp.AxisToDataRatio]);
        end
        
        function clearAll(obj)
            obj.clearMarkerPlots();
            obj.clearDataPlots();
            obj.eventAnnotationsPlotter.clearAnnotations();
            obj.rangeAnnotationsPlotter.clearAnnotations();
            obj.suggestedAnnotationPlotter.clearAnnotations();
            cla(obj.plotAxes);
            zoom out
            zoom reset
        end
        
        function deleteAll(obj)
            obj.deleteAllMarkers();
            obj.deleteAllAnnotations();
            obj.deleteData();
            obj.deleteRangeSelection();
            if ~isempty(obj.videoPlayer)
                obj.videoPlayer.close();
            end
            obj.deleteTimelineMarker();
        end
        
        function deleteData(obj)
            obj.clearDataPlots();
            obj.dataFile = [];
        end
        
        function clearDataPlots(obj)
            for i = 1 : length(obj.plotHandles)
                plotHandle =  obj.plotHandles(i);
                delete(plotHandle);
            end
            obj.plotHandles = [];
        end
        
        %% Video
        function didLoadVideo = loadVideo(obj)
            didLoadVideo = false;
            
            videoFileName = obj.getVideoFileName();
            
            if ~isempty(videoFileName)
                
                if ~isempty(obj.videoPlayer)
                    obj.videoPlayer.close();
                end
                
                videoPlayerWindowPosition = obj.getVideoPlayerWindowPosition();
                
                obj.videoPlayer = VideoPlayer(videoFileName,obj,videoPlayerWindowPosition);
                obj.updateVideoFrame();
                
                didLoadVideo = true;
            end
        end
        
        function fileName = getVideoFileName(obj)
            fileName = obj.getCurrentFileNameNoExtension();
            
            [~,idx] = ismember(fileName,obj.videoFileNamesNoExtension);
            if idx > 0
                fileName = obj.videoFileNames{idx};
            else
                fileName = [];
            end
        end
        
        function videoPlayerWindowPosition = getVideoPlayerWindowPosition(obj)
            currentWindowPosition = obj.uiHandles.mainFigure.OuterPosition;
            currentHeight = currentWindowPosition(4);
            positionX = currentWindowPosition(1) + currentWindowPosition(3);
            videoPlayerWindowPosition = [positionX, currentWindowPosition(2), currentHeight, currentHeight];
        end
        
        function updateVideoFrame(obj)
            if ~isempty(obj.synchronizationFile) && ~isempty(obj.videoPlayer)
                videoFrame = obj.synchronizationFile.sampleToVideoFrame(obj.timeLineMarker);
                if ~isempty(videoFrame)
                    obj.videoPlayer.displayFrame(videoFrame);
                end
            end
        end
        
        function deleteVideoPlayer(obj)
            delete(obj.videoPlayer);
            obj.videoPlayer = [];
        end
        
        
        %% Events
        function addPeakEventAtLocation(obj,x)
            
            %find peak idex around x
            [~, peakIdx] = max(obj.magnitude(x-obj.FindPeaksRadius:x+obj.FindPeaksRadius));
            peakIdx = int32(peakIdx + x - obj.FindPeaksRadius - 1);
            
            if peakIdx > 0
                obj.addEventAtLocation(peakIdx);
            end
        end
        
        function addEventAtLocation(obj,x)
            currentClass = obj.getSelectedClass();
            obj.eventAnnotationsPlotter.addAnnotation(obj.plotAxes,x,currentClass);
        end
        
        %% Ranges
        function selectRangeAtLocation(obj,x)
            
            if isempty(obj.rangeSelection)
                obj.rangeSelection = AnnotationSampleRange(x);
            else
                obj.rangeSelection.addValue(x);
                obj.addCurrentRange();
            end
            
            obj.updateRangeSelection();
        end
        
        function cancelCurrentRangeSelection(obj)
            if ~isempty(obj.rangeSelection) && obj.rangeSelection.isValidRange()
                obj.deleteRangeSelection();
            end
        end
        
        function deleteRangeSelection(obj)
            obj.rangeSelection = [];
        end
        
        function addCurrentRange(obj)
            if ~isempty(obj.rangeSelection) && obj.rangeSelection.isValidRange()
                label = obj.getSelectedClass();
                rangeAnnotation = RangeAnnotation(obj.rangeSelection.sample1,...
                    obj.rangeSelection.sample2,label);
                obj.rangeAnnotationsPlotter.addAnnotation(obj.plotAxes, rangeAnnotation);
                
                if obj.getSuggestAnnotations()
                    suggestedAnnotations = obj.generateAnnotationSuggestionsWithRange(rangeAnnotation);
                    %remove
                    if ~isempty(suggestedAnnotations)
                        obj.suggestedAnnotationPlotter.addAnnotations(obj.plotAxes,suggestedAnnotations);
                    end
                end
            end
        end
        
        
        %% UI
        function b = getSuggestAnnotations(obj)
            b = obj.shouldSuggestAnnotations;
        end
        
        function updateLoadDataTextbox(obj,~,~)
            obj.uiHandles.loadDataTextbox.String = sprintf('data size:\n %d x %d',obj.dataFile.numRows,obj.dataFile.numColumns);
        end
        
        function populateClassesList(obj)
            classes = obj.labeling.classNames;
            classes{end+1} = Labeling.kIgnoreStr;
            obj.uiHandles.classesList.String = classes;
        end
        
        function updateFileName(obj)
            obj.currentFile = obj.uiHandles.fileNamesList.Value;
        end
        
        %% Markers
        function loadMarkers(obj)
            if ~isempty(obj.synchronizationFile) && ~isempty(obj.annotationSet)
                markersFileName = obj.getMarkersFileName();
                obj.markers = DataLoader.LoadMarkers(markersFileName);
                
                if ~isempty(obj.markers)
                    
                    for i = 1 : length(obj.markers)
                        currentMarker = obj.markers(i);
                        currentMarker.sample = obj.synchronizationFile.videoFrameToSample(currentMarker.sample);
                        obj.markers(i) = currentMarker;
                    end
                end
            end
        end
        
        function plotMarkers(obj)
            if ~isempty(obj.markers)
                obj.markersPlotter.markerYRange = obj.plottedSignalYRange;
                obj.markersPlotter.plotMarkers(obj.markers,obj.plotAxes);
            end
        end
        
        function fileName = getMarkersFileName(obj)
            fileName = obj.getCurrentFileNameNoExtension();
            fileName = Helper.AddMarkersFileExtension(fileName);
        end
        
        function deleteAllMarkers(obj)
            obj.clearMarkerPlots();
            obj.markers = [];
        end
        
        function clearMarkerPlots(obj)
            obj.markersPlotter.deleteMarkers();
        end
        
        %% Annotations
        function loadAnnotations(obj)
            fileName = obj.getAnnotationsFileName();
            obj.annotationSet = DataLoader.LoadAnnotationSet(fileName,obj.labeling);
        end
        
        function annotationsFileName = getAnnotationsFileName(obj)
            fileName = obj.getCurrentFileNameNoExtension();
            annotationsFileName = Helper.AddAnnotationsFileExtension(fileName);
        end
        
        function plotAnnotations(obj)
            obj.eventAnnotationsPlotter.verticalLineYRange = obj.plottedSignalYRange;
            
            obj.rangeAnnotationsPlotter.rectanglesYRange = ...
                obj.plottedSignalYRange * AnnotationApp.kRangeAnnotationRectangleYPosToDataRatio;
            
            obj.suggestedAnnotationPlotter.rectanglesYRange = ...
                obj.plottedSignalYRange * AnnotationApp.kRangeAnnotationRectangleYPosToDataRatio;
            
            obj.suggestedClustersPlotter.rectanglesYRange = ...
                obj.plottedSignalYRange * AnnotationApp.kRangeAnnotationRectangleYPosToDataRatio;
            
            if ~isempty(obj.annotationSet)
                obj.eventAnnotationsPlotter.addAnnotations(obj.plotAxes,obj.annotationSet.eventAnnotations);
                obj.rangeAnnotationsPlotter.addAnnotations(obj.plotAxes,obj.annotationSet.rangeAnnotations);
            end
        end
        
        function saveAnnotations(obj)
            eventAnnotations = obj.eventAnnotationsPlotter.getAnnotations();
            rangeAnnotations = obj.rangeAnnotationsPlotter.getAnnotations();
            annotations = AnnotationSet(eventAnnotations,rangeAnnotations);
            if ~isempty(eventAnnotations) || ~isempty(rangeAnnotations)
                fileName = obj.getAnnotationsFileName();
                DataLoader.SaveAnnotations(annotations,fileName,obj.labeling);
            end
            obj.didAnnotationsChange = false;
        end
        
        function deleteAllAnnotations(obj)
            obj.eventAnnotationsPlotter.clearAnnotations();
            obj.rangeAnnotationsPlotter.clearAnnotations();
            obj.suggestedAnnotationPlotter.clearAnnotations();
            obj.suggestedClustersPlotter.clearAnnotations();
            obj.annotationSet = [];
        end
        
        %% Automatic Annotations
        function suggestedAnnotations = generateAnnotationSuggestionsWithRange(obj,rangeAnnotation)
            if(obj.shouldScanUntilTimeline)
                obj.annotationSuggester.suggestionSearchEndSample = obj.timeLineMarker;
            else
                obj.annotationSuggester.suggestionSearchEndSample = -1;
            end
            
            suggestedAnnotations = obj.annotationSuggester.suggestAnnotationsWithRange(rangeAnnotation,obj.dataFile);
        end
                
        function plotAnnotationClusters(obj,annotationClusters)
            obj.suggestedClustersPlotter.clearAnnotations();
            obj.suggestedClustersPlotter.addAnnotations(obj.plotAxes,annotationClusters);
        end
        
        function modifyAnnotationClusters(obj,tag)
            currentLabel = obj.getSelectedClass();
            
            annotation = obj.suggestedClustersPlotter.getAnnotationWithKey(tag);
            
            if ~isempty(annotation)
                label = annotation.label;
                annotations = obj.suggestedClustersPlotter.getAnnotationsWithLabel(label);
                
                for i = 1 : length(annotations)
                    annotation = annotations(i);
                    obj.suggestedClustersPlotter.deleteAnnotationAtSampleIdx(annotation.startSample);
                    annotation.label = currentLabel;
                end
                
                obj.rangeAnnotationsPlotter.addAnnotations(obj.plotAxes,annotations);
                
                if ~obj.uiHandles.showRangesCheckBox.Value
                    obj.uiHandles.showRangesCheckBox.Value = true;
                    obj.handleShowRangesToggled();
                end
            end
        end
                
        function confirmSuggestedAnnotationAtSampleIdx(obj,tag,plotter)
            %get the annotation
            suggestedAnnotation = plotter.getAnnotationWithKey(tag);
            
            if ~isempty(suggestedAnnotation)
                %delete it from suggested plotter
                plotter.deleteAnnotationAtSampleIdx(tag);
                
                %add it to real annotations
                obj.rangeAnnotationsPlotter.addAnnotation(obj.plotAxes, suggestedAnnotation);
            end
        end
        
        function clusterLabeling = generateClusterLabeling(obj)
            clusterLabels = cell(1,obj.labeling.numClasses);
            for i = 1 : obj.labeling.numClasses
                clusterLabels{i} = sprintf('cluster-%d',i);
            end
            
            clusterLabeling = Labeling(clusterLabels);
        end
        
        %% Synchronization files
        function loadSynchronizationFile(obj)
            fileName = obj.getSynchronizationFileName();
            obj.synchronizationFile = DataLoader.LoadSynchronizationFile(fileName);
            if isempty(obj.synchronizationFile)
                obj.synchronizationFile = SynchronizationFile();
            end
        end
        
        function fileName = getSynchronizationFileName(obj)
            fileName = obj.getCurrentFileNameNoExtension();
            fileName = Helper.AddSynchronizationFileExtension(fileName);
        end
        
        %% Methods
        function computePlottedSignalYRanges(obj)
            nPlots = length(obj.plotHandles);
            
            totalMaxY = -inf;
            totalMinY = inf;
            
            for i = 1 : nPlots
                plotHandle = obj.plotHandles(i);
                maxY = max(plotHandle.YData);
                minY = min(plotHandle.YData);
                totalMaxY = max(totalMaxY,maxY);
                totalMinY = min(totalMinY,minY);
            end
            
            obj.plottedSignalYRange(1) = totalMinY;
            obj.plottedSignalYRange(2) = totalMaxY;
        end
        
        function computePreprocessedSignals(obj)
            
            nSignals = length(obj.preprocessingAlgorithms);
            
            obj.preprocessedSignals = cell(1,nSignals);
            
            for i = 1 : nSignals
                preprocessingAlgorithm = obj.preprocessingAlgorithms{i};
                preprocessedSignal = preprocessingAlgorithm.compute(obj.dataFile.data);
                obj.preprocessedSignals{i} = preprocessedSignal;
            end
        end
        
        function closeWindow(obj)
            
            if ~isempty(obj.videoPlayer)
                obj.videoPlayer.close();
                obj.deleteVideoPlayer();
            end
            
            if ~isempty(obj.preprocessingDialog)
                delete(obj.preprocessingDialog);
            end
            
            if ~isempty(obj.videoSynchronizationDialog)
                delete(obj.videoSynchronizationDialog);
            end
            
            if ~isempty(obj.autoAnnotateDialog)
                delete(obj.autoAnnotateDialog);
            end
            
            delete(obj.uiHandles.mainFigure);
        end
        
        %% UI
        function enableZoomInMode(obj)
            zoomModeHandle = zoom(obj.uiHandles.mainFigure);
            zoomModeHandle.Enable = 'on';
            zoomModeHandle.Direction = 'in';
            obj.uiHandles.zoomInRadio.CData = obj.uiImages{AnnotationState.kZoomInState,2};
        end
        
        function disableZoomInMode(obj)
            zoomModeHandle = zoom(obj.uiHandles.mainFigure);
            zoomModeHandle.Enable = 'off';
            obj.uiHandles.zoomInRadio.CData = obj.uiImages{AnnotationState.kZoomInState,1};
        end
        
        function enableZoomOutMode(obj)
            zoomModeHandle = zoom(obj.uiHandles.mainFigure);
            zoomModeHandle.Enable = 'on';
            zoomModeHandle.Direction = 'out';
            obj.uiHandles.zoomOutRadio.CData = obj.uiImages{AnnotationState.kZoomOutState,2};
        end
        
        function disableZoomOutMode(obj)
            zoomModeHandle = zoom(obj.uiHandles.mainFigure);
            zoomModeHandle.Enable = 'off';
            obj.uiHandles.zoomOutRadio.CData = obj.uiImages{AnnotationState.kZoomOutState,1};
        end
        
        function enablePanMode(obj)
            panModeHandle = pan(obj.uiHandles.mainFigure);
            panModeHandle.Enable = 'on';
            obj.uiHandles.panRadio.CData = obj.uiImages{AnnotationState.kPanState,2};
        end
        
        function disablePanMode(obj)
            panModeHandle = pan(obj.uiHandles.mainFigure);
            panModeHandle.Enable = 'off';
            obj.uiHandles.panRadio.CData = obj.uiImages{AnnotationState.kPanState,1};
        end
        
        function enableSetTimelineMode(obj)
            obj.uiHandles.setTimelineRadio.CData = obj.uiImages{AnnotationState.kSetTimelineState,2};
        end
        
        function disableSetTimelineMode(obj)
            obj.uiHandles.setTimelineRadio.CData = obj.uiImages{AnnotationState.kSetTimelineState,1};
        end
        
        function enableAddEventMode(obj)
            cursorModeHandle = datacursormode(obj.uiHandles.mainFigure);
            cursorModeHandle.Enable = 'on';
            obj.uiHandles.addEventRadio.CData = obj.uiImages{AnnotationState.kAddEventState,2};
            
            obj.uiHandles.showEventsCheckBox.Value = true;
            obj.handleShowEventsToggled();
        end
        
        function disableAddEventMode(obj)
            cursorModeHandle = datacursormode(obj.uiHandles.mainFigure);
            cursorModeHandle.Enable = 'off';
            obj.uiHandles.addEventRadio.CData = obj.uiImages{AnnotationState.kAddEventState,1};
        end
        
        function enableAddRangeState(obj)
            cursorModeHandle = datacursormode(obj.uiHandles.mainFigure);
            cursorModeHandle.Enable = 'on';
            obj.uiHandles.addRangeRadio.CData = obj.uiImages{AnnotationState.kAddRangeState,2};
            
            obj.uiHandles.showRangesCheckBox.Value = true;
            obj.handleShowRangesToggled();
            obj.deleteRangeSelection();
        end
        
        function disableAddRangeState(obj)
            cursorModeHandle = datacursormode(obj.uiHandles.mainFigure);
            cursorModeHandle.Enable = 'off';
            obj.uiHandles.addRangeRadio.CData = obj.uiImages{AnnotationState.kAddRangeState,1};
        end
        
        function enableModifyAnnotationState(obj)
            cursorModeHandle = datacursormode(obj.uiHandles.mainFigure);
            cursorModeHandle.Enable = 'off';
            obj.uiHandles.modifyAnnotationRadio.CData = obj.uiImages{AnnotationState.kModifyAnnotationState,2};
        end
        
        function disableModifyAnnotationState(obj)
            obj.uiHandles.modifyAnnotationRadio.CData = obj.uiImages{AnnotationState.kModifyAnnotationState,1};
        end
        
        function enableDeleteAnnotationState(obj)
            cursorModeHandle = datacursormode(obj.uiHandles.mainFigure);
            cursorModeHandle.Enable = 'off';
            obj.uiHandles.deleteAnnotationRadio.CData = obj.uiImages{AnnotationState.kDeleteAnnotationState,2};
        end
        
        function disableDeleteAnnotationState(obj)
            obj.uiHandles.deleteAnnotationRadio.CData = obj.uiImages{AnnotationState.kDeleteAnnotationState,1};
        end
        
        function disableAddSignalButton(obj)
            obj.uiHandles.addSignalButton.Enable = 'off';
        end
        
        function enableAddSignalButton(obj)
            obj.uiHandles.addSignalButton.Enable = 'on';
        end
        
        function setCurrentSampleTextToSample(obj,sample)
            obj.uiHandles.currentSampleText.String = sprintf('%16.f',sample);
        end
                
        function b = getShouldSynchronizeVideo(obj)
            b = isempty(obj.videoSynchronizationDialog);
        end
        
        function b = getShouldLoadVideo(obj)
            b = obj.uiHandles.loadVideoCheckBox.Value;
        end
        
        function class = getSelectedClass(obj)
            class = int8(obj.uiHandles.classesList.Value);
            if (class == length(obj.uiHandles.classesList.String))
                class = Labeling.kIgnoreClass;
            end
        end
        
        function updateSelectingPeaksCheckBox(obj)
            obj.uiHandles.peaksCheckBox.Value = obj.isSelectingPeaks;
        end
        
        function shouldSelectPeaks = getShouldSelectPeaks(obj)
            shouldSelectPeaks = obj.uiHandles.peaksCheckBox.Value;
        end
        
        function updateSignalsTable(obj)
            
            nRawSignals = size(obj.dataFile.data,2);
            nPreprocessingAlgorithms = size(obj.preprocessingAlgorithms,2);
            nTotalSignals = nRawSignals + nPreprocessingAlgorithms;
            
            tableData = cell(nTotalSignals,2);
            
            %fill in raw signal names
            tableData(1:nRawSignals,1) = obj.dataFile.columnNames;
            
            %fill in preprocessed signal names
            tableData(nRawSignals+1:end,1) = Helper.AlgorithmsToStringsArray(obj.preprocessingAlgorithms);
            
            %fill in second column
            tableData(:,2) = num2cell(false(nTotalSignals,1));
            
            obj.uiHandles.signalsTable.Data = tableData;
        end
        
        function enableVideoSynchronizationButton(obj)
            obj.uiHandles.videoSynchronizationButton.Enable = 'on';
        end
        
        function disableVideoSynchronizationButton(obj)
            obj.uiHandles.videoSynchronizationButton.Enable = 'off';
        end
        
        
        %% UI Handles
        function outputTxt = handleUserClick(obj,src,~)
            
            pos = get(src,'Position');
            x = pos(1);
            y = pos(2);
            xStr = num2str(x,7);
            yStr = num2str(y,7);
            outputTxt = {['X: ',xStr],['Y: ',yStr]};
            
            fprintf('%d\n',x);
            
            if obj.state == AnnotationState.kAddEventState
                if obj.isSelectingPeaks
                    obj.addPeakEventAtLocation(x);
                else
                    obj.addEventAtLocation(x);
                end
            elseif obj.state == AnnotationState.kSetTimelineState
                obj.timeLineMarker = x;
                obj.updateTimelineMarker();
                if obj.getShouldSynchronizeVideo()
                    obj.updateVideoFrame();
                end
            elseif obj.state == AnnotationState.kAddRangeState
                obj.selectRangeAtLocation(x);
            end
        end
        
        function handleLoadDataClicked(obj,~,~)
            
            obj.deleteAll();
            obj.loadAll();
            
            if ~isempty(obj.dataFile)
                obj.updateLoadDataTextbox();
                obj.updateSignalsTable();
            end
        end
        
        function handleVisualizeClicked(obj,~,~)
            if ~isempty(obj.dataFile)
                obj.clearAll();
                obj.computePreprocessedSignals();
                dataPlotted = obj.plotData();
                
                if dataPlotted
                    obj.computePlottedSignalYRanges();
                    obj.setPlotAxes();
                    obj.plotAnnotations();
                    obj.plotMarkers();
                    obj.plotTimelineMarker();
                    obj.setPlotLegend();
                    
                    if ~isempty(obj.timeLineMarkerHandle)
                        obj.enableVideoSynchronizationButton();
                    end
                end
                
            end
        end
        
        function handleStateChanged(obj,~,~)
            
            obj.disableCurrentState();
            
            switch obj.uiHandles.stateButtonGroup.SelectedObject
                case (obj.uiHandles.zoomInRadio)
                    obj.state = AnnotationState.kZoomInState;
                    obj.enableZoomInMode();
                case (obj.uiHandles.zoomOutRadio)
                    obj.state = AnnotationState.kZoomOutState;
                    obj.enableZoomOutMode();
                case (obj.uiHandles.panRadio)
                    obj.state = AnnotationState.kPanState;
                    obj.enablePanMode();
                case (obj.uiHandles.setTimelineRadio)
                    obj.state = AnnotationState.kSetTimelineState;
                    obj.enableSetTimelineMode();
                case (obj.uiHandles.addEventRadio)
                    obj.state = AnnotationState.kAddEventState;
                    obj.enableAddEventMode();
                case (obj.uiHandles.addRangeRadio)
                    obj.state = AnnotationState.kAddRangeState;
                    obj.enableAddRangeState();
                case (obj.uiHandles.modifyAnnotationRadio)
                    obj.state = AnnotationState.kModifyAnnotationState;
                    obj.enableModifyAnnotationState();
                case (obj.uiHandles.deleteAnnotationRadio)
                    obj.state = AnnotationState.kDeleteAnnotationState;
                    obj.enableDeleteAnnotationState();
            end
        end
        
        function disableCurrentState(obj)
            switch obj.state
                case (AnnotationState.kZoomInState)
                    obj.disableZoomInMode();
                case (AnnotationState.kZoomOutState)
                    obj.disableZoomOutMode();
                case (AnnotationState.kPanState)
                    obj.disablePanMode();
                case (AnnotationState.kSetTimelineState)
                    obj.disableSetTimelineMode();
                case (AnnotationState.kAddEventState)
                    obj.disableAddEventMode();
                case (AnnotationState.kAddRangeState)
                    obj.disableAddRangeState();
                case (AnnotationState.kModifyAnnotationState)
                    obj.disableModifyAnnotationState();
                case (AnnotationState.kDeleteAnnotationState)
                    obj.disableDeleteAnnotationState();
            end
        end
        
        function handleSelectingPeaksSelected(obj,~,~)
            obj.isSelectingPeaks = obj.getShouldSelectPeaks();
        end
                
        function handleSaveClicked(obj,~,~)
            obj.saveAnnotations();
        end
        
        function handleShowMarkersToggled(obj,~,~)
            obj.markersPlotter.shouldShowMarkers = obj.uiHandles.showMarkersCheckBox.Value;
        end
        
        function handleShowEventsToggled(obj,~,~)
            obj.eventAnnotationsPlotter.shouldShowAnnotations = obj.uiHandles.showEventsCheckBox.Value;
        end
        
        function handleShowRangesToggled(obj,~,~)
            obj.rangeAnnotationsPlotter.shouldShowAnnotations = obj.uiHandles.showRangesCheckBox.Value;
        end
        
        function handleSelectionChanged(obj,~,~)
            obj.updateFileName();
        end
        
        function handleAddSignalsClicked(obj,~,~)
            
            if isempty(obj.preprocessingDialog)
                obj.preprocessingDialog = PreprocessingDialog(obj.dataFile,obj);
                
                positionX = obj.uiHandles.mainFigure.Position(1) + obj.uiHandles.addSignalButton.Position(1);
                positionY = obj.uiHandles.mainFigure.Position(2) + obj.uiHandles.addSignalButton.Position(2);
                obj.preprocessingDialog.Figure.Position(1) = positionX;
                obj.preprocessingDialog.Figure.Position(2) = positionY;
            else
                figure(obj.preprocessingDialog.Figure)
            end
        end
        
        function handleAutoAnnotateClicked(obj,~,~)
            if isempty(obj.autoAnnotateDialog)
                obj.autoAnnotateDialog = AutoAnnotateDialog(obj.labeling.numClasses,obj);
                obj.autoAnnotateDialog.setShouldSuggestAnnotations(obj.shouldSuggestAnnotations);
                                
                positionX = obj.uiHandles.mainFigure.Position(1) + obj.uiHandles.autoAnnotateButton.Position(1);
                positionY = obj.uiHandles.mainFigure.Position(2) + obj.uiHandles.autoAnnotateButton.Position(2);
                obj.autoAnnotateDialog.Figure.Position(1) = positionX;
                obj.autoAnnotateDialog.Figure.Position(2) = positionY;
            else
                figure(obj.autoAnnotateDialog.Figure);
            end
        end
        
        function handleVideoSynchronizationClicked(obj,~,~)
            
            if isempty(obj.videoSynchronizationDialog)
                obj.videoSynchronizationDialog = SynchronizationDialog(obj,obj.synchronizationFile);
                
                obj.videoSynchronizationDialog.setSynchronizationFile(obj.synchronizationFile);
                
                positionX = obj.uiHandles.mainFigure.Position(1) + obj.uiHandles.videoSynchronizationButton.Position(1);
                positionY = obj.uiHandles.mainFigure.Position(2) + obj.uiHandles.videoSynchronizationButton.Position(2);
                obj.videoSynchronizationDialog.Figure.Position(1) = positionX;
                obj.videoSynchronizationDialog.Figure.Position(2) = positionY;
            else
                figure(obj.videoSynchronizationDialog.Figure);
            end
        end
        
        function handleResetButtonClicked(obj,~,~)
            obj.deleteAllAnnotations();
        end
        
        function handleSelectAllToggled(obj,~,~)
            selectAllChecked = obj.uiHandles.selectAllCheckBox.Value;
            nSignals = size(obj.uiHandles.signalsTable.Data,1);
            if selectAllChecked
                obj.uiHandles.signalsTable.Data(:,2) = num2cell(true(nSignals,1));
            else
                obj.uiHandles.signalsTable.Data(:,2) = num2cell(false(nSignals,1));
            end
        end
        
        function handleFigureClick(obj,~,event)
            if obj.state == AnnotationState.kSetTimelineState
                x = event.IntersectionPoint(1);
                obj.timeLineMarker = x;
                obj.updateTimelineMarker();
                if obj.getShouldSynchronizeVideo()
                    obj.updateVideoFrame();
                end
            end
        end
        
        function handleWindowCloseRequested(obj,~,~)
            
            shouldClose = true;
            if obj.didAnnotationsChange
                
                shouldClose = false;
                answer = questdlg('Do you want to save the annotations?', ...
                    'Save Annotations', ...
                    'Save','Discard','Cancel','Cancel');
                
                switch answer
                    case 'Save'
                        obj.saveAnnotations();
                        shouldClose = true;
                    case 'Discard'
                        shouldClose = true;
                end
            end
            
            if shouldClose
                obj.closeWindow();
            end
        end
        
    end
end
