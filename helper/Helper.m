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
        
        function files = listDataFiles(extensions)
            if (nargin == 0)
                extensions = {'*.mat'};
            end
            
            files = Helper.listFilesInDirectory(Constants.dataPath, extensions);
        end
        
        function files = listAnnotationFiles()
            files = Helper.listFilesInDirectory('./data/annotations', {'*.txt'});
        end
        
        function fileName = addAnnotationsFileExtension(fileName)
            fileName = sprintf('%s-annotations.txt',fileName);
        end
        
        function fileName = addMarkersFileExtension(fileName)
            fileName = sprintf('%s-markers.txt',fileName);
        end
        
        function fileName = addDataFileExtension(fileName)
            fileName = sprintf('%s-hand.txt',fileName);
        end
        
        
        function fileName = removeFileExtension(dataFileName)
            n = length(dataFileName);
            periodIdx = strfind(flip(dataFileName),'.');
            fileName = dataFileName(1:n-periodIdx(1));
        end
        
        function fileNames = removeDataFileExtensionForFiles(dataFileNames)

            nFiles = length(dataFileNames);
            fileNames = cell(nFiles,1);
            for fileIdx = 1 : nFiles
                dataFileName = dataFileNames{fileIdx};
                fileNameNoExtension = Helper.removeDataFileExtension(dataFileName);
                fileNames{fileIdx} = fileNameNoExtension;
            end
        end
        
        %% Data Management
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
        
        %% Helper methods
        function str = cellArrayToString(cellArray)
            if isempty(cellArray)
                str = "";
            else
                str = cellArray{1};
                nCells = length(cellArray);
                for i = 2 : nCells
                    columnName = cellArray{i};
                    str = sprintf('%s\n%s',str,columnName);
                end
            end
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
        
        function [b,c]=findInSorted(x,range)
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
        
        function text = convertToString(numbers)
            if isempty(numbers)
                text = "";
            else
                n = length(numbers);
                text = num2str(numbers(1));
                for i = 2 : n
                    numStr = num2str(numbers(i));
                    text = sprintf('%s\n%s',text,numStr);
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
        
        function str = generateSignalComputerNames(signalComputers)
            
            signalComputer = signalComputers(1);
            str = signalComputer.name;
            
            for i = 2 : length(signalComputers)
                signalComputer = signalComputers(i);
                signalName = signalComputer.name;
                str = sprintf('%s\n%s',str,signalName);
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
    end
end