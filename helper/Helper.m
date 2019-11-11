classdef Helper < handle
    methods (Access = public, Static)
        %% File management
        function fileExtension = getFileExtension(fileName)
            n = length(fileName);
            extensionSeparator = n - strfind(flip(fileName),'.') + 1;
            fileExtension = fileName(extensionSeparator:end);
        end
        
        function files = listFilesInDirectory(directory,extensions)
            nExtensions = length(extensions);
            filesCount = 0;
            nFiles = Helper.numberOfFilesInDirectory(directory,extensions);
            files = cell(1,nFiles);
            
            for i = 1 : nExtensions
                extension = extensions{i};
                filesStructs = dir(fullfile(directory, extension));
                for j = 1 : length(filesStructs)
                    file = filesStructs(j);
                    filesCount = filesCount + 1;
                    files{filesCount} = file.name;
                end
            end
        end
        
        function nFiles = numberOfFilesInDirectory(directory,extensions)
            nFiles = 0;
            
            nExtensions = length(extensions);
            for i = 1 : nExtensions
                extension = extensions{i};
                filesStructs = dir(fullfile(directory, extension));
                nFiles = nFiles + length(filesStructs);
            end
        end
        
        function files = listARChainFiles()
            files = Helper.listFilesInDirectory(Constants.kARChainsPath, {'*.mat'});
        end
        
        function files = listLabelGroupings()
            files = Helper.listFilesInDirectory(Constants.kLabelGroupingsPath, {'*.txt'});
        end
        
        function files = listDataFiles(extensions)
            if (nargin == 0)
                extensions = {'*.mat','*.txt'};
            end
            
            files = Helper.listFilesInDirectory(Constants.kDataPath, extensions);
        end
        
        function files = listAnnotationFiles()
            files = Helper.listFilesInDirectory(Constants.kAnnotationsPath, {'*.txt'});
        end
        
        function files = listSynchronizationFileNames()
            files = Helper.listFilesInDirectory(Constants.kVideosPath, {'*.txt'});
        end
        
        function files = listVideoFiles()
            files = Helper.listFilesInDirectory(Constants.kVideosPath, {'*.mov','*.MP4','*.avi'});
        end
        
        function fileName = addSynchronizationFileExtension(fileName)
            fileName = sprintf('%s-synchronization.txt',fileName);
        end
        
        function fileName = addVideoFileExtension(fileName)
            fileName = sprintf('%s-video',fileName);
        end
        
        function fileName = addAnnotationsFileExtension(fileName)
            fileName = sprintf('%s-annotations.txt',fileName);
        end
        
        function fileName = addMarkersFileExtension(fileName)
            fileName = sprintf('%s-markers.edl',fileName);
        end

        function fileNames = addAnnotationsFileExtensionForFiles(fileNames)
            fileNames = cellfun(@(fileName) Helper.addAnnotationsFileExtension(fileName),fileNames,'UniformOutput',false);
        end
        
        function fileName = removeFileExtension(dataFileName)
            n = length(dataFileName);
            periodIdx = strfind(flip(dataFileName),'.');
            if isempty(periodIdx)
                fileName = dataFileName;
            else
                fileName = dataFileName(1:n-periodIdx(1));
            end
        end
        
        function fileNames = removeFileExtensionForFiles(dataFileNames)
            fileNames = cellfun(@Helper.removeFileExtension,dataFileNames,'UniformOutput',false);
        end
        
        function fileName = removeAnnotationsExtension(fileName)
            idx = strfind(fileName,'-annotations');
            fileName = fileName(1:idx-1);
        end
        
        function fileName = removeVideoExtension(fileName)
            idx = strfind(fileName,'-video');
            fileName = fileName(1:idx-1);
        end
        
        function fileNames = removeVideoExtensionForFiles(dataFileNames)
            fileNames = cellfun(@Helper.removeVideoExtension,dataFileNames,'UniformOutput',false);
        end
        
        function fileNames = removeDataFileExtensionForFiles(dataFileNames)

            nFiles = length(dataFileNames);
            fileNames = cell(nFiles,1);
            for fileIdx = 1 : nFiles
                dataFileName = dataFileNames{fileIdx};
                fileNameNoExtension = Helper.removeFileExtension(dataFileName);
                fileNames{fileIdx} = fileNameNoExtension;
            end
        end
        
        %% Conversion methods
        function array = cellArray2FlatArray(cellArray)
            
            n = Helper.nElementsInCellArray(cellArray);
            array = zeros(1,n);
            
            currentIdx = 1;
            for i = 1 : length(cellArray)
                currentArray = cellArray{i};
                nLocal = length(currentArray);
                array(currentIdx:currentIdx + nLocal - 1) = cellArray{i};
                currentIdx = currentIdx + nLocal;
            end
        end
        
        function cellArray = propertyArrayToCellArray(propertyArray)
            numProperties = length(propertyArray);
            cellArray = cell(numProperties,2);
            for i = 1 : numProperties
                property = propertyArray(i);
                cellArray{i,1} = property.name;
                cellArray{i,2} = property.value;
            end
        end
        
        function str = cellArrayToString(cellArray,delimiter)
            if isempty(cellArray)
                str = "";
            else
                
                if nargin == 1
                    delimiter = '\n';
                end
                str = cellArray{1};
                nCells = length(cellArray);
                for i = 2 : nCells
                    cellStr = cellArray{i};
                    str = sprintf('%s%c%s',str,delimiter,cellStr);
                end
            end
        end
        
        function text = arrayToString(numbers,delimiter)
            if isempty(numbers)
                text = "";
            else
                if nargin == 1
                    delimiter = '\n';
                end
                n = length(numbers);
                text = num2str(numbers(1));
                for i = 2 : n
                    numStr = num2str(numbers(i));
                    text = sprintf('%s%c%s',text,delimiter,numStr);
                end
            end
        end
        
        %% Helper methods
        function PrintWrongDataTypeMessage(receivedType,expectedType,currentObject)
            fprintf('Wrong input data type received: %s. Expected: %s. In Algorithm: %s\n',receivedType,expectedType,currentObject);
        end
        
        function labeler = FindLabelerInUserChain(classificationChain)
            
            labeler = [];
            graph = AlgorithmGraph.CreateGraph(classificationChain);
            for i = 1 : length(graph.nodes)
                algorithm = graph.nodes{i};
                if isa(algorithm,'EventsLabeler') || isa(algorithm,'EventSegmentsLabeler') || isa(algorithm,'RangeSegmentsLabeler')
                    labeler = algorithm;
                    break;
                end
            end
        end
        
        function signals = LoadSignalNames()
            dataFiles = Helper.listDataFiles();
            signals = [];
            if ~isempty(dataFiles)
                fileName = dataFiles{1};
                dataFile = DataLoader.LoadDataFile(fileName);
                signals = dataFile.columnNames;
            end
        end
                
        function classStr = StringForClass(class, classNames)
            if class == Labeling.kNullClass
                classStr = Labeling.kNullClassStr;
            else
                classStr = classNames{class};
            end
        end
            
        function totalSize = ComputeObjectSize(obj)
            props = properties(obj);
            totalSize = 0;
            
            for i = 1:length(props)
                currentProperty = getfield(obj, char(props(i)));
                s = whos('currentProperty');
                totalSize = totalSize + s.bytes;
            end
        end
        
        function b = IsPowerOf2(x)
            b = (bitand(x, x - 1) == 0);
        end

        function labeledSegments = LabelSegmentsWithValidLabels(segments,labels)
            
            isValidLabel = ~Labeling.ShouldIgnoreLabels(labels);
            nValidSegments = sum(isValidLabel);
            labeledSegments = repmat(Segment,1,nValidSegments);
            segmentCounter = 1;
            
            for i = 1 : length(segments)
                if isValidLabel(i)
                    segment = segments(i);
                    segment.label = labels(i);
                    labeledSegments(segmentCounter) = segment;
                    segmentCounter = segmentCounter + 1;
                end
            end
        end
        
        function labeledEvents = LabelEventsWithValidLabels(events,labels)
            isValidLabel = ~Labeling.ShouldIgnoreLabels(labels);
            
            nValidEvents = sum(isValidLabel);
            labeledEvents = repmat(Event,1,nValidEvents);
            eventCounter = 1;
            for i = 1 : length(events)
                if isValidLabel(i)
                    event = events(i);
                    event.label = labels(i);
                    labeledEvents(eventCounter) = event;
                    eventCounter = eventCounter + 1;
                end
            end
        end
        
        function segments = CreateSegmentsWithEventLocations(eventLocations,dataFile,segmentSizeLeft,segmentSizeRigh)
            
            events = Helper.CreateEventsWithEventLocations(eventLocations);
            
            segments = Helper.CreateSegmentsWithEvents(events,dataFile,segmentSizeLeft,segmentSizeRigh);
        end
        
        function events = CreateEventsWithEventLocations(eventLocations)
            nEvents = length(eventLocations);
            events = repmat(Event,1,nEvents);
            
            for i = 1 : nEvents
                eventLocation = eventLocations(i);
                events(i) = Event(eventLocation,[]);
            end
        end
        
        function segments = CreateSegmentsWithEvents(events,dataFile,segmentSizeLeft,segmentSizeRight)
            
            nSamples = dataFile.numRows;
            nSegments = Helper.CountNumValidSegments(events,segmentSizeLeft,segmentSizeRight,nSamples);
            segments = repmat(Segment,1,nSegments);
            segmentsCounter = 0;
            
            for i = 1 : length(events)
                eventLocation = events(i).sample;
                startSample = int32(eventLocation) - int32(segmentSizeLeft);
                endSample = int32(eventLocation) + int32(segmentSizeRight);
                
                if startSample > 0 && endSample <= nSamples
                    segment = Segment(dataFile.fileName,...
                        dataFile.data(startSample : endSample,:),...
                        [], eventLocation);

                    segment.startSample = uint32(startSample);
                    segment.endSample = uint32(endSample);

                    segmentsCounter = segmentsCounter + 1;
                    segments(segmentsCounter) = segment;
                end
            end
        end
        
        function numValidSegments = CountNumValidSegments(events,segmentSizeLeft,segmentSizeRight,nSamples)
            numValidSegments = 0;
            for i = 1 : length(events)
                eventLocation = events(i).sample;
                startSample = int32(eventLocation) - int32(segmentSizeLeft);
                endSample = int32(eventLocation) + int32(segmentSizeRight);
                if startSample > 0 && endSample <= nSamples
                    numValidSegments = numValidSegments + 1;
                end
            end
        end
        
        function value = ClampValueToRange(value, rangeStart, rangeEnd)
            if value < rangeStart
                value = rangeStart;
            elseif value > rangeEnd
                value = rangeEnd;
            end
        end
        
        function PlotAlgorithmGraph(algorithm)
            
            algorithmGraph = AlgorithmGraph.CreateGraph(algorithm);
            nEdges = length(algorithmGraph.edges);
            graph = digraph([algorithmGraph.edges.source],[algorithmGraph.edges.target],ones(1,nEdges),algorithmGraph.nodeNames);
            plotHandle = plot(graph,'NodeFontSize',20,'LineWidth',3,'MarkerSize',10,'NodeColor','red','ArrowSize',15,'ArrowPosition',1);
            layout(plotHandle,'layered','Direction','right');
        end
        
        function PrintAlgorithmChain(algorithm)
            stack = Stack();
            stack.push({algorithm,0});
            
            while(~stack.isempty())
                algorithmAndSpaces = stack.pop();
                algorithm = algorithmAndSpaces{1};
                nSpaces = algorithmAndSpaces{2};
                fprintf('%s%s\n',repmat(' ',1,nSpaces),algorithm.toString());
                nSpaces = nSpaces+1;
                for i = 1 : length(algorithm.nextAlgorithms)
                    stack.push({algorithm.nextAlgorithms{i},nSpaces});
                end
            end
        end
        
        function str = getOnOffStringLowerCase(isOn)
            str = 'off';
            if(isOn)
                str = 'on';
            end
        end
        
        function str = getOnOffString(isOn)
            str = 'Off';
            if(isOn)
                str = 'On';
            end
        end
        
        function idx = findStringInCellArray(strings,string)
            idx = find(contains(strings,string));
        end
        
        function n = nElementsInCellArray(cellArray)
            n = 0;
            for i = 1 : length(cellArray)
                n = n + length(cellArray{i});
            end
        end
        
        function table = eliminateRowsWithLabel(table,label)
            
            isNullIdx = (table.label == label);
            tableArray = table2array(table);
            tableArray = tableArray(~isNullIdx,:);
            tableVariables = table.Properties.VariableNames;
            table = array2table(tableArray);
            table.Properties.VariableNames = tableVariables;
        end
        
        function missingPoints = findMissingPoints(data)
            ts = unique(data(:,1));
            
            nMissingPoints = Helper.countMissingPoints(ts);
            missingPoints = zeros(1,nMissingPoints);
            
            previousTimestamp = uint32(ts(1));
            
            missingTimestampCount = 0;
            for i = 2 : length(ts)
                currentTimestamp = uint32(ts(i));
                
                shouldAddPoints = uint32(currentTimestamp - previousTimestamp)/10 - 1;
                addedPoints = 0;
                for missingTimestamp = previousTimestamp + 10 : 10 : currentTimestamp - 10
                    missingTimestampCount = missingTimestampCount + 1;
                    addedPoints = addedPoints + 1;
                    missingPoints(missingTimestampCount) = missingTimestamp;
                end
                if shouldAddPoints ~= addedPoints
                    fprintf('mismatch: %d %d',shouldAddPoints,addedPoints);
                end
                previousTimestamp = currentTimestamp;
            end
        end
        
        function nMissingPoints = countMissingPoints(signal,tsInterval)
            
            nMissingPoints = 0;
            if length(signal) > 1
                lastTimestamp = uint32(signal(1));
                for i = 2 : length(signal)
                    currentTimestamp = uint32(signal(i));
                    tsDiff = uint32(currentTimestamp - lastTimestamp);
                    if tsDiff ~= tsInterval
                        nMissingPoints = nMissingPoints + 1;
                    end
                    lastTimestamp = currentTimestamp;
                end
            end
        end
        
        %segments and points should be sorted
        function contained = isPointContainedInSegments(point,segmentStartings,segmentEndings)
            contained = false;
            for i = 1 : length(segmentStartings)
                segmentStarting = segmentStartings(i);
                segmentEnding = segmentEndings(i);
                if Helper.isPointContainedInSegment(point,segmentStarting,segmentEnding)
                    contained = true;
                end
                if point < segmentStarting
                    break;
                end
            end
        end
        
        function annotationsContained = findAnnotationIdxsContainedInSegment(segmentStarting, segmentEnding, manualAnnotationLocations)
            
            annotationsContained = [];
            
            for i = 1 : length(manualAnnotationLocations)
                
                annotationLocation = manualAnnotationLocations(i);
                
                if Helper.isPointContainedInSegment(annotationLocation,segmentStarting, segmentEnding)
                    annotationsContained = [annotationsContained i];
                end
                
                if annotationLocation > segmentEnding
                    break;
                end
            end
        end
        
        function [result] = isPointContainedInSegment(point, segmentStarting, segmentEnding)
            result = (point <= segmentEnding && point >= segmentStarting);
        end
        
        function [b,c] = findInSorted(x,range)
            A=range(1);
            B=range(end);
            a=1;
            b=numel(x);
            c=1;
            d=numel(x);
            if A<=x(1)
                b=a;
            end
            if B>=x(end)
                c=d;
            end
            while (a+1<b)
                lw=(floor((a+b)/2));
                if (x(lw)<A)
                    a=lw;
                else
                    b=lw;
                end
            end
            while (c+1<d)
                lw=(floor((c+d)/2));
                if (x(lw)<=B)
                    c=lw;
                else
                    d=lw;
                end
            end
        end
        
        %count how many segments include the annotation
        function numSegments = countSegmentsContainingAnnotation(segmentStartings,segmentEndings, annotation)
            numSegments = 0;
            
            for currentSegment = 1 : length(segmentStartings)
                segmentStarting = segmentStartings(currentSegment);
                segmentEnding = segmentEndings(currentSegment);
                
                if segmentStarting > annotation
                    break;
                end
                if Helper.isPointContainedInSegment(annotation,segmentStarting, segmentEnding)
                    numSegments = numSegments + 1;
                end
            end
        end
        
        function text = generateAnnotationDetectorNames(annotationDetectors)
            numAnnotationDetectors = length(annotationDetectors);
            text = annotationDetectors{1}.type;
            for i = 2 : numAnnotationDetectors
                annotationDetector = annotationDetectors{i};
                text = sprintf('%s\n%s',text,annotationDetector.type);
            end
        end 
        
        function stringArray = AlgorithmsToStringsArray(algorithms)
            numAlgorithms = length(algorithms);
            stringArray = cell(1,numAlgorithms);
            for i = 1 : numAlgorithms
                stringArray{i} = algorithms{i}.toString();
            end
        end
        
        function names = generateAlgorithmNamesArray(algorithms)
            numAlgorithms = length(algorithms);
            names = cell(1,numAlgorithms);
            for i = 1 : numAlgorithms
                names{i} = algorithms{i}.name;
            end
        end
        
        function visibleStr = GetVisibleStr(visible)
            visibleStr = 'off';
            if visible
                visibleStr = 'on';
            end
        end        
    end
end