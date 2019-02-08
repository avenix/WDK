classdef CompositeComputer < Computer

    properties (Access = public)
        root;%first element in the chain
    end
    
    methods (Access = public)
        function obj = CompositeComputer(root)
            if nargin > 0
                obj.root = root;
            end
            obj.name = "Composite";
        end
        
        function dataOut = compute(obj,dataIn)
            dataOut = Computer.ExecuteChain(obj.root,dataIn);
        end

        %{
        function editableProperties = getEditableProperties(obj)
            nComputers = obj.numComputers;
            editableProperties = cell(1,nComputers);
            for i = 1 : nComputers
                editableProperties{i} = obj.computers{i}.getEditableProperties();
            end
        end
        %}
        
    end
end