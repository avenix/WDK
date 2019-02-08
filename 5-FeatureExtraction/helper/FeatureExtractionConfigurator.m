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
        loadedFeatureExtractionFiles;
    end
    
    methods (Access = public)
        function obj = FeatureExtractionConfigurator(defaultFeatures,...
                loadedFeatureExtractionFiles, featuresList,...
                addFeaturesButton,removeFeaturesButton,...
                selectedFeaturesList, computersVariablesTable,...
                loadedFeatureExtractorsList,selectionTypeButtonGroup,...
                selectFromFileRadio,selectManuallyRadio,manualFeatureExtractionPanel)
            
            obj.defaultFeatures = defaultFeatures;
            obj.loadedFeatureExtractionFiles = loadedFeatureExtractionFiles;
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
            
            if ~isempty(obj.loadedFeatureExtractionFiles)
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
                featureExtractionFile = obj.loadedFeatureExtractionFiles{fileIdx};
                featureExtractor = DataLoader.LoadComputer(featureExtractionFile);
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
            
            chainBuilder = ChainBuilder(RangeSelector());
            chainBuilder.addComputer(AxisSelector());
            chainBuilder.addComputer(featureExtractor);
            
            computer = chainBuilder.root;
            computer.name = featureExtractor.name;
            obj.computerConfigurator.addComputer(computer);
        end
        
        function handleRemoveButtonClicked(obj,~,~)
            obj.computerConfigurator.removeSelectedComputer();
        end
        
        function fillLoadedFeaturesList(obj)
            obj.loadedFeatureExtractorsList.Items = obj.loadedFeatureExtractionFiles;
        end
        
        function fillDefaultFeaturesList(obj)
            obj.defaultFeaturesList.Items = Helper.generateComputerNamesArray(obj.defaultFeatures);
        end
    end
end