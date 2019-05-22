classdef PostProcessingConfiguratorUIElements < handle
    properties (Access = public)
        computersList;
        computersPropertiesTable;
        annotationsPanel;
        annotationMappingList;
        annotationMappingTable;
    end
    
    methods (Access = public)
        function obj = PostProcessingConfiguratorUIElements(computersList,...
                computersPropertiesTable, annotationsPanel, annotationMappingList,...
            annotationMappingTable)
            obj.computersList = computersList;
            obj.annotationsPanel = annotationsPanel;
            obj.computersPropertiesTable = computersPropertiesTable;
            obj.annotationMappingList = annotationMappingList;
            obj.annotationMappingTable = annotationMappingTable;
        end
    end
end