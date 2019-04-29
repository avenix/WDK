%this class retrieves an event detector algorithm from the UI
classdef GroupingConfigurator < handle
    
    properties (Access = public)
        labelGroupings;
        delegate = [];
    end
    
    properties (Access = private)
        labelGroupingsList;
        selectedLabelsTable;
    end
    
    methods (Access = public)
        
        function obj = GroupingConfigurator(labelGroupings,labelGroupingsList,selectedLabelsTable,delegate)
            obj.labelGroupingsList = labelGroupingsList;
            obj.labelGroupings = labelGroupings;
            if nargin > 2
                obj.selectedLabelsTable = selectedLabelsTable;
            end
            
            if nargin > 3
                obj.delegate = delegate;
            end
            
            if ~isempty(labelGroupings)
                obj.fillLabelGroupingsList();
                
                obj.labelGroupingsList.Value = obj.labelGroupingsList.Items{1};
                
                if ~isempty(obj.selectedLabelsTable)
                    obj.fillGroupingTable();
                    obj.labelGroupingsList.ValueChangedFcn = @obj.handleSelectedLabelGroupingChanged;
                end
            end
        end
        
        function labelGrouping = getCurrentLabelGrouping(obj)
            labelGroupingIdx = obj.getSelectedLabelingIdx();
            labelGrouping = obj.labelGroupings(labelGroupingIdx);
        end
        
        %returns a logical array
        function labels = getSelectedLabels(obj)
            labels = obj.selectedLabelsTable.Data{:,2};
        end
    end
    
    methods (Access = private)
        
        function handleSelectedLabelGroupingChanged(obj,~,~)
            obj.fillGroupingTable();
            if ~isempty(obj.delegate)
                labelGrouping = obj.getCurrentLabelGrouping();
                obj.delegate.handleSelectedLabelGroupingChanged(labelGrouping);
            end
        end
        
        function idx = getSelectedLabelingIdx(obj)
            idxStr = obj.labelGroupingsList.Value;
            [~,idx] = ismember(idxStr,obj.labelGroupingsList.Items);
        end
        
        function fillLabelGroupingsList(obj)
            nLabelGroupings = length(obj.labelGroupings);
            labelGroupingNames = cell(1,nLabelGroupings);
            for i = 1 : nLabelGroupings
                labelGrouping = obj.labelGroupings(i);
                labelGroupingNames{i} = labelGrouping.name;
            end
            obj.labelGroupingsList.Items = labelGroupingNames;
        end
        
        function fillGroupingTable(obj)
            labelGrouping = obj.getCurrentLabelGrouping();
            nRows = labelGrouping.numClasses;
            selected = true(nRows,1);
            obj.selectedLabelsTable.Data = table(labelGrouping.classNames',selected);
        end
    end
end