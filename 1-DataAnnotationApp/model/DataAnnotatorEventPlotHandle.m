classdef DataAnnotatorEventPlotHandle < handle
    properties
        annotation;
        sampleSymbolUI;
        textSymbolUI;
    end
    
    methods
        function obj = DataAnnotatorEventPlotHandle(annotation, sampleSymbolUI, textSymbolUI)
            obj.annotation = annotation;
            obj.sampleSymbolUI = sampleSymbolUI;
            obj.textSymbolUI = textSymbolUI;
        end
    end
end