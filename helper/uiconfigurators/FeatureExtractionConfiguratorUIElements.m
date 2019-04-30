classdef FeatureExtractionConfiguratorUIElements < handle
    properties
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
        featuresSourceButtonGroup;
        featuresSourceFromFileRadio;
        featuresSourceManuallyRadio;
    end
end