classdef ScrollPanel < handle
    
    properties (Access = private)
        panel;
        slider;
        figure;
        originalFigurePosition;
        originalPanelPosition;
        originalSliderPosition;
    end
    
    properties (Access = public, Constant)
        kSliderPadding = 2;
        kSliderWidth = 15;
    end
    
    methods (Access = public)
        function obj = ScrollPanel(panel,figure)
            
            obj.panel = panel;
            obj.figure = figure;
            obj.panel.Units = 'pixels';
            obj.figure.Units = 'pixels';
            
            figure.SizeChangedFcn = @obj.handleSizeChanged;
            
            obj.originalPanelPosition = obj.panel.Position;
            obj.originalFigurePosition = obj.figure.Position;
            
            obj.addSliderToFigure();
            
            obj.originalSliderPosition = obj.slider.Position;
        end
        
        function handleSliderMoved(obj,~,~)
            obj.updatePanelPosition();
        end
    end
    
    methods (Access = private)
        
        function addSliderToFigure(obj)
            
            sliderPosition = obj.originalPanelPosition;
            sliderPosition(1) = obj.originalPanelPosition(1) + obj.originalPanelPosition(3) + obj.kSliderPadding;
            sliderPosition(3) = obj.kSliderWidth;
            
            obj.slider = uicontrol(obj.figure,'Style', 'Slider', ...
                'SliderStep', [0.1, 0.5], ...
                'Min', 0, 'Max', 0, 'Value', 0,...
                'Position',sliderPosition);
            obj.slider.Visible = 'Off';
            
            addlistener(obj.slider, 'Value', 'PostSet',@obj.handleSliderMoved);
        end
        
        function updatePanelPosition(obj)
            pos = obj.panel.Position;
            pos(2) = obj.originalPanelPosition(2) - obj.slider.Value;
            obj.panel.Position = pos;
        end
        
        function handleSizeChanged(obj,~,~)
            sliderPosition  = obj.slider.Position;
            figurePosition = obj.figure.Position;
            
            if(figurePosition(4) >=  obj.originalFigurePosition(4))
                obj.slider.Visible = 'Off';
                obj.slider.Value = 0;
                obj.updatePanelPosition();
            else
                obj.slider.Visible = 'On';
                
                originalHeightDiff = obj.originalFigurePosition(4) - obj.originalSliderPosition(4);
                sliderPosition(4) = figurePosition(4) - originalHeightDiff;
                obj.slider.Position = sliderPosition;
                
                newMaxValue = obj.originalSliderPosition(4) - sliderPosition(4);
                
                if(obj.slider.Value > newMaxValue)
                    obj.slider.Value = newMaxValue;
                    obj.updatePanelPosition();
                end
                obj.slider.Max = newMaxValue;
            end
        end
    end
end