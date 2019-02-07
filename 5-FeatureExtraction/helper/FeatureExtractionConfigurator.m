%this class retrieves a preprocessing computer from the UI
classdef FeatureExtractionConfigurator < handle
    
    properties (Access = private)
        computerConfigurator;
        defaultFeaturesList;
        addFeatureButton;
        removeFeatureButton;
        loadedFeatureExtractorsList;
        
        manualFeatureExtractionPanel;
        selectionTypeButtonGroup;
        selectFromFileRadio;
        selectManuallyRadio;
    end
    
    properties (Access = public)
        defaultFeatures;
        loadedFeatureExtractors;
    end
    
    methods (Access = public)
        function obj = FeatureExtractionConfigurator(defaultFeatures,...
                loadedFeatureExtractors, featuresList,...
                addFeaturesButton,removeFeaturesButton,...
                selectedFeaturesList, computersVariablesTable,...
                loadedFeatureExtractorsList,selectionTypeButtonGroup,...
                selectFromFileRadio,selectManuallyRadio,manualFeatureExtractionPanel)
            
            obj.defaultFeatures = defaultFeatures;
            obj.loadedFeatureExtractors = loadedFeatureExtractors;
            obj.defaultFeaturesList = featuresList;
            obj.addFeatureButton = addFeaturesButton;
            obj.removeFeatureButton = removeFeaturesButton;
            obj.loadedFeatureExtractorsList = loadedFeatureExtractorsList;
            obj.selectionTypeButtonGroup = selectionTypeButtonGroup;
            obj.selectFromFileRadio = selectFromFileRadio;
            obj.selectManuallyRadio = selectManuallyRadio;
            obj.manualFeatureExtractionPanel = manualFeatureExtractionPanel;
            
            obj.addFeatureButton.ButtonPushedFcn = @obj.handleAddButtonClicked;
            obj.removeFeatureButton.ButtonPushedFcn = @obj.handleRemoveButtonClicked;
            obj.selectionTypeButtonGroup.SelectionChangedFcn = @obj.handleSelectionTypeChanged;
            
            if ~isempty(obj.loadedFeatureExtractors)
                obj.fillLoadedFeaturesList();
                obj.loadedFeatureExtractorsList.Value = obj.loadedFeatureExtractorsList.Items{1};
            end
            
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
            if obj.isManualMode()
                featureExtractor = FeatureExtractor(obj.computerConfigurator.computers);
            else
                fileIdx = obj.getSelectedLoadedFileIdx();
                featureExtractor = obj.loadedFeatureExtractors{fileIdx};
            end
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
        
        function idx = getSelectedLoadedFileIdx(obj)
            idxStr = obj.loadedFeatureExtractorsList.Value;
            [~,idx] = ismember(idxStr,obj.loadedFeatureExtractorsList.Items);
        end
        
        function b = isManualMode(obj)
            selectedButton = obj.selectionTypeButtonGroup.SelectedObject;
            b = (selectedButton == obj.selectManuallyRadio);
        end
        
        function handleSelectionTypeChanged(obj,~,~)
            selectedButton = obj.selectionTypeButtonGroup.SelectedObject;
            if selectedButton == obj.selectManuallyRadio
                obj.manualFeatureExtractionPanel.Visible = true;
                obj.loadedFeatureExtractorsList.Visible = false;
            else
                obj.manualFeatureExtractionPanel.Visible = false;
                obj.loadedFeatureExtractorsList.Visible = true;
            end
        end
        
        function handleAddButtonClicked(obj,~,~)
            featureExtractor = obj.getSelectedFeature();
            rangeSelector = RangeSelector();
            axisSelector = AxisSelector();
            windowGetter = Change('window');
            
            chainBuilder = ChainBuilder(windowGetter);
            chainBuilder.addComputer(rangeSelector);
            chainBuilder.addComputer(axisSelector);
            chainBuilder.addComputer(featureExtractor);
            
            computer = chainBuilder.root;
            computer.name = featureExtractor.name;
            obj.computerConfigurator.addComputer(computer);
        end
        
        function handleRemoveButtonClicked(obj,~,~)
            obj.computerConfigurator.removeSelectedComputer();
        end
        
        function fillLoadedFeaturesList(obj)
            obj.loadedFeatureExtractorsList.Items = Helper.generateComputerNamesArray(obj.loadedFeatureExtractors);
        end
        
        function fillDefaultFeaturesList(obj)
            obj.defaultFeaturesList.Items = Helper.generateComputerNamesArray(obj.defaultFeatures);
        end
    end
end