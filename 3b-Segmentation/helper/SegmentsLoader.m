classdef SegmentsLoader < handle
    properties (Access = public)
        segmentsCreator;
        segmentsLabeler;
    end

    methods (Access = public)
        %returns a cell array of arrays of segments
        function segments = loadOrCreateSegments(obj)
            segmentationAlgorithmStr = obj.segmentsCreator.toString();
            fullFileName = sprintf('%s/3-segments_%s.mat',Constants.precomputedPath,segmentationAlgorithmStr);
            if exist(fullFileName,'File') == 2
                segments = load(fullFileName,'segments');
                segments = segments.segments;
            else
                fprintf('Creating %s...\n',fullFileName);
                segments = obj.segmentsCreator.createSegments();
                if ~isempty(obj.segmentsLabeler)
                    obj.segmentsLabeler.labelSegments(segments);
                end
                save(fullFileName,'segments');
            end
        end

    end
end