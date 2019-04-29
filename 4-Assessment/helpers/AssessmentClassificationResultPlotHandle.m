classdef AssessmentClassificationResultPlotHandle < handle
    properties (Access = public)
        rectangleHandle;
        textHandle;
        symbolHandle;
    end
    
    methods (Access = public)
        function obj = AssessmentClassificationResultPlotHandle(rectangleHandle,textHandle,symbolHandle)
            if nargin > 0
                obj.rectangleHandle = rectangleHandle;
                if nargin > 1
                    obj.textHandle = textHandle;
                    if nargin > 2
                        obj.symbolHandle = symbolHandle;
                    end
                end
            end
        end
    end
end