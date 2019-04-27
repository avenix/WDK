%this class retrieves a preprocessing computer from the UI
classdef FeatureExtractionConfigurator < handle
    
    properties (Access = private)
        computerConfigurator;
        defaultFeaturesList;
        addFeatureButton;
        removeFeatureButton;
        
        selectedFeaturesList;
        featureStartRangeEditText;
        featureEndRangeEditText;
        featureFullSegmentCheckBox;
        featureAxisEditText;
        
        loadedFeatureExtractorsList;
        
        manualFeatureExtractionPanel;
        selectionTypeButtonGroup;
        selectFromFileRadio;
        selectManuallyRadio;
        
        selectedFeatures;
        currentSelectedFeature;
    end
    
    properties (Access = public)
        defaultFeatures;
        loadedFeatureExtractionFiles;
    end
    
    methods (Access = public)
        function obj = FeatureExtractionConfigurator(defaultFeatures,...
                loadedFeatureExtractionFiles, featuresList,...
                addFeaturesButton,removeFeaturesButton,...
                selectedFeaturesList, featureStartRangeEditText,...
                featureEndRangeEditText,...
                featureFullSegmentCheckBox,...
                featureAxisEditText,...,...
                loadedFeatureExtractorsList,selectionTypeButtonGroup,...
                selectFromFileRadio,selectManuallyRadio,manualFeatureExtractionPanel)
            
            obj.defaultFeatures = defaultFeatures;
            obj.loadedFeatureExtractionFiles = loadedFeatureExtractionFiles;
            obj.defaultFeaturesList = featuresList;
            obj.addFeatureButton = addFeaturesButton;
            obj.removeFeatureButton = removeFeaturesButton;
            obj.selectedFeaturesList = selectedFeaturesList;
            
            obj.featureStartRangeEditText = featureStartRangeEditText;
            obj.featureEndRangeEditText = featureEndRangeEditText;
            obj.featureFullSegmentCheckBox = featureFullSegmentCheckBox;
            obj.featureAxisEditText = featureAxisEditText;
            
            obj.loadedFeatureExtractorsList = loadedFeatureExtractorsList;
            obj.selectionTypeButtonGroup = selectionTypeButtonGroup;
            obj.selectFromFileRadio = selectFromFileRadio;
            obj.selectManuallyRadio = selectManuallyRadio;
            obj.manualFeatureExtractionPanel = manualFeatureExtractionPanel;
            
            obj.addFeatureButton.ButtonPushedFcn = @obj.handleAddButtonClicked;
            obj.removeFeatureButton.ButtonPushedFcn = @obj.handleRemoveButtonClicked;
            obj.selectionTypeButtonGroup.SelectionChangedFcn = @obj.handleSelectionTypeChanged;
            obj.selectedFeaturesList.ValueChangedFcn = @obj.handleSelectedFeatureChanged;
            
            obj.featureStartRangeEditText.ValueChangedFcn = @obj.handleStartValueChanged;
            obj.featureEndRangeEditText.ValueChangedFcn = @obj.handleEndValueChanged;
            obj.featureFullSegmentCheckBox.ValueChangedFcn = @obj.handleFullSegmentCheckBoxChanged;
            obj.featureAxisEditText.ValueChangedFcn = @obj.handleAxisValueChanged;
            
            
            obj.selectedFeatures = [];
            if ~isempty(obj.loadedFeatureExtractionFiles)
                obj.fillLoadedFeaturesList();
                obj.loadedFeatureExtractorsList.Value = obj.loadedFeatureExtractorsList.Items{1};
            end
            
            if ~isempty(obj.defaultFeatures)
                obj.reloadUI();
            end
        end
        
        function reloadUI(obj)
            obj.fillDefaultFeaturesList();
        end
        
        function featureExtractor = createFeatureExtractorWithUIParameters(obj)
            if obj.isManualMode()
                featureExtractor = FeatureExtractor(obj.selectedFeatures);
            else
                fileIdx = obj.getSelectedLoadedFileIdx();
                featureExtractionFile = obj.loadedFeatureExtractionFiles{fileIdx};
                featureExtractor = DataLoader.LoadComputer(featureExtractionFile);
            end
        end
        
        function idx = getDefaultSelectedFeatureIdx(obj)
            idxStr = obj.defaultFeaturesList.Value;
            [~,idx] = ismember(idxStr,obj.defaultFeaturesList.Items);
        end
        
        function feature = getDefaultSelectedFeature(obj)
            idx = obj.getDefaultSelectedFeatureIdx();
            feature = obj.defaultFeatures{idx};
        end
        
        function idx = getSelectedFeatureIdx(obj)
            idxStr = obj.selectedFeaturesList.Value;
            [~,idx] = ismember(idxStr,obj.selectedFeaturesList.Items);
        end
        
        function feature = getSelectedFeature(obj)
            if isempty(obj.selectedFeaturesList.Items)
                feature = [];
            else
                idx = obj.getSelectedFeatureIdx();
                feature = obj.selectedFeatures{idx};
            end
        end
    end
    
    methods(Access = private)
        
        function updateSelectedFeatureUI(obj)
            if ~isempty(obj.currentSelectedFeature)
                axisSelector = obj.currentSelectedFeature.root;
                rangeSelector = axisSelector.nextComputers{1};
                
                if isempty(rangeSelector.rangeEnd)
                    obj.featureStartRangeEditText.Visible = false;
                    obj.featureEndRangeEditText.Visible = false;
                    obj.featureFullSegmentCheckBox.Value = true;
                else
                    obj.featureStartRangeEditText.Visible = true;
                    obj.featureEndRangeEditText.Visible = true;
                    obj.featureFullSegmentCheckBox.Value = false;
                    obj.featureStartRangeEditText.Value = rangeSelector.rangeStart;
                    obj.featureEndRangeEditText.Value = rangeSelector.rangeEnd;
                end
                obj.featureAxisEditText.Value = Helper.arrayToString(axisSelector.axes,' ');
            end
        end
        
        function updateCurrentSelectedFeatureName(obj)
            idx = obj.getSelectedFeatureIdx();
            featureExtractor = obj.selectedFeatures{idx};
            obj.selectedFeaturesList.Items{idx} = FeatureExtractionConfigurator.StringForFeature(featureExtractor);
            obj.selectedFeaturesList.Value = obj.selectedFeaturesList.Items{idx};
        end
        
        function addFeatureToSelectedList(obj, computer)
            obj.selectedFeatures{end+1} = computer;
            obj.selectedFeaturesList.Items{end+1} = FeatureExtractionConfigurator.StringForFeature(computer);
            obj.selectedFeaturesList.Value = obj.selectedFeaturesList.Items(end);
            obj.currentSelectedFeature = computer;
            obj.updateSelectedFeatureUI();
        end
        
        function idx = getSelectedLoadedFileIdx(obj)
            idxStr = obj.loadedFeatureExtractorsList.Value;
            [~,idx] = ismember(idxStr,obj.loadedFeatureExtractorsList.Items);
        end
        
        function b = isManualMode(obj)
            selectedButton = obj.selectionTypeButtonGroup.SelectedObject;
            b = (selectedButton == obj.selectManuallyRadio);
        end
        
        function updateSegmentRangeVisibility(obj)
            visible = obj.featureFullSegmentCheckBox.Value;
            obj.featureStartRangeEditText.Visible = visible;
            obj.featureEndRangeEditText.Visible = visible;
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
            
            axisSelector = AxisSelector();
            rangeSelector = RangeSelector();
            featureExtractor = obj.getDefaultSelectedFeature();
            
            Computer.ComputerWithSequence({axisSelector,rangeSelector,featureExtractor});
            
            compositeComputer = CompositeComputer(axisSelector,featureExtractor);
            compositeComputer.name = featureExtractor.name;
            
            obj.addFeatureToSelectedList(compositeComputer);
        end
        
        function handleRemoveButtonClicked(obj,~,~)
            idx = obj.getSelectedFeatureIdx();
            obj.selectedFeatures(idx) = [];
            obj.selectedFeaturesList.Items(idx) = [];
            obj.selectFirstAddedFeature();
        end
        
        function selectFirstAddedFeature(obj)
            if ~isempty(obj.selectedFeatures)
                obj.selectedFeaturesList.Value = obj.selectedFeaturesList.Items{1};
                obj.currentSelectedFeature = obj.selectedFeatures{1};
            end
        end
        
        function fillLoadedFeaturesList(obj)
            obj.loadedFeatureExtractorsList.Items = obj.loadedFeatureExtractionFiles;
        end
        
        function fillDefaultFeaturesList(obj)
            obj.defaultFeaturesList.Items = Helper.generateComputerNamesArray(obj.defaultFeatures);
        end
        
        function handleSelectedFeatureChanged(obj,~,~)
            obj.currentSelectedFeature = obj.getSelectedFeature();
            obj.updateSelectedFeatureUI();
        end
        
        function handleStartValueChanged(obj,~,~)
            obj.currentSelectedFeature = obj.getSelectedFeature();
            
            if ~isempty(obj.currentSelectedFeature)
                rangeSelector = obj.currentSelectedFeature.root.nextComputers{1};
                rangeSelector.rangeStart = obj.featureStartRangeEditText.Value;
                obj.updateCurrentSelectedFeatureName();
            end
        end
        
        function handleEndValueChanged(obj,~,~)
            obj.currentSelectedFeature = obj.getSelectedFeature();
            
            if ~isempty(obj.currentSelectedFeature)
                rangeSelector = obj.currentSelectedFeature.root.nextComputers{1};
                rangeSelector.rangeEnd = obj.featureEndRangeEditText.Value;
                obj.updateCurrentSelectedFeatureName();
            end
        end
        
        function handleAxisValueChanged(obj,~,~)
            obj.currentSelectedFeature = obj.getSelectedFeature();
            
            if ~isempty(obj.currentSelectedFeature)
                axisSelector = obj.currentSelectedFeature.root;
                axisSelector.axes = str2num(obj.featureAxisEditText.Value);
                obj.updateCurrentSelectedFeatureName();
            end
        end
        
        function handleFullSegmentCheckBoxChanged(obj,~,~)
            obj.updateSegmentRangeVisibility();
            
            obj.currentSelectedFeature = obj.getSelectedFeature();
            if ~isempty(obj.currentSelectedFeature)
                rangeSelector = obj.currentSelectedFeature.root.nextComputers{1};
                
                value = obj.featureFullSegmentCheckBox.Value;
                if (value)
                    rangeSelector.rangeEnd = [];
                else
                    rangeSelector.rangeEnd = obj.featureEndRangeEditText.Value;
                end
                obj.updateCurrentSelectedFeatureName();
            end
        end
        
    end
    
    methods (Access = private, Static)
        function str = StringForFeature(featureComputer)
            axisSelector = featureComputer.root;
            rangeSelector = axisSelector.nextComputers{1};
            featureExtractor = rangeSelector.nextComputers{1};
            
            str = sprintf('%s_%s',featureExtractor.name,Helper.arrayToString(axisSelector.axes,' '));
            if ~isempty(rangeSelector.rangeEnd)
                str = sprintf('%s (%d-%d)',str,rangeSelector.rangeStart,rangeSelector.rangeEnd);
            end
        end
    end
end