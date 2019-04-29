classdef AssessmentValidationConfigurator < handle
    properties (Access = private)
        uiElements AssessmentValidationConfiguratorUIElements;
        fileNames;
    end
    
    methods (Access = public)
        function obj = AssessmentValidationConfigurator(uiElements)
            obj.uiElements = uiElements;
            
            uiElements.validationTypeRadioButtonGroup.SelectionChangedFcn = @obj.handleValidationTypeChanged;
            uiElements.selectAllTrainingCheckBox.ValueChangedFcn = @obj.handleSelectAllFilesTrainingCheckBoxValueChanged;
            uiElements.selectAllTestingCheckBox.ValueChangedFcn = @obj.handleSelectAllFilesTestingCheckBoxValueChanged;
            uiElements.moveRightButton.ButtonPushedFcn = @obj.handleMoveRightButtonPushed;
            uiElements.moveLeftButton.ButtonPushedFcn = @obj.handleMoveLeftButtonPushed;
        end
        
        function populateFileLists(obj,fileNames)
            obj.uiElements.trainFilesList.Items = fileNames';
            obj.uiElements.trainFilesList.Value = obj.uiElements.trainFilesList.Items;
            obj.uiElements.testFilesList.Items = {};
            obj.fileNames = fileNames;
        end
        
        function validator = createValidatorWithUIParameters(obj)
            if obj.isHoldOutValidation()
                validator = HoldOutValidator();
                [~,trainIndices] = ismember(obj.uiElements.trainFilesList.Value, obj.fileNames);
                [~,testIndices] = ismember(obj.uiElements.testFilesList.Value, obj.fileNames);
                
                validator.trainIndices = trainIndices;
                validator.testIndices = testIndices;
            else
                validator = LeaveOneOutCrossValidator();
            end
        end
        
        function testFileNameIndices = getTestFileNameIdxs(obj)
            if obj.isHoldOutValidation()
                [~,testFileNameIndices] = ismember(obj.uiElements.testFilesList.Value, obj.fileNames);
            else
                testFileNameIndices = 1:length(obj.fileNames);
            end
        end
        
        function valid = isValidConfiguration(obj)
            valid = true;
            if(isempty(obj.uiElements.trainFilesList.Value) || (obj.isHoldOutValidation() && isempty(obj.uiElements.testFilesList.Value)))
                valid = false;
            end
        end
        
        function isHoldout = isHoldOutValidation(obj)
            isHoldout = obj.uiElements.holdoutRadio.Value;
        end
    end
    
    methods (Access = private)
        
        function selectedFilesStr = popSelectedFilesFromList(~,list)
            selectedFilesStr = list.Value;
            [~,selectedFileIdxs] = ismember(selectedFilesStr,list.Items);
            listIndices = setdiff(1:length(list.Items),selectedFileIdxs);
            list.Items = list.Items(listIndices);
        end
        
        function list = pushFilesToList(~,files,list)
            nItems = length(list.Items);
            nFiles = length(files);
            list.Items(nItems + 1:nItems + nFiles) = files;
        end
        
        %% handles
        function handleSelectAllFilesTrainingCheckBoxValueChanged(obj,~,~)
            value = obj.uiElements.selectAllTrainingCheckBox.Value;
            if(value == true)
                obj.uiElements.trainFilesList.Value = obj.uiElements.trainFilesList.Items;
            end
        end
        
        function handleSelectAllFilesTestingCheckBoxValueChanged(obj,~,~)
            value = obj.uiElements.selectAllTestingCheckBox.Value;
            
            if(value == true)                
                obj.uiElements.testFilesList.Value = obj.uiElements.testFilesList.Items;
            end
        end
        
        function handleValidationTypeChanged(obj,~,~)
            selectedButton = obj.uiElements.validationTypeRadioButtonGroup.SelectedObject;
            if(selectedButton == obj.uiElements.holdoutRadio)
                obj.uiElements.moveRightButton.Visible = true;
                obj.uiElements.moveLeftButton.Visible = true;
                obj.uiElements.testFilesList.Visible = true;
                obj.uiElements.selectAllTestingCheckBox.Visible = true;
            else
                nTestItems = length(obj.uiElements.testFilesList.Items);
                if nTestItems > 0
                    obj.uiElements.trainFilesList.Items(end+1:end+nTestItems) = obj.uiElements.testFilesList.Items;
                end
                obj.uiElements.moveRightButton.Visible = false;
                obj.uiElements.moveLeftButton.Visible = false;
                obj.uiElements.testFilesList.Visible = false;
                obj.uiElements.selectAllTestingCheckBox.Visible = false;
            end
        end
        
        function handleMoveRightButtonPushed(obj,~,~)
            selectedFilesStr = obj.popSelectedFilesFromList(obj.uiElements.trainFilesList);
            obj.pushFilesToList(selectedFilesStr,obj.uiElements.testFilesList);
        end
        
        % Button pushed function: moveFileLeftButton
        function handleMoveLeftButtonPushed(obj,~,~)
            selectedFileStr = obj.popSelectedFilesFromList(obj.uiElements.testFilesList);
            obj.pushFilesToList(selectedFileStr,obj.uiElements.trainFilesList);
        end
    end
end