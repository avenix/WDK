classdef AccelAndGravityComputer < Computer
    
    methods (Access = public)
        
        function obj = AccelAndGravityComputer()
        end
        
        function computedSignal = compute(~,signal)
            
            linearAccel = signal(:,15:17);
            gravity = signal(:,3:5)/10 - linearAccel;
            computedSignal = [linearAccel, gravity];
        end
        
        function str = toString(~)
            str = 'AccelAndGravityComputer';
        end
        
        function editableProperties = getEditableProperties(obj)
            editableProperties =[]
        end
    end
end