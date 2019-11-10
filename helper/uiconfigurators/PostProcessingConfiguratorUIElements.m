classdef PostProcessingConfiguratorUIElements < handle
    properties (Access = public)
        algorithmsList;
        algorithmsPropertiesTable;
        annotationsPanel;
        annotationMappingList;
        annotationMappingTable;
    end
    
    methods (Access = public)
        function obj = PostProcessingConfiguratorUIElements(algorithmsList,...
                algorithmsPropertiesTable, annotationsPanel, annotationMappingList,...
            annotationMappingTable)
            obj.algorithmsList = algorithmsList;
            obj.annotationsPanel = annotationsPanel;
            obj.algorithmsPropertiesTable = algorithmsPropertiesTable;
            obj.annotationMappingList = annotationMappingList;
            obj.annotationMappingTable = annotationMappingTable;
        end
    end
end