classdef LabelGroupingLoader < handle
        
    methods (Access = public)
        
        function labelGrouping = loadLabelGrouping(obj, fileName)
            labelGrouping = obj.parseLabelGroupingFile(fileName);
        end
    end
    
    methods (Access = private)
         
        function labelGrouping = parseLabelGroupingFile(obj,fileName)
            
            delimiter = ',';
            startRow = 1;
            endRow = inf;
            
            formatSpec = '%s%s%[^\n\r]';
            
            [fileID,~] = fopen(fileName);
            if (fileID < 0)
                fprintf('file not found: %s\n',fileName);
                labelGrouping = [];
            else
                dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', delimiter, 'HeaderLines', startRow(1)-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
                
                nGroups = obj.countNumberOfGroups(dataArray{1});
                labelGroups = obj.parseLabelGroup(dataArray{1},nGroups);
                
                labelGrouping = LabelGrouping(labelGroups);
                
                fclose(fileID);
            end
        end
        
        function nGroups = countNumberOfGroups(~,dataArray)
            nGroups = 0;
            nRows = length(dataArray);
            for i = 1 : nRows
                row = dataArray{i};
                if contains(row,'#')
                    nGroups = nGroups + 1;
                end
            end
        end
        
        function labelGroups = parseLabelGroup(~,dataArray,nGroups)
            labelGroups = repmat(LabelGroup,1,nGroups);
            
            currentLabelGroup = labelGroups(1);
            groupCount = 0;
            nRows = length(dataArray);
            for i = 1 : nRows
                row = dataArray{i};
                if contains(row,'#')
                    currentLabelGroup = LabelGroup(row(2:end));
                    groupCount = groupCount + 1;
                    labelGroups(groupCount) = currentLabelGroup;
                else
                    currentLabelGroup.addGroupedLabel(row);
                end
            end
        end
        
    end
end