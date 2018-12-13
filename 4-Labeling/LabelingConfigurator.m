%this class retrieves an event detector algorithm from the UI
classdef LabelingConfigurator < handle
    
    properties (Access = public)
        labelingStrategies;
    end
    
    properties (Access = private)
        labelingStrategiesList;
    end
    
    methods (Access = public)
        
        function obj = LabelingConfigurator(labelingStrategiesList)
            obj.labelingStrategiesList = labelingStrategiesList;
            
            dataLoader = DataLoader();
            obj.labelingStrategies = dataLoader.loadAllLabelingStrategies();
            obj.fillLabelingStrategiesList();
        end
        
        function labelingStrategy = getCurrentLabelingStrategy(obj)
            labelingStrategyIdx = obj.getSelectedLabelingIdx();
            labelingStrategy = obj.labelingStrategies{labelingStrategyIdx};
        end
    end
    
    methods (Access = private)
        
        function idx = getSelectedLabelingIdx(obj)
            idx = obj.labelingStrategiesList.Value;
        end
        
        function fillLabelingStrategiesList(obj)
            nLabelingStrategies = length(obj.labelingStrategies);
            labelingStrategyNames = cell(1,nLabelingStrategies);
            for i = 1 : nLabelingStrategies
                labelingStrategy = obj.labelingStrategies{i};
                labelingStrategyNames{i} = labelingStrategy.name;
            end
            obj.labelingStrategiesList.String = Helper.cellArrayToString(labelingStrategyNames);
        end
    end
end