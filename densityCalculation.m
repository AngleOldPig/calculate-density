classdef densityCalculation < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        FunctionButtonGroup             matlab.ui.container.ButtonGroup
        MoistAirButton                  matlab.ui.control.RadioButton
        NAButton                        matlab.ui.control.RadioButton
        NAAButton                       matlab.ui.control.RadioButton
        ResetButton                     matlab.ui.control.Button
        CalculateButton                 matlab.ui.control.Button
        ambienttemperatureCEditFieldLabel  matlab.ui.control.Label
        ambienttemperatureCEditField    matlab.ui.control.NumericEditField
        relativehumidityEditFieldLabel  matlab.ui.control.Label
        relativehumidityEditField       matlab.ui.control.NumericEditField
        ambientpressurePaEditFieldLabel  matlab.ui.control.Label
        ambientpressurePaEditField      matlab.ui.control.NumericEditField
        FunctionTextAreaLabel           matlab.ui.control.Label
        FunctionTextArea                matlab.ui.control.TextArea
        InputLabel                      matlab.ui.control.Label
        OutPutLabel                     matlab.ui.control.Label
        densitykgm3EditFieldLabel       matlab.ui.control.Label
        densitykgm3EditField            matlab.ui.control.NumericEditField
    end

    methods (Access = private)

        % Button pushed function: CalculateButton
        function CalculateButtonPushed(app, event)
            % AIR_DENSITY calculates density of air
            %  Usage :[ro] = air_density(t,hr,p)
            %  Inputs:   t = ambient temperature ()
            %           hr = relative humidity [%]
            %            p = ambient pressure [Pa]  (1000 mb = 1e5 Pa)
            %  Output:  ro = air density [kg/m3]
            
            %
            %  Refs:
            % 1)'Equation for the Determination of the Density of Moist Air' P. Giacomo  Metrologia 18, 33-40 (1982)
            % 2)'Equation for the Determination of the Density of Moist Air' R. S. Davis Metrologia 29, 67-70 (1992)
            %
            % ver 1.0   06/10/2006    Jose Luis Prego Borges (Sensor & System Group, Universitat Politecnica de Catalunya)
            % ver 1.1   05-Feb-2007   Richard Signell (rsignell@usgs.gov)  Vectorized
            % ver 1.2   27-Dec-2018   Angle OldPig (angleoldpig@gmail.com)
            %-------------------------------------------------------------------------
            
            % Calculate the Ambient temperature
             t = app.ambienttemperatureCEditField.Value;
            T0 = 273.16;         % Triple point of water (aprox. 0)
             T = T0 + t;         % Ambient temperature
            
            %-------------------------------------------------------------------------
            %-------------------------------------------------------------------------
            % 1) Coefficients values
            
             R =  8.314510;           % Molar ideal gas constant   [J/(mol.)]
            Mv = 18.015*10^-3;        % Molar mass of water vapour [kg/mol]
            Ma = 28.9635*10^-3;       % Molar mass of dry air      [kg/mol]
            
            A =  1.2378847*10^-5;    % [^-2]
            B = -1.9121316*10^-2;    % [^-1]
            C = 33.93711047;         %
            D = -6.3431645*10^3;     % []
            
            a0 =  1.58123*10^-6;      % [/Pa]
            a1 = -2.9331*10^-8;       % [1/Pa]
            a2 =  1.1043*10^-10;      % [1/(.Pa)]
            b0 =  5.707*10^-6;        % [/Pa]
            b1 = -2.051*10^-8;        % [1/Pa]
            c0 =  1.9898*10^-4;       % [/Pa]
            c1 = -2.376*10^-6;        % [1/Pa]
             d =  1.83*10^-11;        % [^2/Pa^2]
             e = -0.765*10^-8;        % [^2/Pa^2]
            
             p = app.ambientpressurePaEditField.Value;
            hr = app.relativehumidityEditField.Value;
            
            %-------------------------------------------------------------------------
            % 2) Calculation of the saturation vapour pressure at ambient temperature, in [Pa]
            psv = exp(A.*(T.^2) + B.*T + C + D./T);   % [Pa]
            
            
            %-------------------------------------------------------------------------
            % 3) Calculation of the enhancement factor at ambient temperature and pressure
            fpt = 1.00062 + (3.14*10^-8)*p + (5.6*10^-7)*(t.^2);
            
            
            %-------------------------------------------------------------------------
            % 4) Calculation of the mole fraction of water vapour
            xv = hr.*fpt.*psv.*(1./p)*(10^-2);
            
            
            %-------------------------------------------------------------------------
            % 5) Calculation of the compressibility factor of air
            Z = 1 - ((p./T).*(a0 + a1*t + a2*(t.^2) + (b0+b1*t).*xv + (c0+c1*t).*(xv.^2))) + ((p.^2/T.^2).*(d + e.*(xv.^2)));
            
            
            %-------------------------------------------------------------------------
            % 6) Final calculation of the air density in [kg/m^3]
            ro = (p.*Ma./(Z.*R.*T)).*(1 - xv.*(1-Mv./Ma));
            
            
            %-------------------------------------------------------------------------
            
            app.densitykgm3EditField.Value = ro;
            
        end
    end

    % App initialization and construction
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure
            app.UIFigure = uifigure;
            app.UIFigure.Position = [100 100 640 480];
            app.UIFigure.Name = 'UI Figure';

            % Create FunctionButtonGroup
            app.FunctionButtonGroup = uibuttongroup(app.UIFigure);
            app.FunctionButtonGroup.Title = 'Function';
            app.FunctionButtonGroup.Position = [126 248 123 106];

            % Create MoistAirButton
            app.MoistAirButton = uiradiobutton(app.FunctionButtonGroup);
            app.MoistAirButton.Text = 'Moist Air';
            app.MoistAirButton.Position = [11 60 69 22];
            app.MoistAirButton.Value = true;

            % Create NAButton
            app.NAButton = uiradiobutton(app.FunctionButtonGroup);
            app.NAButton.Text = 'NA';
            app.NAButton.Position = [11 38 39 22];

            % Create NAAButton
            app.NAAButton = uiradiobutton(app.FunctionButtonGroup);
            app.NAAButton.Text = 'NAA';
            app.NAAButton.Position = [11 16 47 22];

            % Create ResetButton
            app.ResetButton = uibutton(app.UIFigure, 'push');
            app.ResetButton.Position = [175 40 100 22];
            app.ResetButton.Text = 'Reset';

            % Create CalculateButton
            app.CalculateButton = uibutton(app.UIFigure, 'push');
            app.CalculateButton.ButtonPushedFcn = createCallbackFcn(app, @CalculateButtonPushed, true);
            app.CalculateButton.Position = [401 40 100 22];
            app.CalculateButton.Text = 'Calculate';

            % Create ambienttemperatureCEditFieldLabel
            app.ambienttemperatureCEditFieldLabel = uilabel(app.UIFigure);
            app.ambienttemperatureCEditFieldLabel.HorizontalAlignment = 'right';
            app.ambienttemperatureCEditFieldLabel.Position = [56 211 135 22];
            app.ambienttemperatureCEditFieldLabel.Text = 'ambient temperature [C]';

            % Create ambienttemperatureCEditField
            app.ambienttemperatureCEditField = uieditfield(app.UIFigure, 'numeric');
            app.ambienttemperatureCEditField.Position = [206 211 100 22];

            % Create relativehumidityEditFieldLabel
            app.relativehumidityEditFieldLabel = uilabel(app.UIFigure);
            app.relativehumidityEditFieldLabel.HorizontalAlignment = 'right';
            app.relativehumidityEditFieldLabel.Position = [78 173 113 22];
            app.relativehumidityEditFieldLabel.Text = 'relative humidity [%]';

            % Create relativehumidityEditField
            app.relativehumidityEditField = uieditfield(app.UIFigure, 'numeric');
            app.relativehumidityEditField.Position = [206 173 100 22];

            % Create ambientpressurePaEditFieldLabel
            app.ambientpressurePaEditFieldLabel = uilabel(app.UIFigure);
            app.ambientpressurePaEditFieldLabel.HorizontalAlignment = 'right';
            app.ambientpressurePaEditFieldLabel.Position = [68 133 123 22];
            app.ambientpressurePaEditFieldLabel.Text = 'ambient pressure [Pa]';

            % Create ambientpressurePaEditField
            app.ambientpressurePaEditField = uieditfield(app.UIFigure, 'numeric');
            app.ambientpressurePaEditField.Position = [206 133 100 22];

            % Create FunctionTextAreaLabel
            app.FunctionTextAreaLabel = uilabel(app.UIFigure);
            app.FunctionTextAreaLabel.HorizontalAlignment = 'right';
            app.FunctionTextAreaLabel.Position = [362 307 52 22];
            app.FunctionTextAreaLabel.Text = 'Function';

            % Create FunctionTextArea
            app.FunctionTextArea = uitextarea(app.UIFigure);
            app.FunctionTextArea.Position = [429 271 150 60];

            % Create densitykgm3EditFieldLabel
            app.densitykgm3EditFieldLabel = uilabel(app.UIFigure);
            app.densitykgm3EditFieldLabel.HorizontalAlignment = 'right';
            app.densitykgm3EditFieldLabel.Position = [370 190 86 22];
            app.densitykgm3EditFieldLabel.Text = 'density [kg/m3]';

            % Create densitykgm3EditField
            app.densitykgm3EditField = uieditfield(app.UIFigure, 'numeric');
            app.densitykgm3EditField.Position = [471 190 100 22];

            % Create InputLabel
            app.InputLabel = uilabel(app.UIFigure);
            app.InputLabel.FontSize = 40;
            app.InputLabel.FontWeight = 'bold';
            app.InputLabel.Position = [136 388 103 48];
            app.InputLabel.Text = 'Input';

            % Create OutPutLabel
            app.OutPutLabel = uilabel(app.UIFigure);
            app.OutPutLabel.FontSize = 40;
            app.OutPutLabel.FontWeight = 'bold';
            app.OutPutLabel.Position = [401 388 139 48];
            app.OutPutLabel.Text = 'OutPut';
        end
    end

    methods (Access = public)

        % Construct app
        function app = densityCalculation

            % Create and configure components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end