classdef AnnotationClusterer < handle
    properties (Access = public)
        segmentationAlgorithm;
        featureExtractionAlgorithm;
        numClasses;
        distanceThreshold = 25.0;
    end
    
    methods (Access = public)
        
        function obj = AnnotationClusterer(numClasses,segmentationAlgorithm)
            obj.numClasses = numClasses;
            
            obj.segmentationAlgorithm = segmentationAlgorithm;
            
            featureExtractor = FeatureExtractor.CreateFeatureExtractor(...
                1:6,FeatureExtractor.DefaultFeatures());
            
            featureExtractionAlgorithm = Algorithm.AlgorithmWithSequence({featureExtractor});
            
            obj.featureExtractionAlgorithm = featureExtractionAlgorithm;
        end
        
        function rangeAnnotations = clusterAnnotations(obj,dataFile)
            Algorithm.SetSharedContextVariable(Constants.kSharedVariableCurrentDataFile,dataFile);
            
            segments = Algorithm.ExecuteChain(obj.segmentationAlgorithm,dataFile.data);
            
            featuresTable = Algorithm.ExecuteChain(obj.featureExtractionAlgorithm,segments);
            
            fprintf('clustering...\n');
            [labels,~,~,distances] = kmeans(featuresTable.getDataArray(),obj.numClasses);
            
            nSegments = length(labels);
            rangeAnnotations = repmat(RangeAnnotation,1,nSegments);
            
            annotationCount = 1;
            for i = 1 : nSegments
                segment = segments(i);
                label = labels(i);
                
                fprintf('%.5f\n',sqrt(distances(i,label)));
                
                if sqrt(distances(i,label)) < obj.distanceThreshold
                    rangeAnnotation = RangeAnnotation(segment.startSample,segment.endSample,label);
                    rangeAnnotations(annotationCount) = rangeAnnotation;
                    annotationCount = annotationCount + 1;
                end
            end
            
            rangeAnnotations = rangeAnnotations(1:annotationCount-1);
            fprintf('clustered %d annotations\n',annotationCount-1);
        end
    end
    
end