classdef DataAnnotatorPeakPlotHandle < handle
    properties
        annotation;
        peakSymbolUI;
        textSymbolUI;
    end
    
    methods
        function obj = DataAnnotatorPeakPlotHandle(annotation, peakSymbolUI, textSymbolUI)
            obj.annotation = annotation;
            obj.peakSymbolUI = peakSymbolUI;
            obj.textSymbolUI = textSymbolUI;
        end
    end
end