classdef Octants < Computer
    
    methods (Access = public)
        
        function obj = Octants()
            obj.name = 'Octants';
            obj.inputPort = ComputerPort(ComputerPortType.kSignal,ComputerSizeType.kN);
            obj.outputPort = ComputerPort(ComputerPortType.kFeature);
        end
        
        function octants = compute(~,signal)
            octants = zeros(length(x), 1);
            for l=1 : size(signal,1)
                if signal(l,1) >= 0
                    if signal(l,2) >= 0
                        if signal(l,3) >= 0
                            octants(l) = 1;
                        else
                            octants(l) = 5;
                        end
                    else
                        if signal(l,3) >= 0
                            octants(l) = 4;
                        else
                            octants(l) = 8;
                        end
                    end
                else
                    if signal(l,2) >= 0
                        if signal(l,3) >= 0
                            octants(l) = 2;
                        else
                            octants(l) = 6;
                        end
                    else
                        if signal(l,3) >= 0
                            octants(l) = 3;
                        else
                            octants(l) = 7;
                        end
                    end
                end
            end
        end
    end
end

end
