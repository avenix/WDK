%this class retrieves a preprocessing computer from the UI
classdef FeatureExtractionConfigurator < handle

    properties (Access = private)
        computerConfigurator;
        defaultFeaturesList;
        addFeatureButton;
        removeFeatureButton;
    end
    
    properties (Access = public)    
        defaultFeatures;
    end
    
    methods (Access = public)
        function obj = FeatureExtractionConfigurator(defaultFeatures, featuresList,...
                addFeaturesButton,removeFeaturesButton,...
                selectedFeaturesList, computersVariablesTable)
            
            obj.defaultFeatures = defaultFeatures;
            obj.defaultFeaturesList = featuresList;
            obj.addFeatureButton = addFeaturesButton;
            obj.removeFeatureButton = removeFeaturesButton;
            
            obj.addFeatureButton.ButtonPushedFcn = @obj.handleAddButtonClicked;
            obj.removeFeatureButton.ButtonPushedFcn = @obj.handleRemoveButtonClicked;
            
            if ~isempty(obj.defaultFeatures)
                
                obj.computerConfigurator = ComputerConfigurator(...
                    [],...
                    selectedFeaturesList,...
                    computersVariablesTable);
                
                obj.reloadUI();
            end
        end
        
        function reloadUI(obj)
            obj.fillDefaultFeaturesList();
            obj.computerConfigurator.reloadUI();
        end
        
        function featureExtractor = createFeatureExtractorWithUIParameters(obj)
            featureExtractor = FeatureExtractor(obj.computerConfigurator.computers);
        end
        
        function idx = getSelectedFeatureIdx(obj)
            idxStr = obj.defaultFeaturesList.Value;
            [~,idx] = ismember(idxStr,obj.defaultFeaturesList.Items);
        end
        
        function feature = getSelectedFeature(obj)
            idx = obj.getSelectedFeatureIdx();
            feature = obj.defaultFeatures{idx};
        end
    end
    
    methods(Access = private)
        
        function handleAddButtonClicked(obj,~,~)
            featureExtractor = obj.getSelectedFeature();
            rangeSelector = RangeSelector();
            axisSelector = AxisSelector();
            windowGetter = Change('window');
            
            chainBuilder = ChainBuilder(rangeSelector);
            chainBuilder.addComputer(windowGetter);
            chainBuilder.addComputer(axisSelector);
            chainBuilder.addComputer(featureExtractor);
            
            computer = chainBuilder.root;
            computer.name = featureExtractor.name;
            obj.computerConfigurator.addComputer(computer);
        end
        
        function handleRemoveButtonClicked(obj,~,~)
            obj.computerConfigurator.removeSelectedComputer();
        end
        
        function fillDefaultFeaturesList(obj)            
            obj.defaultFeaturesList.Items = Helper.generateComputerNamesArray(obj.defaultFeatures);
        end
    end
end