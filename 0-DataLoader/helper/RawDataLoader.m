classdef RawDataLoader < handle
    properties
        fileName;
    end
    
    methods (Access = public)
        
        function obj = RawDataLoader(fileName)
            obj.fileName = fileName;
        end
        
        function data = loadRawDataText(obj)
            textFileName = sprintf('%s.txt',obj.fileName);
            fileID = fopen(textFileName,'r');
            
            if fileID < 0
                fprintf('file not found %s\n',textFileName);
                data = [];
            else
                data = obj.parseFile(fileID);
            end
        end
        
        function nLines = countLines(~,fileID)
            nLines = 0;
            while(fgetl(fileID) > 0)
                nLines = nLines + 1;
            end
            fseek(fileID,0,'bof');
        end
        
        
        function data = loadRawDataBinary(obj)
            binaryFileName = sprintf('%s.bin',obj.fileName);
            
            binaryFile = fopen(binaryFileName,'r');
            if binaryFile == -1
                data = [];
            else
                %preallocate struct
                fileProperties = dir(binaryFileName);
                size = fileProperties.bytes;
                nSamples = size / 40;%40 bytes per component (38 for data + 2 padding added to the struct by compiler)
                data = zeros(nSamples,10);
                
                for i = 1 : nSamples
                    
                    data(i,1) = fread(binaryFile,1,'uint64');
                    data(i,2) = fread(binaryFile,1,'int32');
                    data(i,3) = fread(binaryFile,1,'int32');
                    data(i,4) = fread(binaryFile,1,'int32');
                    data(i,5) = fread(binaryFile,1,'int32');
                    data(i,6) = fread(binaryFile,1,'int32');
                    data(i,7) = fread(binaryFile,1,'int32');
                    data(i,8) = fread(binaryFile,1,'uint16');
                    data(i,9) = fread(binaryFile,1,'uint16');
                    data(i,10) = fread(binaryFile,1,'uint16');
                    
                    fread(binaryFile,2,'uint8');
                end
                
                fclose(binaryFile);
            end
        end
        
    end
    
    methods (Access = private)
        
        function data = parseFile(obj,fileID)
            
            nLines = obj.countLines(fileID);
            data = zeros(nLines,10);
            rowCount = 0;
            errorCount = 0;
            for i = 1 : nLines-1
                line = fgetl(fileID);
                
                columnsStr = strsplit(line,'\t');
                try
                    columns = cellfun(@str2num,columnsStr);
                catch
                    columns = [];
                end
                
                if isempty(columns) || length(columns) ~= 10
                    if errorCount < 100
                        fprintf('Problem parsin file at line %d\n',i);
                        errorCount = errorCount + 1;
                    end
                else
                    rowCount = rowCount + 1;
                    data(rowCount,:) = columns;
                end
            end
            
            data = data(1:rowCount,:);
        end
    end
end