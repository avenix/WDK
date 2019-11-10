classdef SynchronizationFile < handle
    properties (Access = public)
        synchronizationPointsMap;
        fileName;
        count;%dependent property
    end
    
    methods
        function c = get.count(obj)
            c = obj.synchronizationPointsMap.Count;
        end
    end
    
    methods (Access = public)
        function obj = SynchronizationFile(samples,frames)
            obj.synchronizationPointsMap = containers.Map('KeyType','uint64','ValueType','uint32');
            if nargin > 0
                obj.synchronizationPointsMap.keys = samples;
                obj.synchronizationPointsMap.values = frames;
            end
        end
        
        function isValid = isValidSynchronizationFile(obj)
            isValid = (length(obj.synchronizationPointsMap.keys) >= 2);
        end
        
        function setSynchronizationPoint(obj,sample,frame)
            obj.synchronizationPointsMap(uint64(sample)) = uint32(frame);
        end
        
        function removeSynchronizationPointWithSample(obj,sample)
            obj.synchronizationPointsMap.remove(sample);
        end
        
        function videoFrame = sampleToVideoFrame(obj, sample)
            if ~obj.isValidSynchronizationFile()
                videoFrame = [];
            else
                [sample1, frame1] = obj.getFirstSynchronizationPoint();
                [sample2, frame2] = obj.getLastSynchronizationPoint();
                
                a = double(frame2 - frame1) / double(sample2 - sample1);
                videoFrame = a * (sample - double(sample1)) + double(frame1);
                
                if videoFrame < 1
                    videoFrame = 1;
                end
                
                videoFrame = uint32(videoFrame);
            end
        end
        
        function sample = videoFrameToSample(obj, videoFrame)
            if ~obj.isValidSynchronizationFile()
                sample = [];
            else
                [sample1, frame1] = obj.getFirstSynchronizationPoint();
                [sample2, frame2] = obj.getLastSynchronizationPoint();
                
                a = (double(sample2) - double(sample1)) / (double(frame2) - double(frame1));
                sample = a * (double(videoFrame) - double(frame1)) + double(sample1);
                
                if sample < 1
                    sample = 1;
                end
                
                sample = uint32(sample);
            end
        end
    end
    
    methods (Access = private)
        
        function [sample, frame] = getFirstSynchronizationPoint(obj)
            samples = obj.synchronizationPointsMap.keys;
            frames = obj.synchronizationPointsMap.values;
            if isempty(samples)
                sample = [];
                frame = [];
            else
                [~, minIdx] = min(cell2mat(samples));
                sample = samples{minIdx};
                frame = frames{minIdx};
            end
        end
        
        function [sample, frame] = getLastSynchronizationPoint(obj)
            samples = obj.synchronizationPointsMap.keys;
            frames = obj.synchronizationPointsMap.values;
            if isempty(samples)
                sample = [];
                frame = [];
            else
                [~, maxIdx] = max(cell2mat(samples));
                sample = samples{maxIdx};
                frame = frames{maxIdx};
            end
        end
    end
end
