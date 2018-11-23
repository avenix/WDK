classdef AnnotationsLoader < handle
    
    properties
        classesMap;
    end
    
    methods (Access = public)
        function obj = AnnotationsLoader()
            obj.classesMap = ClassesMap.instance();
        end
        
        function annotationSet = loadAnnotations(obj, fileName)
            annotationSet = obj.parseAnnotationsFile(fileName);
        end
        
        function saveAnnotations(obj,annotationSet,fileName)
               
            fileID = fopen(fileName,'w');
            obj.writeEventAnnotationsToFile(fileID,annotationSet.eventAnnotations);
            if ~isempty(annotationSet.eventAnnotations) && ~isempty(annotationSet.eventAnnotations)
                 fprintf(fileID, '\n');
            end
            obj.writeRangeAnnotationsToFile(fileID,annotationSet.rangeAnnotations);
            fclose(fileID);
        end
    end
    
    methods (Access = private)
         
        function annotationSet = parseAnnotationsFile(obj,fileName)
            
            delimiter = ',';
            startRow = 1;
            endRow = inf;
            
            formatSpec = '%s%s%[^\n\r]';
            
            [fileID,~] = fopen(fileName);
            if (fileID < 0)
                fprintf('file not found: %s\n',fileName);
                annotationSet = [];
            else
                
                dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', delimiter, 'HeaderLines', startRow(1)-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
                fclose(fileID);
                
                [nEvents, nRanges] = obj.countNumberAnnotations(dataArray);
                eventAnnotations = obj.parseEvents(dataArray,nEvents);
                rangeAnnotations = obj.parseRanges(dataArray,nRanges);
                
                if ~isempty(eventAnnotations)
                    [~, sortedIdxs] = sort([eventAnnotations.sample]);
                    eventAnnotations = eventAnnotations(sortedIdxs);
                end
                
                annotationSet = AnnotationSet(eventAnnotations,rangeAnnotations);
            end
        end
        
        function [nEvents, nRanges] = countNumberAnnotations(~,dataArray)
            nRanges = 0;
            
            tsStrings = dataArray{1};
            nRows = length(tsStrings);
            for i = 1 : nRows
                tsString = tsStrings{i};
                if contains(tsString,'-')
                    nRanges = nRanges + 1;
                end
            end
            nEvents = nRows - nRanges;
        end
        
        function rangeAnnotations = parseRanges(obj,dataArray,nRanges)
            rangeAnnotations = repmat(RangeAnnotation,1,nRanges);
            
            tsStrings = dataArray{1};
            classStrings = dataArray{2};
            
            rangeCounter = 1;
            for i = 1 : length(tsStrings)
                tsString = tsStrings{i};
                
                if contains(tsString,'-')
                    hypenationIdx = strfind(tsString,'-');
                    
                    startSampleStr = tsString(1:hypenationIdx-1);
                    endSampleStr = tsString(hypenationIdx+1:end);
                    startSample = uint32(str2double(startSampleStr));
                    endSample = uint32(str2double(endSampleStr));
                    
                    classString = classStrings{i};
                    
                    if obj.classesMap.isValidLabel(classString)
                        label = obj.classesMap.idxOfClassWithString(classString);
                        rangeAnnotations(rangeCounter) = RangeAnnotation(startSample,endSample,label);
                        rangeCounter = rangeCounter + 1;
                    else
                        fprintf('%s: %s\n',Constants.kInvalidAnnotationClassError,classString);
                        rangeAnnotations = [];
                        break;
                    end
                end
            end
            
        end
        
        function eventAnnotations = parseEvents(obj,dataArray,nEvents)
            eventAnnotations = repmat(EventAnnotation,1,nEvents);
            
            tsStrings = dataArray{1};
            classStrings = dataArray{2};
            
            eventCounter = 1;
            for i = 1 : length(tsStrings)
                tsString = tsStrings{i};
                
                if ~contains(tsString,'-')
                    ts = uint32(str2double(tsString));
                    classString = classStrings{i};
                    
                    if ts == 0
                        disp(ts);
                    end
                    
                    if obj.classesMap.isValidLabel(classString)
                        class = obj.classesMap.idxOfClassWithString(classString);
                        eventAnnotations(eventCounter) = EventAnnotation(ts,class);
                        eventCounter = eventCounter + 1;
                    else
                        fprintf('%s: %s\n',Constants.kInvalidAnnotationClassError,classString);
                        eventAnnotations = [];
                        break;
                    end
                end
            end
        end
        
        function writeEventAnnotationsToFile(obj, fileID, eventAnnotations)
            if ~isempty(eventAnnotations)
                for i = 1 : length(eventAnnotations)-1
                    annotation = eventAnnotations(i);
                    obj.writeEventAnnotationToFile(fileID,annotation);
                    fprintf(fileID, '\n');
                end
                annotation = eventAnnotations(end);
                obj.writeEventAnnotationToFile(fileID,annotation);
            end
        end
        
        function writeEventAnnotationToFile(obj,fileID, annotation)
            labelString = obj.classesMap.stringForClassAtIdx(annotation.label);
            fprintf(fileID, '%d, %s',annotation.sample,labelString);
        end
        
        
        function writeRangeAnnotationsToFile(obj, fileID, rangeAnnotations)
            if ~isempty(rangeAnnotations)
                for i = 1 : length(rangeAnnotations)-1
                    annotation = rangeAnnotations(i);
                    obj.writeRangeAnnotationToFile(fileID,annotation);
                    fprintf(fileID, '\n');
                end
                annotation = rangeAnnotations(end);
                obj.writeRangeAnnotationToFile(fileID,annotation);
            end
        end
        
        function writeRangeAnnotationToFile(obj, fileID, annotation)
            labelString = obj.classesMap.stringForClassAtIdx(annotation.label);
            fprintf(fileID, '%d - %d, %s',annotation.startSample, annotation.endSample, labelString);
        end
        
    end
end
