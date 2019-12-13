classdef AnnotationsSuggester < handle
    
    properties (Access = public, Constant)
        kMaxNumberAnnotationSuggestions = 4000;
    end
    
    properties (Access = public)
        dtwWindowSize = 10;
        desiredNumberAnnotationSuggestions = 20;
        maxRangeSamples = 400;
        selectedSignals = 1:6;
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
                suggestedAnnotations = obj.suggestAnnotationsWithRangeAndDataFile(rangeAnnotation,dataFile);
            end
        end
    end
    
    methods (Access = private)
        
        function suggestedAnnotations = suggestAnnotationsWithRangeAndDataFile(obj,rangeAnnotation,dataFile)
            
            template = dataFile.rawDataForRowsAndColumns(rangeAnnotation.startSample,rangeAnnotation.endSample,obj.selectedSignals);
                      
            suggestedAnnotations = repmat(RangeAnnotation,obj.kMaxNumberAnnotationSuggestions,1);
            suggestedDistances = Inf(1,obj.kMaxNumberAnnotationSuggestions);
            
            numSamples = dataFile.numRows;
            
            suggestedAnnotationsCount = 1;
                        
            annotationSize = rangeAnnotation.nSamples;
            
            for i = rangeAnnotation.endSample : annotationSize : numSamples - annotationSize
                
                segment = dataFile.rawDataForRowsAndColumns(i,i + annotationSize,obj.selectedSignals);
                
                %run dynamic time warping
                distance = dtw(template,segment,obj.dtwWindowSize) / numSamples;
                
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
       
    end
end