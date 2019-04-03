classdef LabelGroupingLoader < handle
        
    methods (Static, Access = public)
        
        function labelGrouping = LoadLabelGrouping( fileName)
            labelGrouping = LabelGroupingLoader.ParseLabelGroupingFile(fileName);
        end
    end
    
    methods (Static,Access = private)
         
        function labelGrouping = ParseLabelGroupingFile(fileName)
            
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
                
                nGroups = LabelGroupingLoader.CountNumberOfGroups(dataArray{1});
                labelGroups = LabelGroupingLoader.ParseLabelGroup(dataArray{1},nGroups);
                
                labelGrouping = LabelGrouping(labelGroups);
                
                fclose(fileID);
            end
        end
        
        function nGroups = CountNumberOfGroups(dataArray)
            nGroups = 0;
            nRows = length(dataArray);
            for i = 1 : nRows
                row = dataArray{i};
                if contains(row,'#')
                    nGroups = nGroups + 1;
                end
            end
        end
        
        function labelGroups = ParseLabelGroup(dataArray,nGroups)
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