classdef C45Classifier < Computer
    
    properties (Access = public)
        shouldTrain = false;
        nLearners = 30;
        inc_node;
        region;
    end
    
    properties (Access = private)
        classifier;
    end
    
    methods (Access = public)
        
        function obj = C45Classifier()
            obj.name = 'Ensemble';
            obj.inputPort = ComputerDataType.kTable;
            obj.outputPort = ComputerDataType.kTable;
        end
        
        function dataOut = compute(obj,data)
            if obj.shouldTrain
                obj.train(data);
                dataOut = [];
            else
                dataOut = obj.test(data);
            end
        end
        
        function D = train(obj,table)
            train_features = table.features;
            train_targets = table.labels;
            
            [Ni, M]		= size(train_features);
            obj.inc_node    = obj.inc_node*M/100;
            Nu          = 10;
            
            %For the decision obj.region
            N           = obj.region(5);
            mx          = ones(N,1) * linspace (obj.region(1),obj.region(2),N);
            my          = linspace (obj.region(3),obj.region(4),N)' * ones(1,N);
            flatxy      = [mx(:), my(:)]';
            
            %Find which of the input features are discrete, and discretisize the corresponding
            %dimension on the decision obj.region
            discrete_dim = zeros(1,Ni);
            for i = 1:Ni
                Nb = length(unique(train_features(i,:)));
                if (Nb <= Nu)
                    %This is a discrete feature
                    discrete_dim(i)	= Nb;
                    [~, flatxy(i,:)]	= high_histogram(flatxy(i,:), Nb);
                end
            end
            
            %Build the tree recursively
            disp('Building tree')
            obj.classifier        = make_tree(train_features, train_targets, obj.inc_node, discrete_dim, max(discrete_dim), 0);
            %{
            %Make the decision obj.region according to the tree
            disp('Building decision surface using the tree')
            targets		= use_tree(flatxy, 1:N^2, obj.classifier, discrete_dim, unique(train_targets));
            
            D   		= reshape(targets,N,N);
            %}
        end
        
        function labels = test(obj,table)
            labels = use_tree(table.features,1:N^2, obj.classifier, discrete_dim, unique(train_targets));
        end
        
        function str = toString(obj)
            str = sprintf('%s_%d_%d',obj.name,obj.nLearners,obj.ensembleMethod);
        end
        
        function editableProperties = getEditableProperties(obj)
            editableProperties = Property('nLearners',obj.nLearners,1,100,PropertyType.kNumber);
        end
    end
    
    methods (Access = private)
        function targets = use_tree(features, indices, tree, discrete_dim, Uc)
            
            targets = zeros(1, size(features,2));
            
            if (tree.dim == 0)
                %Reached the end of the tree
                targets(indices) = tree.child;
                return;
            end
            
            %This is not the last level of the tree, so:
            %First, find the dimension we are to work on
            dim = tree.dim;
            dims= 1:size(features,1);
            
            %And classify according to it
            if (discrete_dim(dim) == 0)
                %Continuous feature
                in				= indices(find(features(dim, indices) <= tree.split_loc));
                targets		= targets + use_tree(features(dims, :), in, tree.child(1), discrete_dim(dims), Uc);
                in				= indices(find(features(dim, indices) >  tree.split_loc));
                targets		= targets + use_tree(features(dims, :), in, tree.child(2), discrete_dim(dims), Uc);
            else
                %Discrete feature
                Uf				= unique(features(dim,:));
                for i = 1:length(Uf)
                    in   	   = indices(find(features(dim, indices) == Uf(i)));
                    targets	= targets + use_tree(features(dims, :), in, tree.child(i), discrete_dim(dims), Uc);
                end
            end
        end
        
        function tree = make_tree(features, targets, discrete_dim, maxNbin, base)
            
            %Build a tree recursively
            
            [Ni, L]    					= size(features);
            Uc         					= unique(targets);
            tree.dim						= 0;
            %tree.child(1:maxNbin)	= zeros(1,maxNbin);
            tree.split_loc				= inf;
            
            if isempty(features)
                return;
            end
            
            %When to stop: If the dimension is one or the number of examples is small
            if ((obj.inc_node > L) | (L == 1) | (length(Uc) == 1))
                H					= hist(targets, length(Uc));
                [~, largest] 	= max(H);
                tree.child	 	= Uc(largest);
                return;
            end
            
            %Compute the node's I
            for i = 1:length(Uc)
                Pnode(i) = length(find(targets == Uc(i))) / L;
            end
            Inode = -sum(Pnode.*log(Pnode)/log(2));
            
            %For each dimension, compute the gain ratio impurity
            %This is done separately for discrete and continuous features
            delta_Ib    = zeros(1, Ni);
            split_loc	= ones(1, Ni)*inf;
            
            for i = 1:Ni
                data	= features(i,:);
                Nbins	= length(unique(data));
                if (discrete_dim(i))
                    %This is a discrete feature
                    P	= zeros(length(Uc), Nbins);
                    for j = 1:length(Uc)
                        for k = 1:Nbins
                            indices 	= find((targets == Uc(j)) & (features(i,:) == k));
                            P(j,k) 	= length(indices);
                        end
                    end
                    Pk          = sum(P);
                    P           = P/L;
                    Pk          = Pk/sum(Pk);
                    info        = sum(-P.*log(eps+P)/log(2));
                    delta_Ib(i) = (Inode-sum(Pk.*info))/-sum(Pk.*log(eps+Pk)/log(2));
                else
                    %This is a continuous feature
                    P	= zeros(length(Uc), 2);
                    
                    %Sort the features
                    [sorted_data, indices] = sort(data);
                    sorted_targets = targets(indices);
                    
                    %Calculate the information for each possible split
                    I	= zeros(1, L-1);
                    for j = 1:L-1
                        for k =1:length(Uc)
                            P(k,1) = length(find(sorted_targets(1:j) 		== Uc(k)));
                            P(k,2) = length(find(sorted_targets(j+1:end) == Uc(k)));
                        end
                        Ps		= sum(P)/L;
                        P		= P/L;
                        info	= sum(-P.*log(eps+P)/log(2));
                        I(j)	= Inode - sum(info.*Ps);
                    end
                    [delta_Ib(i), s] = max(I);
                    split_loc(i) = sorted_data(s);
                end
            end
            
            %Find the dimension minimizing delta_Ib
            [~, dim] = max(delta_Ib);
            dims		= 1:Ni;
            tree.dim = dim;
            
            %Split along the 'dim' dimension
            Nf		= unique(features(dim,:));
            Nbins	= length(Nf);
            if (discrete_dim(dim))
                %Discrete feature
                for i = 1:Nbins
                    indices    		= find(features(dim, :) == Nf(i));
                    tree.child(i)	= make_tree(features(dims, indices), targets(indices), discrete_dim(dims), maxNbin, base);
                end
            else
                %Continuous feature
                tree.split_loc		= split_loc(dim);
                indices1		   	= find(features(dim,:) <= split_loc(dim));
                indices2	   		= find(features(dim,:) > split_loc(dim));
                tree.child(1)		= make_tree(features(dims, indices1), targets(indices1), obj.inc_node, discrete_dim(dims), maxNbin);
                tree.child(2)		= make_tree(features(dims, indices2), targets(indices2), obj.inc_node, discrete_dim(dims), maxNbin);
            end
            
        end
    end
end