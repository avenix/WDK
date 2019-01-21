%this class retrieves a preprocessing algorithm from the UI
classdef SegmentationConfigurator < handle

    properties (Access = private)
        %ui
        segmenationStrategiesList;
        segmenationVariablesTable;
        
        %state
        currentSegmentationStrategyVariables;
    end
    
    properties (Access = public)    
        %computers
        segmentationStrategies;
    end
    
    methods (Access = public)
        function obj = SegmentationConfigurator(segmentationStrategies, segmenationStrategiesList,segmenationVariablesTable)
            obj.segmentationStrategies = segmentationStrategies;
            obj.segmenationStrategiesList = segmenationStrategiesList;
            obj.segmenationVariablesTable = segmenationVariablesTable;
                        
            obj.reloadUI();
        end
        
        function reloadUI(obj)
            obj.fillSegmentationList();
            obj.updateSelectedSegmentationStrategy();
            obj.updateSegmentationStrategyVariablesTable();
        end
        
        function segmentationStrategy = createSegmentationStrategyWithUIParameters(obj)
            segmentationStrategy = obj.getCurrentSegmentationStrategy();
            
            data = obj.segmenationVariablesTable.Data;
            for i = 1 : size(data,1)
                variableName = data{i,1};
                variableValue = data{i,2};
                property = Property(variableName,variableValue);
                segmentationStrategy.setProperty(property);
            end
        end
    end
    
    methods(Access = private)
        
        function fillSegmentationList(obj)
            
            nSegmentationStrategies = length(obj.segmentationStrategies);
            segmentationStrategyNames = cell(1,nSegmentationStrategies);
        
            for i = 1 : nSegmentationStrategies
                name = obj.segmentationStrategies{i}.type;
                segmentationStrategyNames{i} = name;
            end
            
            obj.segmenationStrategiesList.String = Helper.cellArrayToString(segmentationStrategyNames);
        end

        function segmentationStrategy = getCurrentSegmentationStrategy(obj)
            idx = obj.segmenationStrategiesList.Value;
            segmentationStrategy = obj.segmentationStrategies{idx};
        end
        
        function updateSelectedSegmentationStrategy(obj)
            segmentationStrategy = obj.getCurrentSegmentationStrategy();
            obj.currentSegmentationStrategyVariables = segmentationStrategy.getEditableProperties();
        end
        
        function updateSegmentationStrategyVariablesTable(obj)
            obj.segmenationVariablesTable.Data = Helper.propertyArrayToCellArray(obj.currentSegmentationStrategyVariables);
        end
        
    end
end