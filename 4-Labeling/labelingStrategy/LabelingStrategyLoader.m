classdef LabelingStrategyLoader < handle
        
    methods (Access = public)
        
        function labelingStrategy = loadLabelingStrategy(obj, fileName)
            labelingStrategy = obj.parseLabelingStrategyFile(fileName);
        end
    end
    
    methods (Access = private)
         
        function labelingStrategy = parseLabelingStrategyFile(obj,fileName)
            
            delimiter = ',';
            startRow = 1;
            endRow = inf;
            
            formatSpec = '%s%s%[^\n\r]';
            
            [fileID,~] = fopen(fileName);
            if (fileID < 0)
                fprintf('file not found: %s\n',fileName);
                labelingStrategy = [];
            else
                dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', delimiter, 'HeaderLines', startRow(1)-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
                
                nGroups = obj.countNumberOfGroups(dataArray{1});
                classGroups = obj.parseClassGroup(dataArray{1},nGroups);
                
                labelingStrategy = ClassLabelingStrategy(classGroups);
                
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
        
        function classGroups = parseClassGroup(~,dataArray,nGroups)
            classGroups = repmat(ClassGroup,1,nGroups);
            
            currentClassGroup = classGroups(1);
            groupCount = 0;
            nRows = length(dataArray);
            for i = 1 : nRows
                row = dataArray{i};
                if contains(row,'#')
                    currentClassGroup = ClassGroup(row(2:end));
                    groupCount = groupCount + 1;
                    classGroups(groupCount) = currentClassGroup;
                else
                    currentClassGroup.addGroupedClass(row);
                end
            end
        end
        
    end
end