%this class retrieves an event detector algorithm from the UI
classdef GroupingConfigurator < handle
    
    properties (Access = public)
        labelingStrategies;
    end
    
    properties (Access = private)
        labelingStrategiesList;
        selectedLabelsTable;
    end
    
    methods (Access = public)
        
        function obj = GroupingConfigurator(labelingStrategies,labelingStrategiesList,selectedLabelsTable)
            obj.labelingStrategiesList = labelingStrategiesList;
            obj.labelingStrategies = labelingStrategies;
            if nargin > 2
                obj.selectedLabelsTable = selectedLabelsTable;
            end
            
            if ~isempty(labelingStrategies)
                obj.fillLabelingStrategiesList();
                
                obj.labelingStrategiesList.Value = obj.labelingStrategiesList.Items{1};
                
                if ~isempty(obj.selectedLabelsTable)
                    obj.fillGroupingTable();
                    obj.labelingStrategiesList.ValueChangedFcn = @obj.handleSelectedLabelingStrategyChanged;
                end
            end
        end
        
        function labelingStrategy = getCurrentLabelingStrategy(obj)
            labelingStrategyIdx = obj.getSelectedLabelingIdx();
            labelingStrategy = obj.labelingStrategies(labelingStrategyIdx);
        end
        
        %returns a logical array
        function labels = getSelectedLabels(obj)
            labels = obj.selectedLabelsTable.Data{:,2};
        end
    end
    
    methods (Access = private)
        
        function handleSelectedLabelingStrategyChanged(obj,~,~)
            obj.fillGroupingTable();
        end
        
        function idx = getSelectedLabelingIdx(obj)
            idxStr = obj.labelingStrategiesList.Value;
            [~,idx] = ismember(idxStr,obj.labelingStrategiesList.Items);
        end
        
        function fillLabelingStrategiesList(obj)
            nLabelingStrategies = length(obj.labelingStrategies);
            labelingStrategyNames = cell(1,nLabelingStrategies);
            for i = 1 : nLabelingStrategies
                labelingStrategy = obj.labelingStrategies(i);
                labelingStrategyNames{i} = labelingStrategy.name;
            end
            obj.labelingStrategiesList.Items = labelingStrategyNames;
        end
        
        function fillGroupingTable(obj)
            labelingStrategy = obj.getCurrentLabelingStrategy();
            nRows = labelingStrategy.numClasses;
            selected = true(nRows,1);
            obj.selectedLabelsTable.Data = table(labelingStrategy.classNames',selected);
        end
    end
end