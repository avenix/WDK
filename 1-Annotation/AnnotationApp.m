classdef AnnotationApp < handle
    
    properties (Constant)
        FindPeaksRadius = 50;
        AutoFindPeakRadius = 100;
        SamplingFrequency = 200;
        SegmentHeight = 30;
    end
    
    properties (Access = private)
        
        %class management
        classesMap;
        
        %data loading
        currentFile = 1;
        dataLoader;
        videoPlayer AnnotationVideoPlayer;
        videoFileNames;
        videoFileNamesNoExtension;
        
        %data
        data;
        magnitude;
        columnNames;
        
        %synchronisation
        synchronisationFile;
        
        %signal computers
        preprocessingConfigurator;
                
        %annotations
        annotationSet;
        eventAnnotationsPlotter;
        rangeAnnotationsPlotter;

        %markers
        markers;
        markerHandles;
        markersPlotter AnnotationMarkersPlotter;
        
        %ui
        timestampMarker;
        videoFigure;
        plottedSignalYRange;
        state AnnotationState = AnnotationState.kSelectMode;    
        uiHandles;
        plotAxes;
        rangeSelectionAxis = [];
        rangeSelection = [];
        plotHandles;
        currentTimeLine;
        currentTimeLineHandle;
        
        %ui state
        isSelectingPeaks = 0;
    end
    
    methods (Access = public)
        
        function obj =  AnnotationApp()
            clear ClassesMap;
            obj.classesMap = ClassesMap.instance();
            obj.dataLoader = DataLoader();
            obj.videoFileNames = Helper.listVideoFiles();
            obj.videoFileNamesNoExtension = Helper.removeVideoExtensionForFiles(obj.videoFileNames);
            
            obj.markersPlotter = AnnotationMarkersPlotter();
            
            obj.eventAnnotationsPlotter = AnnotationEventAnnotationsPlotter(obj.classesMap);
            obj.eventAnnotationsPlotter.delegate = obj;
            
            obj.rangeAnnotationsPlotter = AnnotationRangeAnnotationsPlotter(obj.classesMap);
            obj.rangeAnnotationsPlotter.delegate = obj;
            
            obj.loadUI();
            obj.createCurrentTimeLine();
        end
             
        function handleAnnotationClicked(obj,source,~)
            tag = str2double(source.Tag);
            if obj.state == AnnotationState.kDeleteMode
                obj.eventAnnotationsPlotter.deleteAnnotationAtSampleIdx(tag);
                obj.rangeAnnotationsPlotter.deleteAnnotationAtSampleIdx(tag);
            elseif obj.state == AnnotationState.kModifyMode
                currentClass = obj.uiHandles.classesList.Value;
                obj.eventAnnotationsPlotter.modifyAnnotationToClass(uint32(tag),currentClass);
                obj.rangeAnnotationsPlotter.modifyAnnotationToClass(uint32(tag),currentClass);
            end
        end
    end
    
    methods (Access = private)

        %% methods
        function loadUI(obj)
            obj.uiHandles = guihandles(AnnotationUI);
            
            obj.uiHandles.fileNamesList.Callback = @obj.handleSelectionChanged;
            obj.uiHandles.loadDataButton.Callback = @obj.handleLoadDataClicked;
            obj.uiHandles.visualizeButton.Callback = @obj.handleVisualizeClicked;
            obj.uiHandles.showMarkersCheckBox.Callback = @obj.handleShowMarkersToggled;
            obj.uiHandles.showEventsCheckBox.Callback = @obj.handleShowEventsToggled;
            obj.uiHandles.showRangesCheckBox.Callback = @obj.handleShowRangesToggled;
            
            obj.uiHandles.stateButtonGroup.SelectionChangedFcn = @obj.handleStateChanged;
            obj.uiHandles.findButton.Callback = @obj.handleFindPeaksClicked;
            obj.uiHandles.saveButton.Callback = @obj.handleSaveClicked;
            obj.uiHandles.addRangeAnnotationButton.Callback = @obj.handleAddRangeClicked;
            obj.uiHandles.peaksCheckBox.Callback = @obj.handleSelectingPeaksSelected;

            obj.resetUI();
            obj.loadPlotAxes();
            obj.setUserClickHandle();
            obj.populateFileNamesList();
            obj.populateClassesList();
            
            signalComputers = Palette.PreprocessingComputers();
            obj.preprocessingConfigurator = PreprocessingConfiguratorAnnotationApp(...
                signalComputers,...
                obj.uiHandles.signalsList,...
                obj.uiHandles.signalComputerList,...
                obj.uiHandles.signalComputerVariablesTable);
        end
        
        function resetUI(obj)
            obj.uiHandles.loadDataTextbox.String = "";
            obj.uiHandles.showMarkersCheckBox.Value = true;
            obj.uiHandles.showEventsCheckBox.Value = true;
            obj.uiHandles.showRangesCheckBox.Value = true;
            obj.updateSelectingPeaksCheckBox();
        end
        
        function loadAll(obj)
             obj.loadData();
            if obj.classesMap.numClasses > 0 && ~isempty(obj.data)
                obj.loadAnnotations();
                obj.loadSynchronisationFile();
                obj.loadMarkers();
            end
        end
        
        function populateFileNamesList(obj)
            extensions = {'*.mat','*.txt'};
            files = Helper.listDataFiles(extensions);
            if isempty(files)
                fprintf('%s - AnnotationApp',Constants.kNoDataFileFoundWarning);
            else
                obj.uiHandles.fileNamesList.String = files;
            end
        end
        
        function loadPlotAxes(obj)
            obj.plotAxes = axes(obj.uiHandles.mainFigure);
            obj.plotAxes.Units = 'characters';
            obj.plotAxes.Position  = [35 4 270 57];
            obj.plotAxes.Visible = 'On';
        end
        
        function setUserClickHandle(obj)
            
            dataCursorMode = datacursormode(obj.uiHandles.mainFigure);
            dataCursorMode.SnapToDataVertex = 'on';
            dataCursorMode.DisplayStyle = 'window';
            dataCursorMode.Enable = 'on';
            set(dataCursorMode,'UpdateFcn',@obj.handleUserClick);
        end
        
        function createCurrentTimeLine(obj)
            %{
            obj.currentTimeLineHandle = line(obj.plotAxes,[marker.sample, marker.sample],...
                    [obj.markerYRange(1) obj.markerYRange(2)],...
                    'Color',color{1},'LineWidth',lineWidth,...
                    'LineStyle','-');
            %}
        end
        
        function loadData(obj)
            fileName = obj.getCurrentFileName();
            if ~isempty(fileName)
                [obj.data, obj.columnNames] = obj.dataLoader.loadData(fileName);
            end
        end
        
        function loadMarkers(obj)
            if ~isempty(obj.annotationSet)
                markersFileName = obj.getMarkersFileName();
                obj.markers = obj.dataLoader.loadMarkers(markersFileName);
                
                if ~isempty(obj.markers)                    
                    x1 = obj.findFirstSynchronisationMarker();
                    x2 = obj.findLastSynchronisationMarker();
                    
                    y1 = obj.findFirstSynchronisationSample();
                    y2 = obj.findLastSynchronisationSample();
                    
                    a = double(y2-y1) / double(x2-x1);
                    
                    for i = 1 : length(obj.markers)
                        currentMarker = obj.markers(i);
                        currentMarker.sample = a * (currentMarker.sample - x1) + y1;
                        obj.markers(i) = currentMarker;
                    end
                end
            end
        end
        
        function videoFrame = sampleToVideoFrame(obj, x)
            
            x1 = double(obj.findFirstSynchronisationSample());%data
            x2 = double(obj.findLastSynchronisationSample());
            
            y1 = obj.synchronisationFile.startFrame;
            y2 = obj.synchronisationFile.endFrame;
            
            a = (y2-y1) / (x2-x1);
            videoFrame = a * (x - x1) + y1;
            if videoFrame < 1
                videoFrame = 1;
            end
        end
        
        function plotData(obj)
            if ~isempty(obj.data)
                hold(obj.plotAxes,'on');
                
                selectedSignals = obj.preprocessingConfigurator.getSelectedSignalIdxs();
                nSignals = length(selectedSignals);
                obj.plotHandles = cell(1,nSignals+1);
                
                for i = 1 : nSignals
                    signalIdx = selectedSignals(i);
                    obj.plotHandles{i} = plot(obj.plotAxes,obj.data(:,signalIdx));
                end
                obj.plotHandles{nSignals+1} = plot(obj.plotAxes,obj.magnitude);
                
                n = size(obj.magnitude,1);
                axis(obj.plotAxes,[1,n,obj.plottedSignalYRange(1) * 1.1,obj.plottedSignalYRange(2) * 1.1]);
            end
        end
        
        function clearAll(obj)
            obj.clearMarkerPlots();
            obj.clearDataPlots();
            obj.eventAnnotationsPlotter.clearAnnotations();
            obj.rangeAnnotationsPlotter.clearAnnotations();
            cla(obj.plotAxes);
        end
        
        function deleteAll(obj)
            obj.deleteAllMarkers();
            obj.deleteAllAnnotations();
            obj.deleteData();
            obj.deleteRangeSelection();
        end
        
        function deleteData(obj)
            obj.clearDataPlots();
            obj.magnitude = [];
            obj.data = [];
        end
        
        function clearDataPlots(obj)
            for i = 1 : length(obj.plotHandles)
                plotHandle =  obj.plotHandles{i};
                delete(plotHandle);
            end
            obj.plotHandles = [];
        end
        
        function plotMarkers(obj)
            if ~isempty(obj.markers)
                obj.markersPlotter.markerYRange = obj.plottedSignalYRange;
                obj.markersPlotter.plotMarkers(obj.markers,obj.plotAxes);
            end
        end
        
        function plotVideo(obj)
            
            videoFileName = obj.getVideoFileName();
            
            if ~isempty(videoFileName)
                if isempty(obj.videoFigure) || ~isvalid(obj.videoFigure)
                    videoTitle = sprintf('Reference Video: %s',videoFileName);
                    obj.videoFigure = figure('NumberTitle', 'off', 'Name', videoTitle);
                    obj.videoFigure.CurrentAxes = axes();
                    set(obj.videoFigure,'KeyPressFcn',@obj.handleKeyPressed);
                end
                obj.videoPlayer = AnnotationVideoPlayer(videoFileName,obj.videoFigure.CurrentAxes);
                obj.videoPlayer.displayFrame(1);
            end
        end
        
        function selectSampleAtLocation(obj, x)
            
            if ~isempty(obj.videoPlayer)
                videoFrame = obj.sampleToVideoFrame(x);
                obj.videoPlayer.displayFrame(videoFrame);
            end
        end
        
        function selectRangeAtLocation(obj,x)
            
            if ~isempty(obj.rangeSelection) && obj.rangeSelection.isValidRange()
                obj.deleteRangeSelection();
            end
            
            if isempty(obj.rangeSelection)
                obj.rangeSelection = AnnotationSampleRange(x);
            else
                obj.rangeSelection.addValue(x);
            end
            
            obj.updateRangeSelection();
        end
        
        function updateRangeSelection(obj)
            if isempty(obj.rangeSelection)
                obj.deleteRangeSelection();
            elseif obj.rangeSelection.isValidRange()
                obj.plotRangeSelection();
            end
        end
        
        function plotRangeSelection(obj)
            selectionRanges = obj.rangeSelection.sample1:obj.rangeSelection.sample2;
            selectionMagnitude = obj.magnitude(selectionRanges,:);
            obj.rangeSelectionAxis = plot(obj.plotAxes,selectionRanges,selectionMagnitude,'Color','red');
        end
        
        function deleteRangeSelection(obj)
            if ~isempty(obj.rangeSelectionAxis)
                delete(obj.rangeSelectionAxis);
                obj.rangeSelectionAxis = [];
                obj.rangeSelection = [];
            end
        end
        
        function addPeakAtLocation(obj,x)
            peakIdx = obj.findPeakIdxNearLocation(x);
            
            if peakIdx > 0
                obj.addSampleAtLocation(peakIdx);
            end
        end
        
        function addSampleAtLocation(obj,x)
            y = obj.magnitude(x);
            currentClass = obj.getSelectedClass();
            obj.eventAnnotationsPlotter.addAnnotation(obj.plotAxes,x,y,currentClass);
        end
        
        function updateLoadDataTextbox(obj,~,~)
            obj.uiHandles.loadDataTextbox.String = sprintf('data size: %d x %d',size(obj.data,1),size(obj.data,2));
        end
 
        function populateClassesList(obj)
            classes = obj.classesMap.classesList;
            classes{end+1} = obj.classesMap.synchronisationStr;
            obj.uiHandles.classesList.String = classes;
        end
        
        function deleteAllMarkers(obj)
            obj.clearMarkerPlots();
            obj.markers = [];
        end
        
        function clearMarkerPlots(obj)
            obj.markersPlotter.deleteMarkers();
        end
        
        function deleteAllAnnotations(obj)
            obj.eventAnnotationsPlotter.clearAnnotations();
            obj.rangeAnnotationsPlotter.clearAnnotations();
            obj.annotationSet = [];
        end
                
        function addCurrentRange(obj)
            if ~isempty(obj.rangeSelection) && obj.rangeSelection.isValidRange()
                label = obj.getSelectedClass();
                rangeAnnotation = RangeAnnotation(obj.rangeSelection.sample1,...
                    obj.rangeSelection.sample2,label);
                obj.rangeAnnotationsPlotter.plotAnnotation(obj.plotAxes, rangeAnnotation);
            end
        end
        
        function updateFileName(obj)
            obj.currentFile = obj.uiHandles.fileNamesList.Value;
        end
        
        function fileName = getMarkersFileName(obj)
            fileName = obj.getCurrentFileNameNoExtension();
            fileName = Helper.addMarkersFileExtension(fileName);
        end
        
        function fileName = getSynchronisationFileName(obj)
            fileName = obj.getCurrentFileNameNoExtension();
            fileName = Helper.addSynchronisationFileExtension(fileName);
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
        
        function annotationsFileName = getAnnotationsFileName(obj)
            fileName = obj.getCurrentFileNameNoExtension();
            annotationsFileName = Helper.addAnnotationsFileExtension(fileName);
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
            fileName = Helper.removeFileExtension(dataFileName);
        end
        
        function saveAnnotations(obj)
            eventAnnotations = obj.eventAnnotationsPlotter.getAnnotations();
            rangeAnnotations = obj.rangeAnnotationsPlotter.getAnnotations();
            annotations = AnnotationSet(eventAnnotations,rangeAnnotations);
            if ~isempty(eventAnnotations)
                fileName = obj.getAnnotationsFileName();
                obj.dataLoader.saveAnnotations(annotations,fileName);
            end
        end
        
        function loadAnnotations(obj)
            fileName = obj.getAnnotationsFileName();
            obj.annotationSet = obj.dataLoader.loadAnnotations(fileName);
        end
        
        function loadSynchronisationFile(obj)
            fileName = obj.getSynchronisationFileName();
            obj.synchronisationFile = obj.dataLoader.loadSynchronisationFile(fileName);
        end
        
        function computePlottedSignalYRanges(obj)
            maxY = max(max(obj.magnitude));
            minY = min(min(obj.magnitude));
            
            selectedSignals = obj.preprocessingConfigurator.getSelectedSignalIdxs();
            
            maxYSignals = max(max(obj.data(:,selectedSignals)));
            maxY = max(maxY,maxYSignals);
            
            minYSignals = min(min(obj.data(:,selectedSignals)));
            minY = min(minY,minYSignals);
            obj.plottedSignalYRange = [minY, maxY];
        end
        
        function plotAnnotations(obj)
            if ~isempty(obj.annotationSet) && ~isempty(obj.magnitude)
                obj.rangeAnnotationsPlotter.yRange = obj.plottedSignalYRange;
                obj.eventAnnotationsPlotter.plotAnnotations(obj.plotAxes,obj.annotationSet.eventAnnotations,obj.magnitude);
                obj.rangeAnnotationsPlotter.plotAnnotations(obj.plotAxes,obj.annotationSet.rangeAnnotations);
            end
        end

        function peakIdx = findPeakIdxNearLocation(obj,idx)
            
            [~, peakIdx] = max(obj.magnitude(idx-obj.FindPeaksRadius:idx+obj.FindPeaksRadius));
            peakIdx = int32(peakIdx + idx - obj.FindPeaksRadius - 1);
        end
        
        function computeMagnitude(obj)
            signalComputer = obj.preprocessingConfigurator.createSignalComputerWithUIParameters();
            
            if ~isempty(signalComputer)
                obj.magnitude = signalComputer.compute(obj.data);
            end
        end
        
        %% UI
        function class = getSelectedClass(obj)
            class = int8(obj.uiHandles.classesList.Value);
            if (class == length(obj.uiHandles.classesList.String))
                class = ClassesMap.kSynchronisationClass;
            end
        end

        function updateSelectingPeaksCheckBox(obj)
            obj.uiHandles.peaksCheckBox.Value = obj.isSelectingPeaks;
        end
        
        function shouldSelectPeaks = getShouldSelectPeaks(obj)
            shouldSelectPeaks = obj.uiHandles.peaksCheckBox.Value;
        end
        
        %% Handles
        function outputTxt = handleUserClick(obj,src,~)

            pos = get(src,'Position');
            x = pos(1);
            y = pos(2);
            xStr = num2str(x,7);
            yStr = num2str(y,7);
            outputTxt = {['X: ',xStr],['Y: ',yStr]};
            
            fprintf('%d\n',x);
            
            if obj.state == AnnotationState.kAddMode
                if obj.isSelectingPeaks
                    obj.addPeakAtLocation(x);
                else
                    obj.addSampleAtLocation(x);
                end
            elseif obj.state == AnnotationState.kSelectMode
                obj.selectSampleAtLocation(x);
            elseif obj.state == AnnotationState.kSelectRangesMode
                obj.selectRangeAtLocation(x);
            end
            
            %obj.timestampMarker = 
        end
        
        function handleLoadDataClicked(obj,~,~)
            obj.deleteAll();
            obj.loadAll();
            
            if ~isempty(obj.columnNames)
                obj.preprocessingConfigurator.setColumnNames(obj.columnNames);
            end
            
            if ~isempty(obj.data)
                obj.updateLoadDataTextbox();
            end
        end
        
        function handleVisualizeClicked(obj,~,~)
            if ~isempty(obj.data)
                obj.clearAll();
                obj.computeMagnitude();
                obj.computePlottedSignalYRanges();
                obj.plotData();
                obj.plotAnnotations();
                obj.plotMarkers();
                obj.plotVideo();
            end
        end
        
        function handleStateChanged(obj,~,~)
            
            cursorModeHandle = datacursormode(obj.uiHandles.mainFigure);
            cursorModeHandle.Enable = 'on';
            
            if obj.state == AnnotationState.kSelectRangesMode
                obj.deleteRangeSelection();
            end
            
            switch obj.uiHandles.stateButtonGroup.SelectedObject
                case (obj.uiHandles.selectRadio)
                    obj.state = AnnotationState.kSelectMode;
                case (obj.uiHandles.addRadio)
                    obj.state = AnnotationState.kAddMode;
                case (obj.uiHandles.modifyRadio)
                    obj.state = AnnotationState.kModifyMode;
                    cursorModeHandle.Enable = 'off';
                case (obj.uiHandles.deleteRadio)
                    obj.state = AnnotationState.kDeleteMode;
                    cursorModeHandle.Enable = 'off';
                case (obj.uiHandles.selectRangeRadio)
                    obj.state = AnnotationState.kSelectRangesMode;
            end
        end
        
        function handleSelectingPeaksSelected(obj,~,~)
            obj.isSelectingPeaks = obj.getShouldSelectPeaks();
        end
        
        function handleFindPeaksClicked(obj,~,~)
            for i = 1 : length(obj.markers)
                marker = obj.markers(i);
                segmentStart = marker.sample - ceil(obj.AutoFindPeakRadius/2);
                segmentStart = max(1,segmentStart);
                segmentEnd = marker.sample + ceil(obj.AutoFindPeakRadius/2);
                segmentEnd = min(segmentEnd,length(obj.magnitude));
                
                if segmentStart < segmentEnd
                    segment = obj.magnitude(segmentStart:segmentEnd);
                    [~, maxSample] = max(segment);
                    peakIdx = maxSample + segmentStart - 1;
                    peakX = peakIdx;
                    peakY = obj.magnitude(peakIdx);
                    obj.addPeak(peakX,peakY,1);
                end
            end
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
        
        function handleAddRangeClicked(obj,~,~)
            obj.addCurrentRange();
        end
        
        function handleKeyPressed(obj,~,event)
            if strcmp(event.Key, 'rightarrow')
                %obj.currentTimestamp = obj.currentTimestamp + 10;
            elseif strcmp(event.Key, 'leftarrow')
                %obj.currentTimestamp = obj.currentTimestamp - 10;
            end
            
            %obj.updateTimestampMarker();
        end
        
        %% Helper methods
        function idx = findIdxOfValue(~,valueArray,startIdx,value)
            idx = uint32(-1);
            for i = startIdx : length(valueArray)
                if value == valueArray(i)
                    idx = i;
                    break;
                end
            end
        end
        
         function firstSynchronisatonSample = findFirstSynchronisationSample(obj)
            firstSynchronisatonSample = -1;
            eventAnnotations = obj.annotationSet.eventAnnotations;
            for i = 1 : length(eventAnnotations)
                manualAnnotation = eventAnnotations(i);
                if manualAnnotation.label == ClassesMap.kSynchronisationClass
                    firstSynchronisatonSample = manualAnnotation.sample;
                    break;
                end
            end
        end
        
        function lastSynchronisatonSample = findLastSynchronisationSample(obj)
            lastSynchronisatonSample = -1;
            eventAnnotations = obj.annotationSet.eventAnnotations;
            for i = length(eventAnnotations) : -1 : 1
                manualAnnotation = eventAnnotations(i);
                if manualAnnotation.label == ClassesMap.kSynchronisationClass
                    lastSynchronisatonSample = manualAnnotation.sample;
                    break;
                end
            end
        end
        
        function firstSynchronisationMarker = findFirstSynchronisationMarker(obj)
            firstSynchronisationMarker = -1;
            for i = 1 : length(obj.markers)
                currentMarker = obj.markers(i);
                if currentMarker.label == Constants.kSynchronisatonMarker
                    firstSynchronisationMarker = currentMarker.sample;
                    break;
                end
            end
        end
        
        function lastSynchronisationMarker = findLastSynchronisationMarker(obj)
            lastSynchronisationMarker = -1;
            for i = length(obj.markers) : -1 : 1
                currentMarker = obj.markers(i);
                if currentMarker.label == Constants.kSynchronisatonMarker
                    lastSynchronisationMarker = currentMarker.sample;
                    break;
                end
            end
        end
    end
    
end
