%this class retrieves an event detector algorithm from the UI
classdef LabelMappingConfigurator < handle
    
    properties (Access = public)
        labelings;
        delegate = [];
    end
    
    properties (Access = private)
        labelingsList;
        labelMappingTable;
    end
    
    methods (Access = public)
        
        function obj = LabelMappingConfigurator(labelings,labelingsList,labelingsTable, delegate)
            obj.labelings = labelings;
            obj.labelingsList = labelingsList;
            obj.labelMappingTable = labelingsTable;
            
            if nargin > 3
                obj.delegate = delegate;
            end
            
            if ~isempty(labelings)
                obj.fillLabelMappingsList();
                
                obj.labelingsList.Value = obj.labelingsList.Items{1};
                obj.labelingsList.ValueChangedFcn = @obj.handleSelectedLabelMappingChanged;
                
                obj.updateMappingsTable();
            end
        end
        
        function setLabelings(obj,labelingsParameter)
            obj.labelings = labelingsParameter;
            if ~isempty(obj.labelings)
                obj.updateMappingsTable();
            end
        end
        
        function labelMapper = createLabelMapperFromUI(obj)
            targetLabelsMap = obj.createTargetLabelsMap();
            labelMapper = obj.createMapperWithTargetLabelsMap(targetLabelsMap);
            labelMapper.targetLabeling = obj.createTargetLabelingWithMap(targetLabelsMap);
        end
        
        function targetLabeling = createTargetLabeling(obj)
            targetLabelsMap = obj.createTargetLabelsMap();
            targetLabeling = obj.createTargetLabelingWithMap(targetLabelsMap);
        end
        
    end
    
    methods (Access = private)
        
        function idx = getSelectedLabelingIdx(obj)
            idxStr = obj.labelingsList.Value;
            [~,idx] = ismember(idxStr,obj.labelingsList.Items);
        end
        
        function labelMapping = getSelectedLabelMapping(obj)
            idx = obj.getSelectedLabelingIdx();
            labelMapping = obj.labelings(idx);
        end
        
        function labeling = createTargetLabelingWithMap(~,targetLabelsMap)
            classNames = targetLabelsMap.keys;
            classNames(ismember(classNames,Labeling.kNullClassStr)) = [];
            labeling = Labeling(classNames);
        end
        
        function updateMappingsTable(obj)
            currentMapping = obj.getSelectedLabelMapping();
            numClasses = currentMapping.numSourceClasses;
            data = cell(numClasses,2);
            data(:,1) = currentMapping.sourceClassNames;
            mappedLabels = currentMapping.mappingForLabels(int8(1:numClasses));
            data(:,2) = currentMapping.targetClassNames(mappedLabels);
            
            obj.labelMappingTable.Data = data;
        end
        
        function targetLabelsMap = createTargetLabelsMap(obj)
            targetLabelsMap = containers.Map();
            data = obj.labelMappingTable.Data;
            
            nSourceClasses = size(data,1);
            
            %maps target class strings to integers
            targetClassCount = 0;
            for sourceClass = 1 : nSourceClasses
                targetClassStr = data{sourceClass,2};
                if ~strcmp(targetClassStr, Labeling.kNullClassStr)...
                        && ~isKey(targetLabelsMap,targetClassStr)
                    targetClassCount = targetClassCount + 1;
                    targetLabelsMap(targetClassStr) = targetClassCount;
                end
            end
            
            targetLabelsMap(Labeling.kNullClassStr) = Labeling.kNullClass;
        end
        
        function labelMapper = createMapperWithTargetLabelsMap(obj,targetLabelsMap)
            labelMapper = LabelMapper();
            
            data = obj.labelMappingTable.Data;
            nSourceClasses = size(data,1);
            for sourceClass = 1 : nSourceClasses
                targetClassStr = data{sourceClass,2};
                targetClass = targetLabelsMap(targetClassStr);
                labelMapper.addMapping(int8(sourceClass),int8(targetClass));
            end
        end
        
        function handleSelectedLabelMappingChanged(obj,~,~)
            obj.updateMappingsTable();
            if ~isempty(obj.delegate)
                targetLabeling = obj.createTargetLabeling();
                obj.delegate.handleSelectedLabelingChanged(targetLabeling);
            end
        end
        
        function fillLabelMappingsList(obj)
            nLabelMappings = length(obj.labelings);
            labelMappingNames = cell(1,nLabelMappings);
            for i = 1 : nLabelMappings
                labelMapping = obj.labelings(i);
                labelMappingNames{i} = labelMapping.name;
            end
            obj.labelingsList.Items = labelMappingNames;
        end
    end
end