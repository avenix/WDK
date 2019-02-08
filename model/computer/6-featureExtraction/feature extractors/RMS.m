classdef RMS < Computer
    
    methods (Access = public)
        
        function obj = RMS()
            obj.name = 'RMS';
            obj.inputPort = ComputerPort(ComputerPortType.kSignal,ComputerSizeType.kN);
            obj.outputPort = ComputerPort(ComputerPortType.kFeature);
        end
        
        function dataOut = compute(~,signal)
            dataOut = rms(signal);
        end
    end
end