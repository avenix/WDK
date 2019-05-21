%labels segments using the rangeAnnotations. If the
%shouldContainEntireSegment property is set, segments are labeled as the
%rangeAnnotation that fully contains them ir as NULL otherwise.
%if the shouldContainEntireSegment is not set, segments are labeled as the
%rangeAnnotation that contains the middle point of the segment.

classdef RangeSegmentsLabeler < Computer
    
    properties (Access = public)
        shouldContainEntireSegment = true;
        manualAnnotations;
    end
    
    methods (Access = public)
        
        function obj = RangeSegmentsLabeler(shouldContainEntireSegment)
            if nargin > 0
                obj.shouldContainEntireSegment = shouldContainEntireSegment;
            end
            
            obj.name = 'rangeSegmentsLabeler';
            obj.inputPort = ComputerDataType.kSegment;
            obj.outputPort = ComputerDataType.kSegment;
        end
        
        function labeledSegments = compute(obj,segments)
            
            if obj.shouldContainEntireSegment
                labels = obj.labelsOfSegmentsContainedInRanges(segments,obj.manualAnnotations);
            else
                labels = obj.labelsOfSegmentMiddlePointsContainedInRanges(segments,obj.manualAnnotations);
            end
            
            labeledSegments = Helper.LabelSegmentsWithValidLabels(segments,labels);
        end
        
        function str = toString(obj)
            str = sprintf('%s_%d',obj.name,obj.shouldContainEntireSegment);
        end

        function editableProperties = getEditableProperties(obj)
            editableProperties = Property('shouldContainEntireSegment',obj.shouldContainEntireSegment,false,true,PropertyType.kBoolean);
        end
    end
    
    methods (Access = private)
        
        function labels = labelsOfSegmentsContainedInRanges(~,segments,annotationSet)
            nSegments = length(segments);
            labels = zeros(1,nSegments);
            
            for i = 1 : nSegments
                segment = segments(i);
                
                idx1 = annotationSet.findRangeAnnotationIdxContainingSample(segment.startSample);
                label = [];
                if idx1 > 0
                    idx2 = annotationSet.findRangeAnnotationIdxContainingSample(segment.endSample);
                    if idx2 > 0
                        rangeAnnotation = annotationSet.rangeAnnotations(idx1);
                        if(idx1 == idx2)
                            label = rangeAnnotation.label;
                        else
                            rangeAnnotation2 = annotationSet.rangeAnnotations(idx2);
                            if rangeAnnotation.label == rangeAnnotation2.label
                                label = rangeAnnotation.label;
                            else
                                label = Labeling.kInvalidClass;%segment spans multiple annotations
                            end
                        end
                    end
                end
                if isempty(label)
                    labels(i) = Labeling.kNullClass;
                else
                    labels(i) = label;
                end
            end
        end
        
        function labels = labelsOfSegmentMiddlePointsContainedInRanges(~,segments,annotationSet)
            
            nSegments = length(segments);
            labels = zeros(1,nSegments);
            for i = 1 : nSegments
                segment = segments(i);
                midPoint = (segment.startSample + segment.endSample) / 2;
                idx = annotationSet.findRangeAnnotationIdxContainingSample(midPoint);
                if idx > 0
                    rangeAnnotation = annotationSet.rangeAnnotations(idx);
                    labels(i) = rangeAnnotation.label;
                else
                    labels(i) = Labeling.kNullClass;
                end
            end
        end
    end
end
