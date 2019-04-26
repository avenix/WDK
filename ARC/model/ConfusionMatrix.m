classdef ConfusionMatrix < handle
    properties (GetAccess = public)
        confusionMatrixData;
        nClasses;
        containsNullClass;
        classNames;
    end
    
    methods (Access = public)
        function obj = ConfusionMatrix(truthClasses,predictedClasses,classes,classNames)
            if nargin > 1
                if nargin == 3
                    classNames = [];
                end
                
                if(any(predictedClasses == ClassesMap.kNullClass))
                    obj.confusionMatrixData = confusionmat(truthClasses,predictedClasses,'Order',[classes 0]);
                    obj.classNames = [classNames, Constants.kNullClassGroupStr];
                    obj.containsNullClass = true;
                else
                    obj.confusionMatrixData = confusionmat(truthClasses,predictedClasses,'Order',classes);
                    obj.classNames = classNames;
                    obj.containsNullClass = false;
                end
                
                obj.nClasses = size(obj.confusionMatrixData,1);
            end
        end
    end
    
    methods (Access = public, Static)
        function confusionMatrix = CreateConfusionMatrixWithData(confusionMatrixData)
            confusionMatrix = ConfusionMatrix();
            confusionMatrix.confusionMatrixData = confusionMatrixData;
        end
    end
    
end