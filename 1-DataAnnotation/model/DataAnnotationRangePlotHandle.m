classdef DataAnnotationRangePlotHandle < handle
    properties
        annotation;
        rectangleUI;
        textSymbolUI;
    end
        
    properties (Dependent)
        visible;
    end
    
    methods
        function set.visible(obj,visible)
            obj.rectangleUI.Visible = visible;
            obj.textSymbolUI.Visible = visible;
        end
    end
    
    methods (Access = public)
        function obj = DataAnnotationRangePlotHandle(annotation, rectangleUI, textSymbolUI)
            obj.annotation = annotation;
            obj.rectangleUI = rectangleUI;
            obj.textSymbolUI = textSymbolUI;
        end
    end
end