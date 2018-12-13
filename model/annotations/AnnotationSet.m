classdef AnnotationSet < handle
   properties (Access = public)
       eventAnnotations;
       rangeAnnotations;
       file;
   end
   
   methods (Access = public)
       function obj = AnnotationSet(eventAnnotations,rangeAnnotations)
           if nargin >= 1
               obj.eventAnnotations = eventAnnotations;
               if nargin > 1
                   obj.rangeAnnotations = rangeAnnotations;
               end
           end
       end
   end
end