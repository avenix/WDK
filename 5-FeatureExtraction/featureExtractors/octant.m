%% octant
    function octants = octant(x, y, z)
        octants = zeros(length(x), 1);
        for l=1 : length(x)
            if x(l) >= 0
                if y(l) >= 0
                    if z(l) >= 0
                        octants(l) = 1;
                    else
                        octants(l) = 5;
                    end
                else
                    if z(l) >= 0
                        octants(l) = 4;
                    else
                        octants(l) = 8;
                    end
                end
            else
                if y(l) >= 0
                    if z(l) >= 0
                        octants(l) = 2;
                    else
                        octants(l) = 6;
                    end
                else
                    if z(l) >= 0
                        octants(l) = 3;
                    else
                        octants(l) = 7;
                    end
                end
            end
        end
    end