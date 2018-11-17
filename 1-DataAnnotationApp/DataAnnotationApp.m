classdef DataAnnotationApp < handle
    
    properties (Constant)
        NMaxPeaks = 500;
        FindPeaksRadius = 50;
        AutoFindPeakRadius = 100;
        SamplingFrequency = 200;
        SegmentHeight = 30;
    end
    
    properties (Access = private)
        
        %class management
        classesMap;
        
        %data loading
        currentFile;
        dataLoader;
        
        %data
        data;
        magnitude;
        columnNames;
        
        %signal computers
        signalComputers;
                
        %annotations
        annotationSet;
        eventAnnotationsPlotter;
        rangeAnnotationsPlotter;

        %markers
        markers;
        markerHandles;
        markersPlotter;
        
        %ui   
        state;    
        uiHandles;
        plotAxes;
        rangeSelectionAxis = [];
        rangeSelection = [];
        plotHandles;
        
        %ui state
        showingMarkers = 1;
    end
    
    methods (Access = public)
        
        function obj =  DataAnnotationApp()
            obj.classesMap = ClassesMap();
            obj.dataLoader = DataLoader();
            obj.signalComputers = [SignalComputer.NoOpComputer, SignalComputer.EnergyComputer()];
            obj.markersPlotter = MarkersPlotter();
            
            obj.eventAnnotationsPlotter = EventAnnotationsPlotter(obj.classesMap);
            obj.eventAnnotationsPlotter.delegate = obj;
            
            obj.rangeAnnotationsPlotter = RangeAnnotationsPlotter(obj.classesMap);
            obj.rangeAnnotationsPlotter.delegate = obj;
            
            obj.currentFile = 1;
            obj.state = DataAnnotatorState.kAddPeaksMode;
            
            obj.loadUI();
        end
             
        function handleAnnotationClicked(obj,source,~)
            tag = str2double(source.Tag);
            if obj.state == DataAnnotatorState.kDeletePeaksMode
                obj.eventAnnotationsPlotter.deleteAnnotationAtSampleIdx(tag);
                obj.rangeAnnotationsPlotter.deleteAnnotationAtSampleIdx(tag);
            elseif obj.state == DataAnnotatorState.kModifyPeaksMode
                currentClass = obj.uiHandles.classesList.Value;
                obj.eventAnnotationsPlotter.modifyAnnotationToClass(uint32(tag),currentClass);
                obj.rangeAnnotationsPlotter.modifyAnnotationToClass(uint32(tag),currentClass);
            end
        end
    end
    
    methods (Access = private)

        function loadUI(obj)
            obj.uiHandles = guihandles(DataAnnotationUI);
            
            obj.uiHandles.fileNamesList.Callback = @obj.handleSelectionChanged;
            obj.uiHandles.loadDataButton.Callback = @obj.handleLoadDataClicked;
            obj.uiHandles.visualizeButton.Callback = @obj.handleVisualizeClicked;
            obj.uiHandles.showMarkersCheckBox.Callback = @obj.handleShowMarkersToggled;
            obj.uiHandles.stateButtonGroup.SelectionChangedFcn = @obj.handleStateChanged;
            obj.uiHandles.findButton.Callback = @obj.handleFindPeaksClicked;
            obj.uiHandles.saveButton.Callback = @obj.handleSaveClicked;
            obj.uiHandles.addRangeAnnotationButton.Callback = @obj.handleAddRangeClicked;
            
            obj.resetUI();
            obj.loadPlotAxes();
            obj.setUserClickHandle();
            obj.populateFileNamesList();
            obj.populateClassesList();
            
            obj.fillSignalsComputerList();
        end
        
        function resetUI(obj)
            obj.uiHandles.loadDataTextbox.String = "";
        end
        
        function loadAll(obj)
            if obj.classesMap.numClasses > 0
                obj.loadData();
                obj.loadAnnotations();
                obj.loadMarkers();
            end
        end
        
        function populateFileNamesList(obj)
            extensions = {'*.mat','*.txt'};
            files = Helper.listDataFiles(extensions);
            obj.uiHandles.fileNamesList.String = files;
        end
        
        function loadPlotAxes(obj)
            obj.plotAxes = axes(obj.uiHandles.figure1);
            obj.plotAxes.Units = 'characters';
            obj.plotAxes.Position  = [35 4 270 57];
            obj.plotAxes.Visible = 'Off';
        end
        
        function setUserClickHandle(obj)
            dataCursorMode = datacursormode(obj.uiHandles.figure1);
            dataCursorMode.SnapToDataVertex = 'on';
            dataCursorMode.DisplayStyle = 'window';
            dataCursorMode.Enable = 'on';
            set(dataCursorMode,'UpdateFcn',@obj.handleUserClick);
        end
        
        function loadData(obj)
            fileName = obj.getDataFileName();
            [obj.data, obj.columnNames] = obj.dataLoader.loadAnyDataFile(fileName);
        end
        
        function loadMarkers(obj)
            markersFileName = obj.getMarkersFileName();
            obj.markers = obj.dataLoader.loadMarkers(markersFileName);
            
            if ~isempty(obj.markers)
                x1 = obj.findFirstSynchronisationMarker();
                x2 = obj.findLastSynchronisationMarker();
                y1 = obj.findFirstSynchronisationSample();
                y2 = obj.findLastSynchronisationSample();
                
                a = double(y2-y1) / (x2-x1);
                
                for i = 1 : length(obj.markers)
                    currentMarker = obj.markers(i);
                    currentMarker.sample = a * (currentMarker.sample - x1) + y1;
                    obj.markers(i) = currentMarker;
                end
            end
        end
  
        function plotData(obj)
            if ~isempty(obj.data)
                hold(obj.plotAxes,'on');
                selectedSignals = obj.getSelectedSignals();
                nSignals = length(selectedSignals);
                obj.plotHandles = cell(1,nSignals+1);
                
                for i = 1 : nSignals
                    signalIdx = selectedSignals(i);
                    obj.plotHandles{i} = plot(obj.plotAxes,obj.data(:,signalIdx));
                end
                obj.plotHandles{nSignals+1} = plot(obj.plotAxes,obj.magnitude);
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
                obj.markersPlotter.plotMarkers(obj.markers,obj.plotAxes,obj.showingMarkers);
            end
        end
        
        function selectSampleAtLocation(obj,x)
            if isempty(obj.rangeSelection)
                obj.rangeSelection = DataAnnotatorSampleRange(x);
            else
                obj.rangeSelection.addValue(x);
            end
            
            obj.updateRangeSelection();
        end
        
        function updateRangeSelection(obj)
            if isempty(obj.rangeSelection)
                obj.deleteRangeSelection();
            else
                if obj.rangeSelection.isValidRange()
                    obj.plotRangeSelection();
                else
                    obj.deleteRangeSelection();
                end
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
                y = obj.magnitude(peakIdx);
                currentClass = obj.getSelectedClass();
                obj.eventAnnotationsPlotter.addAnnotation(obj.plotAxes,peakIdx,y,currentClass);
            end
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
            if ~isempty(obj.rangeSelection)
                label = obj.getSelectedClass();
                rangeAnnotation = RangeAnnotation(obj.rangeSelection.sample1,...
                    obj.rangeSelection.sample2,label);
                obj.rangeAnnotationsPlotter.plotAnnotation(obj.plotAxes, rangeAnnotation);
            end
        end
        
        function updateFileName(obj)
            obj.currentFile = obj.uiHandles.fileNamesList.Value;
        end
        
        function markersFileName = getMarkersFileName(obj)
            fileName = obj.getCurrentFileNameNoExtension();
            markersFileName = sprintf('%s-markers.edl',fileName);
        end
        
        function annotationsFileName = getAnnotationsFileName(obj)
            fileName = obj.getCurrentFileNameNoExtension();
            annotationsFileName = Helper.addAnnotationsFileExtension(fileName);
        end
        
        function fileName = getDataFileName(obj)
            fileName = obj.uiHandles.fileNamesList.String{obj.currentFile};
        end
        
        function fileName = getCurrentFileNameNoExtension(obj)
            dataFileName = obj.getDataFileName();
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
            peaksFileName = obj.getAnnotationsFileName();
            obj.annotationSet = obj.dataLoader.loadAnnotations(peaksFileName);
        end
        
        function plotAnnotations(obj)
            if ~isempty(obj.annotationSet) && ~isempty(obj.magnitude)
                
                obj.eventAnnotationsPlotter.plotAnnotations(obj.plotAxes,obj.annotationSet.eventAnnotations,obj.magnitude);
                obj.rangeAnnotationsPlotter.plotAnnotations(obj.plotAxes,obj.annotationSet.rangeAnnotations);
            end
        end
                
        function peakIdx = findPeakIdxNearLocation(obj,idx)
            
            [~, peakIdx] = max(obj.magnitude(idx-obj.FindPeaksRadius:idx+obj.FindPeaksRadius));
            peakIdx = int32(peakIdx + idx - obj.FindPeaksRadius - 1);
        end
        
        
        %% UI
        function class = getSelectedClass(obj)
            class = uint8(obj.uiHandles.classesList.Value);
        end
        
        function selectedSignals = getSelectedSignals(obj)
            selectedSignals = obj.uiHandles.signalsList.Value;
        end
        
        function signalComputer = getSelectedSignalComputer(obj)
            signalComputerIdx = obj.uiHandles.signalComputerList.Value;
            signalComputer = obj.signalComputers(signalComputerIdx);
        end
        
        function updateSignalsList(obj)
            str = Helper.cellArrayToString(obj.columnNames);
            obj.uiHandles.signalsList.String = str;
        end
        
        function fillSignalsComputerList(obj)
            str = Helper.generateSignalComputerNames(obj.signalComputers);
            obj.uiHandles.signalComputerList.String = str;
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
            
            if obj.state == DataAnnotatorState.kAddPeaksMode
                obj.addPeakAtLocation(x);
            elseif obj.state == DataAnnotatorState.kSelectSamplesMode
                obj.selectSampleAtLocation(x);
            end
        end
        
        function handleLoadDataClicked(obj,~,~)
            obj.deleteAll();
            obj.loadAll();
            obj.updateLoadDataTextbox();
            obj.updateSignalsList();
        end
        
        function computeMagnitude(obj)
            signalComputer = obj.getSelectedSignalComputer();
            if ~isempty(signalComputer)
                signalIdxs = obj.getSelectedSignals();
                signals = obj.data(:,signalIdxs);
                obj.magnitude = signalComputer.compute(signals);
            end
        end
        
        function handleVisualizeClicked(obj,~,~)
            if ~isempty(obj.data)
                obj.clearAll();
                obj.computeMagnitude();
                obj.plotData();
                obj.plotAnnotations();
                obj.plotMarkers();
            end
        end
        
        function handleStateChanged(obj,~,~)
            
            cursorModeHandle = datacursormode(obj.uiHandles.figure1);
            cursorModeHandle.Enable = 'on';
            
            if obj.state == DataAnnotatorState.kSelectSamplesMode
                obj.deleteRangeSelection();
            end
            
            switch obj.uiHandles.stateButtonGroup.SelectedObject
                case (obj.uiHandles.addPeaksRadio)
                    obj.state = DataAnnotatorState.kAddPeaksMode;
                case (obj.uiHandles.modifyPeaksRadio)
                    obj.state = DataAnnotatorState.kModifyPeaksMode;
                    cursorModeHandle.Enable = 'off';
                case (obj.uiHandles.deletePeaksRadio)
                    obj.state = DataAnnotatorState.kDeletePeaksMode;
                    cursorModeHandle.Enable = 'off';
                case (obj.uiHandles.selectRangeRadio)
                    obj.state = DataAnnotatorState.kSelectSamplesMode;
            end
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
            obj.showingMarkers = ~obj.showingMarkers;
            obj.markersPlotter.toggleMarkersVisibility(obj.showingMarkers);
        end
        
        function handleSelectionChanged(obj,~,~)
            obj.updateFileName();
        end
        
        function handleAddRangeClicked(obj,~,~)
            obj.addCurrentRange();
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
                peakLabel = manualAnnotation.label;
                if peakLabel == obj.classesMap.synchronisationClass
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
                peakLabel = manualAnnotation.label;
                if peakLabel == obj.classesMap.synchronisationClass
                    lastSynchronisatonSample = manualAnnotation.sample;
                    break;
                end
            end
        end
        
        function firstSynchronisationMarker = findFirstSynchronisationMarker(obj)
            firstSynchronisationMarker = -1;
            for i = 1 : length(obj.markers)
                currentMarker = obj.markers(i);
                if currentMarker.label == Constants.SynchronisatonMarker
                    firstSynchronisationMarker = currentMarker.sample;
                    break;
                end
            end
        end
        
        function lastSynchronisationMarker = findLastSynchronisationMarker(obj)
            lastSynchronisationMarker = -1;
            for i = length(obj.markers) : -1 : 1
                currentMarker = obj.markers(i);
                if currentMarker.label == Constants.SynchronisatonMarker
                    lastSynchronisationMarker = currentMarker.sample;
                    break;
                end
            end
        end
    end
    
end
