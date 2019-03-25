classdef Cache < handle
    
    properties (Access = private)
        filesMap;
    end
    
    methods (Access = public)
        
        function saveVariable(obj,var,str)
            if ~isempty(var) && ~isempty(str)
                fileName = Cache.HashForString(str);
                obj.filesMap(fileName) = true;
                fileName = sprintf('%s/%s.mat',Constants.kCachePath,fileName);
                save(fileName,'var');
            end
        end
        
        function b = containsVariable(obj,str)
            fileName = Cache.HashForString(str);
            b = isKey(obj.filesMap,fileName);
        end
        
        function var = loadVariable(~,str)
            fileName = Cache.HashForString(str);
            fileName = sprintf('%s/%s.mat',Constants.kCachePath,fileName);
            var = load(fileName);
            var = var.var;
        end
    end
    
    methods(Static, Access = public)
        function obj = SharedInstance()
            persistent uniqueInstance
            if isempty(uniqueInstance)
                obj = Cache();
                uniqueInstance = obj;
            else
                obj = uniqueInstance;
            end
        end
        
        function hash = HashForString(str)
            persistent md
            if isempty(md)
                md = java.security.MessageDigest.getInstance('SHA-256');
            end
            hash = sprintf('%2.2x', typecast(md.digest(uint8(str)), 'uint8')');
        end        
    end
    
    methods (Access = private)
        function obj = Cache()
            files = Helper.listFilesInDirectory(Constants.kCachePath,{'*.mat'});
            files = Helper.removeFileExtensionForFiles(files);
            
            if isempty(files)
                obj.filesMap = containers.Map('KeyType','char','ValueType','logical');
            else
                values = true(1,length(files));
                obj.filesMap = containers.Map(files,values);
            end
        end
        
    end
    
end