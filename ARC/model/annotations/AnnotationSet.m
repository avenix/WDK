classdef AnnotationSet < handle
   properties (Access = public)
       eventAnnotations;
       rangeAnnotations;
       fileName;
   end
   
   methods (Access = public)
       function obj = AnnotationSet(eventAnnotations,rangeAnnotations)
           if nargin > 0
               obj.eventAnnotations = eventAnnotations;
               if nargin > 1
                   obj.rangeAnnotations = rangeAnnotations;
               end
           end
       end
       
       function idx = findRangeAnnotationIdxContainingSample(obj,sample)
           idx = obj.binarySearchRangeAnnotationIdxContainingSample(sample,1,length(obj.rangeAnnotations));
       end
   end
   
   methods (Access = private)
       function idx = binarySearchRangeAnnotationIdxContainingSample(obj,sample,idx1,idx2)
           if idx1 > idx2
               idx = -1;
           else
               midIdx = floor((idx1 + idx2) / 2);
               midRangeAnnotation = obj.rangeAnnotations(midIdx);

               if sample >= midRangeAnnotation.startSample && sample <= midRangeAnnotation.endSample
                   idx = midIdx;
               else
                   if sample < midRangeAnnotation.startSample
                       idx = obj.binarySearchRangeAnnotationIdxContainingSample(sample,idx1,midIdx-1);
                   else
                       idx = obj.binarySearchRangeAnnotationIdxContainingSample(sample,midIdx+1,idx2);
                   end
               end
           end
       end
   end
   
   methods (Static)
       function copyAnnotationSet = CopyAnnotationSet(annotationSet)
           copyAnnotationSet = AnnotationSet(annotationSet.eventAnnotations,annotationSet.rangeAnnotations);
           copyAnnotationSet.fileName = annotationSet.fileName;
       end
   end
   
end