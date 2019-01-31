classdef AAV < Computer
    
    methods (Access = public)
        
        function obj = AAV()
            obj.name = 'AAV';
            obj.inputPort = ComputerPort(ComputerPortType.kSignal,ComputerSizeType.kN);
            obj.outputPort = ComputerPort(ComputerPortType.kFeature);
        end
        
        function dataOut = compute(~,signal)
            dataOut = single(0);
            
            for i = 1 : length(signal)-1
                dataOut = dataOut + single(abs(signal(i+1) - signal(i)));
            end
            dataOut = dataOut / length(signal);
        end
    end
end