classdef AnnotationEventPlotHandle < handle
    properties (Access = public)
        annotation;
        sampleSymbolUI;
        textSymbolUI;
    end
    
    properties (Dependent)
        visible;
    end
    
    methods
        function set.visible(obj,visible)
            obj.sampleSymbolUI.Visible = visible;
            obj.textSymbolUI.Visible = visible;
        end
    end
    
    methods (Access = public)
        function obj = AnnotationEventPlotHandle(annotation, sampleSymbolUI, textSymbolUI)
            obj.annotation = annotation;
            obj.sampleSymbolUI = sampleSymbolUI;
            obj.textSymbolUI = textSymbolUI;
        end
    end
end