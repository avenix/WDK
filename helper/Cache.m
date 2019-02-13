classdef Cache < handle
    
    properties (Access = private)
        filesMap;
    end
    
    methods (Access = public)
        
        function saveVariable(obj,var,str)
            if ~isempty(var) && ~isempty(str)
                fileName = Cache.HashForString(str);
                obj.filesMap(fileName) = true;
                fileName = sprintf('%s/%s.mat',Constants.kPrecomputedPath,fileName);
                save(fileName,'var');
            end
        end
        
        function b = containsVariable(obj,str)
            fileName = Cache.HashForString(str);
            b = isKey(obj.filesMap,fileName);
        end
        
        function var = loadVariable(~,str)
            fileName = Cache.HashForString(str);
            fileName = sprintf('%s/%s.mat',Constants.kPrecomputedPath,fileName);
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
            hash = mlreportgen.utils.hash(str);
        end
        
    end
    
    methods (Access = private)
        function obj = Cache()
            files = Helper.listFilesInDirectory(Constants.kPrecomputedPath,{'*.mat'});
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