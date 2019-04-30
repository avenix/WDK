%this class retrieves a preprocessing computer from the UI
classdef FeatureExtractionConfigurator < handle
    
    properties (Access = private)
        computerConfigurator;
        
        uiElements FeatureExtractionConfiguratorUIElements;
        
        selectedFeatures;
        currentSelectedFeature;
    end
    
    properties (Access = public)
        defaultFeatures;
        loadedFeatureExtractionFiles;
    end
    
    methods (Access = public)
        function obj = FeatureExtractionConfigurator(defaultFeatures,...
                loadedFeatureExtractionFiles, uiElements)
            
            obj.defaultFeatures = defaultFeatures;
            obj.loadedFeatureExtractionFiles = loadedFeatureExtractionFiles;
            
            obj.uiElements = uiElements;
            
            obj.uiElements.addFeatureButton.ButtonPushedFcn = @obj.handleAddButtonClicked;
            obj.uiElements.removeFeatureButton.ButtonPushedFcn = @obj.handleRemoveButtonClicked;
            obj.uiElements.featuresSourceButtonGroup.SelectionChangedFcn = @obj.handleSelectionTypeChanged;
            obj.uiElements.selectedFeaturesList.ValueChangedFcn = @obj.handleSelectedFeatureChanged;
            obj.uiElements.featureStartRangeEditText.ValueChangedFcn = @obj.handleStartValueChanged;
            obj.uiElements.featureEndRangeEditText.ValueChangedFcn = @obj.handleEndValueChanged;
            obj.uiElements.featureFullSegmentCheckBox.ValueChangedFcn = @obj.handleFullSegmentCheckBoxChanged;
            obj.uiElements.featureAxisEditText.ValueChangedFcn = @obj.handleAxisValueChanged;
            
            
            obj.selectedFeatures = [];
            if ~isempty(obj.loadedFeatureExtractionFiles)
                obj.fillLoadedFeaturesList();
                obj.uiElements.loadedFeatureExtractorsList.Value = obj.uiElements.loadedFeatureExtractorsList.Items{1};
            end
            
            if ~isempty(obj.defaultFeatures)
                obj.reloadUI();
            end
        end
        
        function reloadUI(obj)
            obj.fillDefaultFeaturesList();
        end
        
        function featureExtractor = createFeatureExtractorWithUIParameters(obj)
            if obj.isManualFeatureSelectionMode()
                featureExtractor = FeatureExtractor(obj.selectedFeatures);
            else
                fileIdx = obj.getSelectedLoadedFileIdx();
                featureExtractionFile = obj.loadedFeatureExtractionFiles{fileIdx};
                featureExtractor = DataLoader.LoadComputer(featureExtractionFile);
            end
        end
        
        function idx = getDefaultSelectedFeatureIdx(obj)
            idxStr = obj.uiElements.defaultFeaturesList.Value;
            [~,idx] = ismember(idxStr,obj.uiElements.defaultFeaturesList.Items);
        end
        
        function feature = getDefaultSelectedFeature(obj)
            idx = obj.getDefaultSelectedFeatureIdx();
            feature = obj.defaultFeatures{idx};
        end
        
        function idx = getSelectedFeatureIdx(obj)
            idxStr = obj.uiElements.selectedFeaturesList.Value;
            [~,idx] = ismember(idxStr,obj.uiElements.selectedFeaturesList.Items);
        end
        
        function feature = getSelectedFeature(obj)
            if isempty(obj.uiElements.selectedFeaturesList.Items)
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
                    obj.uiElements.featureStartRangeEditText.Visible = false;
                    obj.uiElements.featureEndRangeEditText.Visible = false;
                    obj.uiElements.featureFullSegmentCheckBox.Value = true;
                else
                    obj.uiElements.featureStartRangeEditText.Visible = true;
                    obj.uiElements.featureEndRangeEditText.Visible = true;
                    obj.uiElements.featureFullSegmentCheckBox.Value = false;
                    obj.uiElements.featureStartRangeEditText.Value = rangeSelector.rangeStart;
                    obj.uiElements.featureEndRangeEditText.Value = rangeSelector.rangeEnd;
                end
                obj.uiElements.featureAxisEditText.Value = Helper.arrayToString(axisSelector.axes,' ');
            end
        end
        
        function updateCurrentSelectedFeatureName(obj)
            idx = obj.getSelectedFeatureIdx();
            featureExtractor = obj.selectedFeatures{idx};
            obj.uiElements.selectedFeaturesList.Items{idx} = FeatureExtractionConfigurator.StringForFeature(featureExtractor);
            obj.uiElements.selectedFeaturesList.Value = obj.uiElements.selectedFeaturesList.Items{idx};
        end
        
        function addFeatureToSelectedList(obj, computer)
            obj.selectedFeatures{end+1} = computer;
            obj.uiElements.selectedFeaturesList.Items{end+1} = FeatureExtractionConfigurator.StringForFeature(computer);
            obj.uiElements.selectedFeaturesList.Value = obj.uiElements.selectedFeaturesList.Items(end);
            obj.currentSelectedFeature = computer;
            obj.updateSelectedFeatureUI();
        end
        
        function idx = getSelectedLoadedFileIdx(obj)
            idxStr = obj.uiElements.loadedFeatureExtractorsList.Value;
            [~,idx] = ismember(idxStr,obj.uiElements.loadedFeatureExtractorsList.Items);
        end
        
        function b = isManualFeatureSelectionMode(obj)
            selectedButton = obj.uiElements.featuresSourceButtonGroup.SelectedObject;
            b = (selectedButton == obj.uiElements.featuresSourceManuallyRadio);
        end
        
        function updateSegmentRangeVisibility(obj)
            visible = ~obj.uiElements.featureFullSegmentCheckBox.Value;
            obj.uiElements.featureStartRangeEditText.Visible = visible;
            obj.uiElements.featureEndRangeEditText.Visible = visible;
        end
        
        function handleSelectionTypeChanged(obj,~,~)
            if obj.isManualFeatureSelectionMode()
                obj.uiElements.manualFeatureExtractionPanel.Visible = true;
                obj.uiElements.loadedFeatureExtractorsList.Visible = false;
            else
                obj.uiElements.manualFeatureExtractionPanel.Visible = false;
                obj.uiElements.loadedFeatureExtractorsList.Visible = true;
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
                obj.uiElements.selectedFeaturesList.Value = obj.uiElements.selectedFeaturesList.Items{1};
                obj.currentSelectedFeature = obj.selectedFeatures{1};
            end
        end
        
        function fillLoadedFeaturesList(obj)
            obj.uiElements.loadedFeatureExtractorsList.Items = obj.loadedFeatureExtractionFiles;
        end
        
        function fillDefaultFeaturesList(obj)
            obj.uiElements.defaultFeaturesList.Items = Helper.generateComputerNamesArray(obj.defaultFeatures);
        end
        
        function handleSelectedFeatureChanged(obj,~,~)
            obj.currentSelectedFeature = obj.getSelectedFeature();
            obj.updateSelectedFeatureUI();
        end
        
        function handleStartValueChanged(obj,~,~)
            obj.currentSelectedFeature = obj.getSelectedFeature();
            
            if ~isempty(obj.currentSelectedFeature)
                rangeSelector = obj.currentSelectedFeature.root.nextComputers{1};
                rangeSelector.rangeStart = obj.uiElements.featureStartRangeEditText.Value;
                obj.updateCurrentSelectedFeatureName();
            end
        end
        
        function handleEndValueChanged(obj,~,~)
            obj.currentSelectedFeature = obj.getSelectedFeature();
            
            if ~isempty(obj.currentSelectedFeature)
                rangeSelector = obj.currentSelectedFeature.root.nextComputers{1};
                rangeSelector.rangeEnd = obj.uiElements.featureEndRangeEditText.Value;
                obj.updateCurrentSelectedFeatureName();
            end
        end
        
        function handleAxisValueChanged(obj,~,~)
            obj.currentSelectedFeature = obj.getSelectedFeature();
            
            if ~isempty(obj.currentSelectedFeature)
                axisSelector = obj.currentSelectedFeature.root;
                axisSelector.axes = str2num(obj.uiElements.featureAxisEditText.Value);
                obj.updateCurrentSelectedFeatureName();
            end
        end
        
        function handleFullSegmentCheckBoxChanged(obj,~,~)
            obj.updateSegmentRangeVisibility();
            
            obj.currentSelectedFeature = obj.getSelectedFeature();
            if ~isempty(obj.currentSelectedFeature)
                rangeSelector = obj.currentSelectedFeature.root.nextComputers{1};
                
                value = obj.uiElements.featureFullSegmentCheckBox.Value;
                if (value)
                    rangeSelector.rangeEnd = [];
                else
                    rangeSelector.rangeEnd = obj.uiElements.featureEndRangeEditText.Value;
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