classdef VideoAnnotatorRangePlotHandle < handle
    properties
        annotation;
        startSegmentUI;
        endSegmentUI;
        horizontalSegmentUI;
        textSymbolUI;
    end
    
    methods
        function obj = VideoAnnotatorRangePlotHandle(annotation, startSegmentUI, endSegmentUI, horizontalSegmentUI, textSymbolUI)
            obj.annotation = annotation;
            obj.startSegmentUI = startSegmentUI;
            obj.endSegmentUI = endSegmentUI;
            obj.horizontalSegmentUI = horizontalSegmentUI;
            obj.textSymbolUI = textSymbolUI;
        end
    end
end