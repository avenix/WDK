classdef AssessmentClassificationResultsViewer < handle
    properties (Access = public)
        detailedClassificationResults;
        delegate;
    end
    
    properties (Access = private)
        %data
        dataLoader;
        dataFile;
        magnitude;
        
        %ui handles
        uiHandles;
        signalPlotHandles;
                
        %video
        videoPlayer;
        synchronisationFile;
        videoFileNames;
        videoFileNamesNoExtension;
        
        %timeline marker
        timeLineMarker;
        timeLineMarkerHandle;
        
        %preprocessing
        preprocessingConfigurator;
        classificationResultsPlotter AssessmentClassificationResultsPlotter;
        
        plottedSignalYRange;
    end
    
    methods (Access = public)
        function  obj = AssessmentClassificationResultsViewer(delegate,detailedClassificationResults)
            obj.delegate = delegate;
            obj.detailedClassificationResults = detailedClassificationResults;
            
            obj.videoFileNames = Helper.listVideoFiles();
            obj.videoFileNamesNoExtension = Helper.removeVideoExtensionForFiles(obj.videoFileNames);
            obj.timeLineMarker = 1;
            obj.dataLoader = DataLoader();
            obj.loadUI();
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
            close(obj.uiHandles.mainFigure);
        end
    end
    
    methods
        function delete(obj)
            if ~isempty(obj.videoPlayer)
                obj.videoPlayer.delegate = [];
                obj.videoPlayer.close();
                obj.deleteVideoPlayer();
            end
        end
    end
    
    methods (Access = private)
        %% init
        function loadUI(obj)
            
            obj.uiHandles = guihandles(PerformanceAssessmentDetailUI);
            obj.initPlotAxes();
            movegui(obj.uiHandles.mainFigure,'center');
            obj.uiHandles.mainFigure.Visible = 'On';
            
            obj.uiHandles.loadDataButton.Callback = @obj.handleLoadDataClicked;
            obj.uiHandles.visualizeButton.Callback = @obj.handleVisualizeClicked;
            obj.uiHandles.mainFigure.KeyPressFcn = @obj.handleKeyPress;
            
            obj.uiHandles.filesList.String = {obj.detailedClassificationResults.fileName};
            obj.uiHandles.mainFigure.DeleteFcn = @obj.handleWindowClosed;
            
            signalComputers = Palette.PreprocessingComputers();
            obj.preprocessingConfigurator = PreprocessingConfiguratorAnnotationApp(...
                signalComputers,...
                obj.uiHandles.signalsList,...
                obj.uiHandles.signalComputerList,...
                obj.uiHandles.signalComputerVariablesTable);
            
            if ~isempty(obj.detailedClassificationResults)
                classNames = obj.detailedClassificationResults(1).validationResult.classNames;
                obj.classificationResultsPlotter = AssessmentClassificationResultsPlotter(obj.uiHandles.plotAxes,classNames);
            end
        end
        
        function initPlotAxes(obj)
            obj.uiHandles.plotAxes.ButtonDownFcn = @obj.handleFigureClick;
            hold(obj.uiHandles.plotAxes,'on');
        end
        
        function setUserClickHandle(obj)
            dataCursorMode = datacursormode(obj.uiHandles.mainFigure);
            dataCursorMode.SnapToDataVertex = 'on';
            dataCursorMode.DisplayStyle = 'window';
            set(dataCursorMode,'UpdateFcn',@obj.handleUserClickOnAxes);
        end
        
        function plotSignal(obj,signal)
            hold(obj.plotAxes,'on');
            n = length(signal);
            xlim(obj.plotAxes,[1,n]);
            plot(obj.plotAxes,signal);
        end
        
        function plotTimelineMarker(obj)
            if ~isempty(obj.timeLineMarker)
                obj.timeLineMarkerHandle = line(obj.uiHandles.plotAxes,[obj.timeLineMarker, obj.timeLineMarker],...
                    [obj.uiHandles.plotAxes.YLim(1), obj.uiHandles.plotAxes.YLim(2)],...
                    'Color','red','LineWidth',2,'LineStyle','-');
            end
        end
                        
        %% other
        function idx = getSelectedFileIdx(obj)
            idx = obj.uiHandles.filesList.Value;
        end
        
        function fileName = getCurrentFileName(obj)
            if isempty(obj.uiHandles.filesList.String)
                fileName = [];
            else
                idx = obj.uiHandles.filesList.Value;
                fileName = obj.uiHandles.filesList.String{idx};
            end
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
        
        function fileName = getCurrentFileNameNoExtension(obj)
            dataFileName = obj.getCurrentFileName();
            fileName = Helper.removeFileExtension(dataFileName);
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
        
        function computePlottedSignalYRanges(obj)
            maxY = max(max(obj.magnitude));
            minY = min(min(obj.magnitude));
            
            selectedSignals = obj.preprocessingConfigurator.getSelectedSignalIdxs();
            
            maxYSignals = max(max(obj.dataFile.data(:,selectedSignals)));
            maxY = max(maxY,maxYSignals);
            
            minYSignals = min(min(obj.dataFile.data(:,selectedSignals)));
            minY = min(minY,minYSignals);
            obj.plottedSignalYRange = [minY, maxY];
            
        end
        
        function updateLoadDataTextbox(obj,~,~)
            obj.uiHandles.loadDataTextbox.String = sprintf('data size: %d x %d',obj.dataFile.numRows,obj.dataFile.numColumns);
        end
        
        %% plotting
        function plotData(obj)
            if ~isempty(obj.dataFile)
                hold(obj.uiHandles.plotAxes,'on');
                
                selectedSignals = obj.preprocessingConfigurator.getSelectedSignalIdxs();
                nSignals = length(selectedSignals);
                obj.signalPlotHandles = cell(1,nSignals+1);
                
                for i = 1 : nSignals
                    signalIdx = selectedSignals(i);
                    obj.signalPlotHandles{i} = plot(obj.uiHandles.plotAxes,obj.dataFile.data(:,signalIdx));
                end
                obj.signalPlotHandles{nSignals+1} = plot(obj.uiHandles.plotAxes,obj.magnitude);
                
                n = size(obj.magnitude,1);
                axis(obj.uiHandles.plotAxes,[1,n,obj.plottedSignalYRange(1) * 1.1, obj.plottedSignalYRange(2) * 1.1]);
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
        
        function computeMagnitude(obj)
            signalComputer = obj.preprocessingConfigurator.createSignalComputerWithUIParameters();
            
            if ~isempty(signalComputer)
                obj.magnitude = signalComputer.compute(obj.dataFile.data);
            end
        end
        
        %% deleting
        function deleteVideoPlayer(obj)
            delete(obj.videoPlayer);
            obj.videoPlayer = [];
        end
                
        function deleteTimelineMarker(obj)
            obj.timeLineMarker = [];
            delete(obj.timeLineMarkerHandle);
            obj.timeLineMarkerHandle = [];
        end
        
        function clearAll(obj)
            obj.clearDataPlots();
            cla(obj.uiHandles.plotAxes);
        end
        
        function deleteAll(obj)
            obj.deleteData();
            if ~isempty(obj.videoPlayer)
                obj.videoPlayer.close();
            end
            obj.deleteTimelineMarker();
        end
        
        function deleteData(obj)
            obj.clearDataPlots();
            obj.magnitude = [];
            obj.dataFile = [];
        end
        
        function clearDataPlots(obj)
            cla(obj.uiHandles.plotAxes,'reset');
            obj.initPlotAxes();
            obj.signalPlotHandles = [];
        end
        
        %% loading
        function loadSynchronisationFile(obj)
            fileName = obj.getSynchronisationFileName();
            obj.synchronisationFile = obj.dataLoader.loadSynchronisationFile(fileName);
        end
        
        function loadData(obj)
            fileName = obj.getCurrentFileName();
            if ~isempty(fileName)
                obj.dataFile = obj.dataLoader.loadDataFile(fileName);
            end
        end
        
        function loadVideo(obj)
            
            videoFileName = obj.getVideoFileName();
            
            if ~isempty(videoFileName)
                
                if ~isempty(obj.videoPlayer)
                    obj.videoPlayer.close();
                end
                
                currentWindowPosition = obj.uiHandles.mainFigure.OuterPosition;
                currentHeight = currentWindowPosition(4);
                positionX = currentWindowPosition(1) + currentWindowPosition(3);                
                windowPosition = [positionX, currentWindowPosition(2), currentHeight, currentHeight];
                
                obj.videoPlayer = VideoPlayer(videoFileName,obj,windowPosition);
                obj.updateVideoFrame();
            end
        end
        
        %% Handles
        function handleLoadDataClicked(obj,~,~)
            
            obj.deleteAll();
            
            obj.loadData();
            if ~isempty(obj.dataFile)
                obj.timeLineMarker = 1;
            end
            obj.loadSynchronisationFile();
            obj.loadVideo();
            
            if ~isempty(obj.dataFile)
                obj.preprocessingConfigurator.setColumnNames(obj.dataFile.columnNames);
                obj.updateLoadDataTextbox();
            end
        end
        
        function handleVisualizeClicked(obj,~,~)
            if ~isempty(obj.dataFile)
                obj.clearAll();
                obj.computeMagnitude();
                obj.computePlottedSignalYRanges();
                obj.plotData();
                obj.plotTimelineMarker();
                
                selectedIdx = obj.getSelectedFileIdx();
                currentResults = obj.detailedClassificationResults(selectedIdx);
                
                obj.classificationResultsPlotter.yRange = obj.plottedSignalYRange;
                obj.classificationResultsPlotter.plotClassificationResults(currentResults,obj.magnitude);
            end
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
            if ~isempty(obj.delegate)
                obj.delegate.handleDetailedClassificationViewerClosed();
            end
        end
    end
end