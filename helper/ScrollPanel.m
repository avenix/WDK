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
            
            obj.updateSize();
            obj.updatePanelPosition();
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
            
            if sliderPosition(2) < 0
                sliderPosition(2) = 0;
            end
            
            if obj.figure.Position(4) < sliderPosition(4)
                sliderPosition(4) = obj.figure.Position(4);
            end
            
            
            obj.slider = uicontrol(obj.figure,'Style', 'Slider', ...
                'SliderStep', [0.1, 0.5], ...
                'Min', 0, 'Max', 0, 'Value', 0,...
                'Position',sliderPosition);
            obj.slider.Visible = 'Off';
            
            obj.slider.Min = obj.panel.Position(2);
            obj.slider.Max = obj.slider.Min;
            obj.slider.Value = obj.slider.Min;
            
            addlistener(obj.slider, 'Value', 'PostSet',@obj.handleSliderMoved);
        end
        
        function updatePanelPosition(obj)
            pos = obj.panel.Position;
            pos(2) = obj.originalPanelPosition(2) - obj.slider.Value;
            obj.panel.Position = pos;
        end
        
        function updateSize(obj)
            sliderPosition  = obj.slider.Position;
            figurePosition = obj.figure.Position;
            
            if(figurePosition(4) >=  obj.originalFigurePosition(4))
                obj.slider.Visible = 'Off';
                obj.slider.Value = obj.slider.Min;
                
                fprintf('val: %f, min: %f, max: %f\n',obj.slider.Value,obj.slider.Min,obj.slider.Max);
                
                obj.updatePanelPosition();
            else
                
                obj.slider.Visible = 'On';
                
                originalHeightDiff = obj.originalFigurePosition(4) - obj.originalSliderPosition(4);
                sliderPosition(4) = figurePosition(4) - originalHeightDiff;
                obj.slider.Position = sliderPosition;
                
                newValue = obj.originalSliderPosition(4) - sliderPosition(4);
                
                if(obj.slider.Value > newValue)
                    obj.slider.Value = newValue;
                    obj.updatePanelPosition();
                end
                
                fprintf('visible on val: %f, min: %f, max: %f\n',obj.slider.Value,obj.slider.Min,obj.slider.Max);
                
                obj.slider.Max = newValue;
                
            end
        end
        
        function handleSizeChanged(obj,~,~)
            obj.updateSize();
        end
    end
end