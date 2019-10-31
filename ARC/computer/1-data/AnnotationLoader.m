classdef AnnotationLoader < Computer
    properties (Access = public)
        fileName;
    end
    
    properties (Access = private)
        annotationsMap;
    end
    
    properties (Dependent)
        annotations;
    end
    
    methods
        function set.annotations(obj,annotations)
            obj.createAnnotationsMap(annotations);
        end
    end
    
    methods (Access = public)
        function obj = AnnotationLoader(fileName,annotations)
            if nargin > 0
                obj.fileName = fileName;
                if nargin > 1
                    obj.createAnnotationsMap(annotations);
                end
            end
            
            obj.name = 'annotationsLoader';
            obj.inputPort = DataType.kNull;
            obj.outputPort = DataType.kAnnotation;
        end
        
        function annotation = compute(obj,~)
            annotationFileName = Helper.removeFileExtension(obj.fileName);
            if isempty(obj.annotationsMap)
                defaultLabeling = DataLoader.LoadDefaultLabeling();
                annotation = DataLoader.LoadAnnotationSetFullPath(obj.fileName,defaultLabeling);
            else
                annotation = obj.annotationsMap(annotationFileName);
            end
        end
        
        function str = toString(obj)
            str = sprintf('%s_%s',obj.name, obj.fileName);
        end
        
        function fileNameProperty = getEditableProperties(obj)
            fileNameProperty = Property('fileName',obj.fileName);
        end
    end
    
    methods (Access = private)
        function createAnnotationsMap(obj,annotations)
            nAnnotations = length(annotations);
            
            annotationCells = cell(1,nAnnotations);
            annotationNames = cell(1,nAnnotations);
            
            for i = 1 : nAnnotations
                annotation = annotations(i);
                annotationName = annotation.fileName;
                annotationNames{i} = Helper.removeAnnotationsExtension(annotationName);
                annotationCells{i} = AnnotationSet(annotation.eventAnnotations,annotation.rangeAnnotations);
            end
            obj.annotationsMap = containers.Map(annotationNames,annotationCells);
        end
    end
end
