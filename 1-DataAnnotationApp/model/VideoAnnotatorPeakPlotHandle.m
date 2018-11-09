classdef VideoAnnotatorPeakPlotHandle < handle
    properties
        annotation;
        peakSymbolUI;
        textSymbolUI;
    end
    
    methods
        function obj = VideoAnnotatorPeakPlotHandle(annotation, peakSymbolUI, textSymbolUI)
            obj.annotation = annotation;
            obj.peakSymbolUI = peakSymbolUI;
            obj.textSymbolUI = textSymbolUI;
        end
    end
end