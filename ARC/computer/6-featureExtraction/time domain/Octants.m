classdef Octants < Computer
    
    methods (Access = public)
        
        function obj = Octants()
            obj.name = 'Octants';
            obj.inputPort = DataType.kSignal3;
            obj.outputPort = DataType.kFeature;
        end
        
        function octants = compute(~,signal)
            octants = zeros(length(signal), 1);
            for i=1 : size(signal,1)
                if signal(i,1) >= 0
                    if signal(i,2) >= 0
                        if signal(i,3) >= 0
                            octants(i) = 1;
                        else
                            octants(i) = 5;
                        end
                    else
                        if signal(i,3) >= 0
                            octants(i) = 4;
                        else
                            octants(i) = 8;
                        end
                    end
                else
                    if signal(i,2) >= 0
                        if signal(i,3) >= 0
                            octants(i) = 2;
                        else
                            octants(i) = 6;
                        end
                    else
                        if signal(i,3) >= 0
                            octants(i) = 3;
                        else
                            octants(i) = 7;
                        end
                    end
                end
            end
        end
        
        function metrics = computeMetrics(~,input)
            n = size(input,1);
            flops = 7 * n;
            memory = 1;
            outputSize = Constants.kFeatureBytes;
            metrics = Metric(flops,memory,outputSize);
        end
    end
end

