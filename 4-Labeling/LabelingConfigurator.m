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
            groupStrategiesCellArray = Helper.listLabelingStrategies();
            obj.labelingStrategiesList.String = Helper.cellArrayToString(groupStrategiesCellArray);
        end
    end
end