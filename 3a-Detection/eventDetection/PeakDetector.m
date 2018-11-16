%each peak finder approach should return an array of peaks
classdef (Abstract) PeakDetector < handle
    properties
        type;
    end
    
    methods (Abstract)
        peakLocations = detectPeaks(obj,data);
        [] = resetVariables(obj);
        str = toString(obj);
    end
    methods
        function editableProperties = getEditableProperties(~)
            editableProperties = [];
        end
    end
end