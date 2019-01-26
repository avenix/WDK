classdef DataAnnotationEventPlotHandle < handle
    properties
        annotation;
        sampleSymbolUI;
        textSymbolUI;
    end
    
    methods
        function obj = DataAnnotationEventPlotHandle(annotation, sampleSymbolUI, textSymbolUI)
            obj.annotation = annotation;
            obj.sampleSymbolUI = sampleSymbolUI;
            obj.textSymbolUI = textSymbolUI;
        end
    end
end