classdef RangeSegmentsLabeler < Computer
    
    properties (Access = public)
        shouldContainEntireSegment = true;
    end
    
    methods (Access = public)
        
        function obj = RangeSegmentsLabeler()
            obj.name = 'rangeSegmentsLabeler';
            obj.inputPort = ComputerPort(ComputerPortType.kSegment);
            obj.outputPort = ComputerPort(ComputerPortType.kSegment);
        end
        
        function labeledSegments = compute(obj,segments)
            manualAnnotations = Computer.GetSharedContextVariable(Constants.kSharedVariableCurrentAnnotationFile);
            
            if obj.shouldContainEntireSegment
                labels = obj.labelsOfSegmentsContainedInRanges(segments,manualAnnotations);
            else
                labels = obj.labelsOfSegmentMiddlePointsContainedInRanges(segments,manualAnnotations);
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
                                label = ClassesMap.kInvalidClass;%segment spans multiple annotations
                            end
                        end
                    end
                end
                if isempty(label)
                    labels(i) = ClassesMap.kNullClass;
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
                midPoint = segment.startSample + segment.endSample / 2;
                idx = annotationSet.findRangeAnnotationIdxContainingSample(midPoint);
                if idx > 0
                    rangeAnnotation = annotationSet.rangeAnnotations(idx);
                    labels(i) = rangeAnnotation.label;
                else
                    labels(i) = ClassesMap.kNullClass;
                end
            end
        end
    end
end