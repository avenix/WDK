classdef AnnotationMarkersLoader < handle
    
    properties (Access = public)
        videoFrameRate = 23.976;
    end
        
    methods (Access = public)
        function markers = loadMarkers(obj, fileName)
            
            delimiter = {'\\n'};
            if nargin<=2
                startRow = 3;
                endRow = inf;
            end
            
            formatSpec = '%s%[^\n\r]';
            fileID = fopen(fileName,'r');
            
            if fileID == -1
                markers = [];
                fprintf('Markers file %s not found.\n',fileName);
                
            else
                textscan(fileID, '%[^\n\r]', startRow(1)-1, 'WhiteSpace', '', 'ReturnOnError', false);
                dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true, 'TextType', 'string', 'ReturnOnError', false, 'EndOfLine', '\r\n');
                for block=2:length(startRow)
                    frewind(fileID);
                    textscan(fileID, '%[^\n\r]', startRow(block)-1, 'WhiteSpace', '', 'ReturnOnError', false);
                    dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true, 'TextType', 'string', 'ReturnOnError', false, 'EndOfLine', '\r\n');
                    dataArray{1} = [dataArray{1};dataArrayBlock{1}];
                end
                
                fclose(fileID);
                
                raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
                for col=1:length(dataArray)-1
                    raw(1:length(dataArray{col}),col) = mat2cell(dataArray{col}, ones(length(dataArray{col}), 1));
                end
                
                nRows = floor(length(raw)/2);
                
                markers = repmat(AnnotationVideoMarker(),1,nRows);
                
                rowCounter = 1;
                for i = 1 : 2 : length(raw)
                    firstRow = string(raw(i, 1));
                    secondRow = string(raw(i+1, 1));
                    firstRowSplitted = strsplit(firstRow,' ');
                    separatorIndices = strfind(secondRow,'|');
                    text = extractBefore(secondRow,separatorIndices(1));
                    secondRow = extractAfter(secondRow,separatorIndices(1)+2);
                    secondRowSplitted = strsplit(secondRow,' ');
                    timeStampStr = firstRowSplitted{5};
                    markerTimeStamp = obj.timeStampStrToFrame(timeStampStr);
                    colorStr = secondRowSplitted{1};
                    markerLabel = obj.colorStrToEnum(colorStr);
                    
                    markers(rowCounter) = AnnotationVideoMarker(markerTimeStamp,markerLabel,text);
                    rowCounter = rowCounter + 1;
                end
            end
        end
    end
    methods (Access = private)
        function markerEnum = colorStrToEnum(~,colorStr)
            
            if strcmp(colorStr,'ResolveColorRed')
                markerEnum = 1;
            elseif strcmp(colorStr,'ResolveColorYellow')
                markerEnum = 2;
            elseif strcmp(colorStr,'ResolveColorGreen')
                markerEnum = Constants.kSynchronisatonMarker;
            elseif strcmp(colorStr,'ResolveColorBlue')
                markerEnum = 4;
            elseif strcmp(colorStr,'ResolveColorCyan')
                markerEnum = 5;
            elseif strcmp(colorStr,'ResolveColorPink')
                markerEnum = 6;
            elseif strcmp(colorStr,'ResolveColorPurple')
                markerEnum = 7;
            else
                markerEnum = 8;
            end
            
        end
        
        function frame = timeStampStrToFrame(obj, markerStr)
            hour = str2double(markerStr(1:2))-1;
            minute = str2double(markerStr(4:5));
            second = str2double(markerStr(7:8));
            frame = str2double(markerStr(10:11));
            
            frame = (hour * 3600 + minute * 60 + second + frame/obj.videoFrameRate);
        end
    end
    
end