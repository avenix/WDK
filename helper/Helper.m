%offers static methods used throughout the toolkit
classdef Helper < handle
    methods (Access = public, Static)
        
        %% Listing data files
        function files = ListFilesInDirectory(directory,extensions)
            nExtensions = length(extensions);
            filesCount = 0;
            nFiles = Helper.NumberOfFilesInDirectory(directory,extensions);
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
        
        function nFiles = NumberOfFilesInDirectory(directory,extensions)
            nFiles = 0;
            
            nExtensions = length(extensions);
            for i = 1 : nExtensions
                extension = extensions{i};
                filesStructs = dir(fullfile(directory, extension));
                nFiles = nFiles + length(filesStructs);
            end
        end
        
        function files = ListARChainFiles()
            files = Helper.ListFilesInDirectory(Constants.kARChainsPath, {'*.mat'});
        end
        
        function files = ListLabelGroupings()
            files = Helper.ListFilesInDirectory(Constants.kLabelGroupingsPath, {'*.txt'});
        end
        
        function files = ListDataFiles(extensions)
            if (nargin == 0)
                extensions = {'*.mat','*.txt'};
            end
            
            files = Helper.ListFilesInDirectory(Constants.kDataPath, extensions);
        end
        
        function files = ListAnnotationFiles()
            files = Helper.ListFilesInDirectory(Constants.kAnnotationsPath, {'*.txt'});
        end
        
        function files = listSynchronizationFileNames()
            files = Helper.ListFilesInDirectory(Constants.kVideosPath, {'*.txt'});
        end
        
        function files = ListVideoFiles()
            files = Helper.ListFilesInDirectory(Constants.kVideosPath, {'*.mov','*.MP4','*.avi'});
        end
        
        %% Generating file names
        function fileName = AddSynchronizationFileExtension(fileName)
            fileName = sprintf('%s-synchronization.txt',fileName);
        end
        
        function fileName = AddVideoFileExtension(fileName)
            fileName = sprintf('%s-video',fileName);
        end
        
        function fileName = AddAnnotationsFileExtension(fileName)
            fileName = sprintf('%s-annotations.txt',fileName);
        end
        
        function fileName = AddMarkersFileExtension(fileName)
            fileName = sprintf('%s-markers.edl',fileName);
        end
        
        function fileNames = AddAnnotationsFileExtensionForFiles(fileNames)
            fileNames = cellfun(@(fileName) Helper.AddAnnotationsFileExtension(fileName),fileNames,'UniformOutput',false);
        end
        
        %% Manipulating file names
        function fileExtension = GetFileExtension(fileName)
            n = length(fileName);
            extensionSeparator = n - strfind(flip(fileName),'.') + 1;
            fileExtension = fileName(extensionSeparator:end);
        end
        
        function fileName = RemoveFileExtension(dataFileName)
            n = length(dataFileName);
            periodIdx = strfind(flip(dataFileName),'.');
            if isempty(periodIdx)
                fileName = dataFileName;
            else
                fileName = dataFileName(1:n-periodIdx(1));
            end
        end
        
        function fileNames = RemoveFileExtensionForFiles(dataFileNames)
            fileNames = cellfun(@Helper.RemoveFileExtension,dataFileNames,'UniformOutput',false);
        end
        
        function fileName = RemoveAnnotationsExtension(fileName)
            idx = strfind(fileName,'-annotations');
            fileName = fileName(1:idx-1);
        end
        
        function fileName = RemoveVideoExtension(fileName)
            idx = strfind(fileName,'-video');
            fileName = fileName(1:idx-1);
        end
        
        function fileNames = RemoveVideoExtensionForFiles(dataFileNames)
            fileNames = cellfun(@Helper.RemoveVideoExtension,dataFileNames,'UniformOutput',false);
        end
        
        function fileNames = RemoveDataFileExtensionForFiles(dataFileNames)
            
            nFiles = length(dataFileNames);
            fileNames = cell(nFiles,1);
            for fileIdx = 1 : nFiles
                dataFileName = dataFileNames{fileIdx};
                fileNameNoExtension = Helper.RemoveFileExtension(dataFileName);
                fileNames{fileIdx} = fileNameNoExtension;
            end
        end
        
        %% Conversion methods
        %generates a 2D cell array from a property array to be used within
        %a table view
        function cellArray = PropertyArrayToCellArray(propertyArray)
            numProperties = length(propertyArray);
            cellArray = cell(numProperties,2);
            for i = 1 : numProperties
                property = propertyArray(i);
                cellArray{i,1} = property.name;
                cellArray{i,2} = property.value;
            end
        end
        
        %concatenates the string representation of every element in a cell
        %array and returns the concatenated string
        function str = CellArrayToString(cellArray,separator)
            if isempty(cellArray)
                str = "";
            else
                
                if nargin == 1
                    separator = '\n';
                end
                str = cellArray{1};
                nCells = length(cellArray);
                for i = 2 : nCells
                    cellStr = cellArray{i};
                    str = sprintf('%s%c%s',str,separator,cellStr);
                end
            end
        end
        
        %TODO convert to cell array and reuse above function
        %concatenates the string representation of every element in an
        %array and returns the concatenated string
        function str = ArrayToString(array,separator)
            if isempty(array)
                str = "";
            else
                if nargin == 1
                    separator = '\n';
                end
                n = length(array);
                str = num2str(array(1));
                for i = 2 : n
                    numStr = num2str(array(i));
                    str = sprintf('%s%c%s',str,separator,numStr);
                end
            end
        end
        
        %% Generate strings
        function stringArray = AlgorithmsToStringsArray(algorithms)
            numAlgorithms = length(algorithms);
            stringArray = cell(1,numAlgorithms);
            for i = 1 : numAlgorithms
                stringArray{i} = algorithms{i}.toString();
            end
        end
        
        function names = GenerateAlgorithmNamesArray(algorithms)
            numAlgorithms = length(algorithms);
            names = cell(1,numAlgorithms);
            for i = 1 : numAlgorithms
                names{i} = algorithms{i}.name;
            end
        end
        
        %% Error printing
        function PrintWrongDataTypeError(receivedType,expectedType,currentObject)
            fprintf('%s. Received: %s. Expected: %s. In Algorithm: %s\n',...
                Constants.kInvalidInputError,receivedType,expectedType,currentObject);
        end
        
        %% Metrics computation
        function totalSize = ComputeObjectSize(obj)
            props = properties(obj);
            totalSize = 0;
            
            for i = 1:length(props)
                currentProperty = getfield(obj, char(props(i)));
                s = whos('currentProperty');
                totalSize = totalSize + s.bytes;
            end
        end
        
        %% Labeling
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
        
        %% Plotting
        % plots an algorithm graph
        function PlotAlgorithmGraph(algorithm)
            
            algorithmGraph = AlgorithmGraph.CreateGraph(algorithm);
            nEdges = length(algorithmGraph.edges);
            graph = digraph([algorithmGraph.edges.source],[algorithmGraph.edges.target],ones(1,nEdges),algorithmGraph.nodeNames);
            plotHandle = plot(graph,'NodeFontSize',20,'LineWidth',3,'MarkerSize',10,'NodeColor','red','ArrowSize',15,'ArrowPosition',1);
            layout(plotHandle,'layered','Direction','right');
        end
        
        %prints the description method of every algorithm in a graph
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
        
        %% UI
        function str = GetOnOffStringLowerCase(isOn)
            str = 'off';
            if(isOn)
                str = 'on';
            end
        end
        
        function str = GetOnOffString(isOn)
            str = 'off';
            if(isOn)
                str = 'On';
            end
        end
        
        %% Other
        function b = IsPowerOf2(x)
            b = (bitand(x, x - 1) == 0);
        end
    end
end