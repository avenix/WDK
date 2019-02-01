  classdef OldFeatureExtractor < handle

    properties (Access = public, Constant)
        kSignalNames = {'lax','lay','laz','GravX','GravY','GravZ','MA'};
        kMiddlePartStart = 200;
        kMiddlePartEnd = 350;
    end
    
    properties (Access = public)
        nFeatures;
        featureNames;
        signalComputer;
        %numExpectedInputSignals = 18;
        numExpectedInputSignals = 6;
    end
    
    properties (Access = private)
        featureExtractors = {@min,@max,@mean,@var,@std,@median,@trapz,@aav,...
            @mad,@iqr,@rms,@mySkewness,@myKurtosis};
    end
    
    methods (Access = public)
        
        
        function obj = FeatureExtractor(signalComputer)
            if nargin > 0
                obj.signalComputer = signalComputer;
            end
            obj.computeFeatureNames();
            
        end
        
        function computeFeatureNames(obj)
            %window = rand(451,obj.numExpectedInputSignals);
            window = rand(451,6);
            segment = Segment(1,window,1,1);
            [~,obj.featureNames] = obj.extractFeaturesForSegment(segment);
            obj.nFeatures = length(obj.featureNames);
        end
        
        function [featureVector, featureNames] = extractFeaturesForSegment(obj,segment)
            dataArray = segment.window;
            if size(dataArray,2) ~= obj.numExpectedInputSignals
                fprintf('%s. Is %d, should be: %d\n',...
                    Constants.kInvalidInputSegmentError,size(dataArray,2),...
                    obj.numExpectedInputSignals);
                featureVector = [];
                featureNames = [];
            else
                if ~isempty(obj.signalComputer)
                    dataArray = obj.signalComputer.compute(dataArray);
                end
                accelerationMagnitude = single(dataArray(:,1).^2 + dataArray(:,2).^2 + dataArray(:,3).^2);
                dataArray = [dataArray, accelerationMagnitude];
                clear accelerationMagnitude;
                [featureVector, featureNames] = obj.extractFeaturesForArray(dataArray);
                
            end
        end
    end
    
    methods (Access = private)
        
        function [featureVector, featureNames] = extractFeaturesForArray(obj,segment)
            
            %Seperate halfs
            leftPart = segment(1:FeatureExtractor.kMiddlePartStart-1, :);
            middlePart = segment(FeatureExtractor.kMiddlePartStart:FeatureExtractor.kMiddlePartEnd, :);
            rightPart = segment(FeatureExtractor.kMiddlePartEnd+1:end, :);

            %% Extract features               
            featureVector = zeros(1,obj.nFeatures);
            featureNames = cell(1,obj.nFeatures);

            featureCounter = 1;
            for currentFeature = 1 : length(obj.featureExtractors)
                for currentSignal = 1 : size(segment,2)
                    featureExtractorHandle = obj.featureExtractors{currentFeature};
                    featureVector(featureCounter) = featureExtractorHandle(double(leftPart(:,currentSignal)));
                    featureNames(featureCounter) = obj.convertFeatureToString(featureExtractorHandle,currentSignal,'left');
                    featureCounter = featureCounter + 1;
                    
                    featureExtractorHandle = obj.featureExtractors{currentFeature};
                    featureVector(featureCounter) = featureExtractorHandle(double(middlePart(:,currentSignal)));
                    featureNames(featureCounter) = obj.convertFeatureToString(featureExtractorHandle,currentSignal,'middle');
                    featureCounter = featureCounter + 1;
                    
                    featureExtractorHandle = obj.featureExtractors{currentFeature};
                    featureVector(featureCounter) = featureExtractorHandle(double(rightPart(:,currentSignal)));
                    featureNames(featureCounter) = obj.convertFeatureToString(featureExtractorHandle,currentSignal,'right');
                    featureCounter = featureCounter + 1;
                end
            end

            %{
            %quantile
            numQuantileParts = 4;
            for currentSignal = 1 : size(segment,2)
                quantilesResult = quantile(segment(:,currentSignal),numQuantileParts);
                featureStringName = obj.convertFeatureToString(@quantile,currentSignal, signalNames);
                for quantilePart = 1 : numQuantileParts
                    featureVector(featureCounter) = quantilesResult(quantilePart);
                    finalFeatureName = sprintf('%s%d',featureStringName{1},quantilePart);
                    featureNames(featureCounter) = {finalFeatureName};
                    featureCounter = featureCounter + 1;
                end
            end
            %}
            
            %zero crossing: only for ax,ay,az,gx,gy,gz
            for currentSignal = 1 : size(segment,2)-1
                featureVector(featureCounter) = zrc(leftPart(:,currentSignal));
                featureNames(featureCounter) = obj.convertFeatureToString(@zrc,currentSignal,'left');
                featureCounter = featureCounter + 1;
                
                featureVector(featureCounter) = zrc(middlePart(:,currentSignal));
                featureNames(featureCounter) = obj.convertFeatureToString(@zrc,currentSignal,'middle');
                featureCounter = featureCounter + 1;
                
                featureVector(featureCounter) = zrc(rightPart(:,currentSignal));
                featureNames(featureCounter) = obj.convertFeatureToString(@zrc,currentSignal,'right');
                featureCounter = featureCounter + 1;
            end
            
            %sma acceleration:
            featureVector(featureCounter) = sma(segment(:,1:3));
            featureNames(featureCounter) = {'smaAcceleration'};
            featureCounter = featureCounter + 1;
            
            %sma gravity:
            featureVector(featureCounter) = sma(segment(:,4:6));
            featureNames(featureCounter) = {'smaGravity'};
            featureCounter = featureCounter + 1;
            
            %svm acceleration:
            featureVector(featureCounter) = svmFeature(segment(:,7));
            featureNames(featureCounter) = {'svmAcceleration'};
            featureCounter = featureCounter + 1;
            
            %correlation coefficients
            corrCoeffResult = corrcoef(segment(:,1:end));
            for i = 1 : size(corrCoeffResult,1)-1%exclude magnitude
                for j = i + 1 : size(corrCoeffResult,2)-1
                    featureVector(featureCounter) = corrCoeffResult(i,j);
                    featureNames(featureCounter) = obj.getCorrelationFeatureString(i,j,'corr');
                    featureCounter = featureCounter + 1;
                end
            end
            
            %cross correlation coefficients
            %for each pair of signals
            for i = 1 : size(segment,2)-1
                for j = i + 1 : size(segment,2)-1
                    featureVector(featureCounter) = maxCrossCorr(segment(:,i),segment(:,j));
                    featureNames(featureCounter) = obj.getCorrelationFeatureString(i,j,'xcorr');
                    featureCounter = featureCounter + 1;
                end
            end
            
            %acceleration energy
            featureVector(featureCounter) = energy(segment(:,1));
            featureNames(featureCounter) = {'energyAx'};
            featureCounter = featureCounter + 1;
            
            featureVector(featureCounter) = energy(segment(:,2));
            featureNames(featureCounter) = {'energyAy'};
            featureCounter = featureCounter + 1;
            
            featureVector(featureCounter) = energy(segment(:,3));
            featureNames(featureCounter) = {'energyAz'};
            featureCounter = featureCounter + 1;
            
            featureVector(featureCounter) = sum(segment(:,7));
            featureNames(featureCounter) = {'energyAM'};
            %featureCounter = featureCounter + 1;
            
            %featureVector(featureCounter) = segment.peakIdx;
            %featureNames(featureCounter) = {'ts'};
        end
    end
    
    methods (Static, Access = private)
        function [featureString] = getCorrelationFeatureString(row,col, correlationType)
            signalName1 = FeatureExtractor.kSignalNames(row);
            signalName2 = FeatureExtractor.kSignalNames(col);
            featureString = sprintf('%s%s%s',correlationType,signalName1{1},signalName2{1});
            featureString = {featureString};
        end
        
        function [featureString] = convertFeatureToString(featureExtractorHandle,signalIdx,part)
            signalName = FeatureExtractor.kSignalNames(signalIdx);
            featureString = sprintf('%s%s_%s',func2str(featureExtractorHandle),signalName{1},part);
            featureString = {featureString};
        end
    end
    
  end




  


