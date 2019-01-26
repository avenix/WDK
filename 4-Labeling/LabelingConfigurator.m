%this class retrieves an event detector algorithm from the UI
classdef LabelingConfigurator < handle
    
    properties (Access = public)
        labelingStrategies;
    end
    
    properties (Access = private)
        labelingStrategiesList;
    end
    
    methods (Access = public)
        
        function obj = LabelingConfigurator(labelingStrategiesList, labelingStrategies)
            obj.labelingStrategiesList = labelingStrategiesList;
            obj.labelingStrategies = labelingStrategies;
            obj.fillLabelingStrategiesList();
            obj.labelingStrategiesList.Value = obj.labelingStrategiesList.Items{1};
        end
        
        function labelingStrategy = getCurrentLabelingStrategy(obj)
            labelingStrategyIdx = obj.getSelectedLabelingIdx();
            labelingStrategy = obj.labelingStrategies{labelingStrategyIdx};
        end
    end
    
    methods (Access = private)
        
        function idx = getSelectedLabelingIdx(obj)
            idxStr = obj.labelingStrategiesList.Value;
            [~,idx] = ismember(idxStr,obj.labelingStrategiesList.Items);
        end
        
        function fillLabelingStrategiesList(obj)
            nLabelingStrategies = length(obj.labelingStrategies);
            labelingStrategyNames = cell(1,nLabelingStrategies);
            for i = 1 : nLabelingStrategies
                labelingStrategy = obj.labelingStrategies{i};
                labelingStrategyNames{i} = labelingStrategy.name;
            end
            obj.labelingStrategiesList.Items = labelingStrategyNames;
        end
    end
end