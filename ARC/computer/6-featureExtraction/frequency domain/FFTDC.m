%returns the first component of the frequency representation of the signal
classdef FFTDC < Computer
    
    methods (Access = public)
        
        function obj = FFTDC()
            obj.name = 'FFTDC';
            obj.inputPort = ComputerDataType.kSignal;
            obj.outputPort = ComputerDataType.kFeature;
        end
        
        %receives a fourier transform
        function result = compute(~,Y)
            result = real(Y(1));
        end
        
        function metrics = computeMetrics(~,~)
            flops = 1;
            memory = 1;
            outputSize = Constants.kFeatureBytes;
            metrics = Metric(flops,memory,outputSize);
        end
    end
end
