classdef AnnotationsSuggester < handle
    
    properties (Access = public, Constant)
        kMaxNumberAnnotationSuggestions = 1000;
    end
    
    properties (Access = public)
        similarityThreshold = 0.0002;
        dtwWindowSize = 10;
        desiredNumberAnnotationSuggestions = 20;
        maxRangeSamples = 400;
        selectedSignals = 1:6;
    end
    
    properties (Access = private)
        dataFile;
    end
    
    properties(Constant)
        kTooLargeRangeWarning = 'The provided range annotation is too large - AnnotationsSuggester\n';
    end
    
    methods (Access = public)
        
        function suggestedAnnotations = suggestAnnotationsWithRange(obj,rangeAnnotation,dataFile)
            if rangeAnnotation.nSamples > obj.maxRangeSamples
                fprintf(AnnotationsSuggester.kTooLargeRangeWarning);
                suggestedAnnotations = [];
            else
                obj.dataFile = dataFile;
                
                Algorithm.SetSharedContextVariable(Constants.kSharedVariableCurrentDataFile,dataFile);
                
                %segments = Algorithm.ExecuteChain(obj.segmentationAlgorithm,dataFile.data);
                
                suggestedAnnotations = obj.suggestAnnotationsWithRange2(rangeAnnotation);
                
                fprintf('found %d matches\n',length(suggestedAnnotations));
            end
        end
    end
    
    methods (Access = private)
        
        function suggestedAnnotations = suggestAnnotationsWithRange2(obj,rangeAnnotation)
            
            template = obj.dataFile.rawDataForRowsAndColumns(rangeAnnotation.startSample,rangeAnnotation.endSample,obj.selectedSignals);
                      
            suggestedAnnotations = repmat(RangeAnnotation,obj.kMaxNumberAnnotationSuggestions,1);
            suggestedDistances = zeros(1,obj.kMaxNumberAnnotationSuggestions);
            
            numSamples = obj.dataFile.numRows;
            
            suggestedAnnotationsCount = 1;
                        
            annotationSize = rangeAnnotation.nSamples;
            
            for i = rangeAnnotation.endSample : annotationSize : numSamples - annotationSize
                
                segment = obj.dataFile.rawDataForRowsAndColumns(i,i + annotationSize,obj.selectedSignals);
                
                %run dynamic time warping
                distance = dtw(template,segment,obj.dtwWindowSize) / numSamples;
                fprintf('dist: %.6f\n',distance);
                
                suggestedAnnotations(suggestedAnnotationsCount) = RangeAnnotation(i,i + annotationSize,rangeAnnotation.label);
                suggestedDistances(suggestedAnnotationsCount) = distance;
                
                suggestedAnnotationsCount = suggestedAnnotationsCount + 1;
                if suggestedAnnotationsCount > obj.kMaxNumberAnnotationSuggestions
                    break;
                end
            end
            
            if ~isempty(suggestedAnnotations)
                numAnnotations = min(obj.desiredNumberAnnotationSuggestions,suggestedAnnotationsCount-1);
                [~,idxs] = sort(suggestedDistances);
                idxs = idxs(1:numAnnotations);
                suggestedAnnotations = suggestedAnnotations(idxs);
            end
        end
        
        function suggestedAnnotations = suggestAnnotationsWithRangeAndSegments(obj,rangeAnnotation,segments)
            
            template = obj.dataFile.rawDataForRowsAndColumns(rangeAnnotation.startSample,rangeAnnotation.endSample,obj.selectedSignals);
                      
            suggestedAnnotations = repmat(RangeAnnotation,obj.maxAnnotationSuggestions,1);
            
            numSamples = obj.dataFile.numRows;
            
            suggestedAnnotationsCount = 1;

            nSegments = length(segments);
            
            fprintf('comparing %d segments...\n',nSegments);
            
            for i = 1 : nSegments
                
                segment = segments(i);
                
                if segment.startSample ~= rangeAnnotation.startSample
                    %run dynamic time warping
                    distance = dtw(template,segment.data(:,obj.selectedSignals),obj.dtwWindowSize) / numSamples;
                    fprintf('dist: %.6f\n',distance);
                    
                    if distance < obj.similarityThreshold
                        
                        suggestedAnnotations(suggestedAnnotationsCount) = RangeAnnotation(segment.startSample,segment.endSample,rangeAnnotation.label);
                        suggestedAnnotationsCount = suggestedAnnotationsCount + 1;
                        if suggestedAnnotationsCount > obj.maxAnnotationSuggestions
                            suggestedAnnotations = [];
                            break;
                        end
                    end
                end
            end
            
            if ~isempty(suggestedAnnotations)
                suggestedAnnotations = suggestedAnnotations(1:suggestedAnnotationsCount-1);
            end
        end
    end
end