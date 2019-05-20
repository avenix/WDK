classdef DetectionEventsPlotter < handle
    
    properties (Access = public, Constant)
        FontSize = 22;
        SymbolSize = 10;
    end
    
    properties (Access = public)
        labelGrouping ClassesMap;
        delegate;
    end
    
    properties (Access = private)
        showingDetectedEventsPrivate = true;
        showingMissedEventsPrivate = true;
        showingFalsePositiveEventsPrivate = true;
        
        %data
        dataLoader;
        fileNames;
        signalsPerFile;
        resultsPerFile;
        
        %ui handles
        figureHandle;
        plotAxes;
        uiHandles;
        
        %events
        detectedEventHandles;
        missedEventHandles;
        falsePositiveEventHandles;
        
        %video
        videoPlayer;
        synchronisationFile;
        videoFileNames;
        videoFileNamesNoExtension;
        
        %timeline marker
        timeLineMarker;
        timeLineMarkerHandle;
    end
    
    properties (Dependent)
        showingDetectedEvents;
        showingMissedEvents;
        showingFalsePositiveEvents;
    end
    
    methods
        function set.showingDetectedEvents(obj,value)
            obj.showingDetectedEventsPrivate = value;
            if ~isempty(obj.detectedEventHandles)
                obj.toggleEventsVisibility(obj.detectedEventHandles,value);
            end
        end
        
        function set.showingMissedEvents(obj,value)
            obj.showingMissedEventsPrivate = value;
            if ~isempty(obj.missedEventHandles)
                obj.toggleEventsVisibility(obj.missedEventHandles,value);
            end
        end
        
        function set.showingFalsePositiveEvents(obj,value)
            obj.showingFalsePositiveEventsPrivate = value;
            if ~isempty(obj.falsePositiveEventHandles)
                obj.toggleEventsVisibility(obj.falsePositiveEventHandles,value);
            end
        end
        
        function delete(obj)
            if ~isempty(obj.videoPlayer)
                obj.videoPlayer.delegate = [];
                obj.videoPlayer.close();
                obj.deleteVideoPlayer();
            end
        end
    end
    
    methods (Access = public)
        function obj = DetectionEventsPlotter(delegate,signalsPerFile,resultsPerFile,fileNames, figurePosition)
            
            obj.delegate = delegate;
            obj.signalsPerFile = signalsPerFile;
            obj.resultsPerFile = resultsPerFile;
            obj.fileNames = fileNames;
            
            obj.dataLoader = DataLoader();
            
            obj.videoFileNames = Helper.listVideoFiles();
            obj.videoFileNamesNoExtension = Helper.removeVideoExtensionForFiles(obj.videoFileNames);
            
            obj.timeLineMarker = 1;
            
            obj.loadUI();
            if nargin > 3
                obj.figureHandle.OuterPosition(1) = figurePosition(1);
                obj.figureHandle.OuterPosition(2) = figurePosition(2);
            end
        end
        
        function handleFrameChanged(obj,~)
            if ~isempty(obj.synchronisationFile)
                obj.timeLineMarker = obj.synchronisationFile.videoFrameToSample(obj.videoPlayer.currentFrame);
                if ~isempty(obj.timeLineMarkerHandle)
                    obj.updateTimelineMarker();
                end
            end
        end
        
        function handleVideoPlayerWindowClosed(obj)
            obj.deleteVideoPlayer();
        end
        
        function close(obj)
            close(obj.figureHandle);
        end
        
        function clearPlot(obj)
            cla(obj.plotAxes);
        end
    end
    
    methods (Access = private)
        %% init
        function loadUI(obj)
            
            obj.uiHandles = guihandles(DetectionEventsPlotterUI);
            obj.figureHandle = obj.uiHandles.mainFigure;
            
            obj.plotAxes = obj.uiHandles.plotAxes;
            obj.plotAxes.ButtonDownFcn = @obj.handleFigureClick;
            hold(obj.plotAxes,'on');
            
            obj.uiHandles.visualizeButton.Callback = @obj.handleVisualizeClicked;
            obj.uiHandles.mainFigure.KeyPressFcn = @obj.handleKeyPress;
            
            obj.uiHandles.showDetectedCheckBox.Callback = @obj.handleShowDetectedEventsCheckBoxChanged;
            obj.uiHandles.showMissedCheckBox.Callback = @obj.handleShowMissedEventsCheckBoxChanged;
            obj.uiHandles.showFalsePositivesCheckBox.Callback = @obj.handleShowFalsePositiveEventsCheckBoxChanged;
            
            %populate files
            obj.uiHandles.filesList.String = obj.fileNames;
            obj.figureHandle.DeleteFcn = @obj.handleWindowClosed;
        end
        
        function setUserClickHandle(obj)
            dataCursorMode = datacursormode(obj.uiHandles.mainFigure);
            dataCursorMode.SnapToDataVertex = 'on';
            dataCursorMode.DisplayStyle = 'window';
            set(dataCursorMode,'UpdateFcn',@obj.handleUserClickOnAxes);
        end
        
        %% plotting
        
        function plotSignal(obj,signal)
            hold(obj.plotAxes,'on');
            n = length(signal);
            xlim(obj.plotAxes,[1,n]);
            plot(obj.plotAxes,signal);
        end
        
        function plotTimelineMarker(obj)
            if ~isempty(obj.timeLineMarker)
                obj.timeLineMarkerHandle = line(obj.plotAxes,[obj.timeLineMarker, obj.timeLineMarker],...
                    [obj.plotAxes.YLim(1), obj.plotAxes.YLim(2)],...
                    'Color','red','LineWidth',2,'LineStyle','-');
            end
        end
        
        function plotAllEvents(obj,signal,currentFileResults)
            
            obj.detectedEventHandles = obj.plotEvents(currentFileResults.goodEvents,signal,Constants.kCorrectColor);
            obj.missedEventHandles = obj.plotEvents(currentFileResults.missedEvents,signal,Constants.kMissedEventColor);
            obj.falsePositiveEventHandles = obj.plotEvents(currentFileResults.badEvents,signal,Constants.kWrongColor);
            
            if ~obj.showingDetectedEventsPrivate
                obj.toggleEventsVisibility(obj.detectedEventHandles,false);
            end
            
            if ~obj.showingMissedEventsPrivate
                obj.toggleEventsVisibility(obj.missedEventHandles,false);
            end
            
            if ~obj.showingFalsePositiveEventsPrivate
                obj.toggleEventsVisibility(obj.falsePositiveEventHandles,false);
            end
        end
        
        function eventHandles = plotEvents(obj,events,signal,symbolColor)
            eventHandles = [];
            nEvents = length(events);
            if nEvents > 0
                eventHandles = repmat(DetectionEventHandle(), 1, nEvents);
                for i = 1 : length(events)
                    event = events(i);
                    eventX = event.sample;
                    eventY = signal(eventX);
                    label = event.label;
                    if label == ClassesMap.kNullClass
                        classStr = Constants.kNullClassGroupStr;
                    else
                        classStr = obj.labelGrouping.classNames{label};
                    end
                    
                    symbolHandle = plot(obj.plotAxes,eventX,eventY,'*','Color',symbolColor,'LineWidth',DetectionEventsPlotter.SymbolSize);
                    textHandle = text(obj.plotAxes,double(eventX),double(eventY), classStr,'FontSize',DetectionEventsPlotter.FontSize, 'Color',symbolColor);
                    set(textHandle, 'Clipping', 'on');
                    
                    eventHandle = DetectionEventHandle(event,symbolHandle,textHandle);
                    eventHandles(i) = eventHandle;
                end
            end
        end
        
        function plotVideo(obj)
            fileIdx = obj.uiHandles.filesList.Value;
            fileName = obj.uiHandles.filesList.String{fileIdx};
            
            [videoFileName, synchronisationFileName] = obj.getVideoAndSynchronisationFileName(fileName);
            
            obj.synchronisationFile = obj.dataLoader.loadSynchronisationFile(synchronisationFileName);
            
            if ~isempty(videoFileName)
                if ~isempty(obj.videoPlayer)
                    obj.videoPlayer.close();
                end
                
                currentWindowPosition = obj.figureHandle.OuterPosition;
                currentHeight = currentWindowPosition(4);
                positionX = currentWindowPosition(1) + currentWindowPosition(3);                
                windowPosition = [positionX, currentWindowPosition(2), currentHeight, currentHeight];
                
                obj.videoPlayer = VideoPlayer(videoFileName,obj,windowPosition);
                obj.updateVideoFrame();
            end
        end
        
        
        %% other
        function idx = getSelectedFileIdx(obj)
            idx = obj.uiHandles.filesList.Value;
        end
        
        
        function toggleEventsVisibility(~,eventHandles,visible)
            for i = 1 : length(eventHandles)
                eventHandle = eventHandles(i);
                eventHandle.setVisible(visible);
            end
        end
        
        function [videoFileName, synchronisationFileName] = getVideoAndSynchronisationFileName(obj,fileName)
            fileName = Helper.removeFileExtension(fileName);
            [~,idx] = ismember(fileName,obj.videoFileNamesNoExtension);
            if idx > 0
                videoFileName = obj.videoFileNames{idx};
                synchronisationFileName = Helper.addSynchronisationFileExtension(fileName);
            else
                videoFileName = [];
                synchronisationFileName = [];
            end
        end
        
        
        function updateVideoFrame(obj)
            if ~isempty(obj.synchronisationFile) && ~isempty(obj.videoPlayer)
                videoFrame = obj.synchronisationFile.sampleToVideoFrame(obj.timeLineMarker);
                obj.videoPlayer.displayFrame(videoFrame);
            end
        end
        function updateTimelineMarker(obj)
            set(obj.timeLineMarkerHandle,'XData',[obj.timeLineMarker, obj.timeLineMarker]);
            drawnow;
        end
        
        function deleteVideoPlayer(obj)
            delete(obj.videoPlayer);
            obj.videoPlayer = [];
        end
        
        %% Handles
        function handleVisualizeClicked(obj,~,~)
            selectedIdx = obj.getSelectedFileIdx();
            currentSignal = obj.signalsPerFile{selectedIdx};
            currentResults = obj.resultsPerFile(selectedIdx);
            
            if ~isempty(obj.plotAxes)
                obj.clearPlot();
            end
            
            if ~isempty(obj.videoPlayer)
                obj.videoPlayer.close();
            end
            
            obj.plotSignal(currentSignal);
            obj.plotTimelineMarker();
            obj.plotAllEvents(currentSignal,currentResults);
            obj.plotVideo();
        end
        
        function handleUserClickOnAxes(obj,~,~)
            x = pos(1);
            obj.timeLineMarker = x;
            obj.updateTimelineMarker();
            obj.updateVideoFrame();
        end
        
        function handleKeyPress(obj, source, event)
            if ~isempty(obj.videoPlayer)
                obj.videoPlayer.handleKeyPress(source,event);
            end
        end
        
        function handleFigureClick(obj,~,event)
            x = event.IntersectionPoint(1);
            obj.timeLineMarker = x;
            obj.updateTimelineMarker();
            obj.updateVideoFrame();
        end
        
        function handleWindowClosed(obj,~,~)            
            obj.delegate.handleEventsPlotterWindowClosed();
        end
        
        function handleShowDetectedEventsCheckBoxChanged(obj,~,~)
            value = obj.uiHandles.showDetectedCheckBox.Value;
            obj.showingDetectedEvents = value;
        end
        
        function handleShowMissedEventsCheckBoxChanged(obj,~,~)
            value = obj.uiHandles.showMissedCheckBox.Value;
            obj.showingMissedEvents = value;
        end
        
        function handleShowFalsePositiveEventsCheckBoxChanged(obj,~,~)
            value = obj.uiHandles.showFalsePositivesCheckBox.Value;
            obj.showingFalsePositiveEvents = value;
        end
    end
    
end