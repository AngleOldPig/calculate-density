classdef densityCalculation < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        TabGroup                        matlab.ui.container.TabGroup
        MoistAirTab                     matlab.ui.container.Tab
        ResetButton                     matlab.ui.control.Button
        CalculateButton                 matlab.ui.control.Button
        FunctionTextAreaLabel           matlab.ui.control.Label
        FunctionTextArea                matlab.ui.control.TextArea
        ambienttemperatureCEditFieldLabel_2  matlab.ui.control.Label
        ambienttemperatureCEditField    matlab.ui.control.NumericEditField
        relativehumidityEditFieldLabel  matlab.ui.control.Label
        relativehumidityEditField       matlab.ui.control.NumericEditField
        ambientpressurePaEditFieldLabel_2  matlab.ui.control.Label
        ambientpressurePaEditField      matlab.ui.control.NumericEditField
        densitykgm3EditFieldLabel       matlab.ui.control.Label
        densitykgm3EditField            matlab.ui.control.NumericEditField
        InputLabel                      matlab.ui.control.Label
        OutputLabel                     matlab.ui.control.Label
        Tab2                            matlab.ui.container.Tab
        Tab3                            matlab.ui.container.Tab
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

        % Button pushed function: ResetButton
        function ResetButtonPushed(app, event)
            app.ambienttemperatureCEditField.Value = 0;
            app.relativehumidityEditField.Value = 0;
            app.ambientpressurePaEditField.Value = 0;
            app.densitykgm3EditField.Value = 0;
        end
    end

    % App initialization and construction
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure
            app.UIFigure = uifigure;
            app.UIFigure.Position = [100 100 671 643];
            app.UIFigure.Name = 'UI Figure';

            % Create TabGroup
            app.TabGroup = uitabgroup(app.UIFigure);
            app.TabGroup.Position = [35 101 604 460];

            % Create MoistAirTab
            app.MoistAirTab = uitab(app.TabGroup);
            app.MoistAirTab.Title = 'Moist Air';

            % Create ResetButton
            app.ResetButton = uibutton(app.MoistAirTab, 'push');
            app.ResetButton.ButtonPushedFcn = createCallbackFcn(app, @ResetButtonPushed, true);
            app.ResetButton.Position = [173 50 100 22];
            app.ResetButton.Text = 'Reset';

            % Create CalculateButton
            app.CalculateButton = uibutton(app.MoistAirTab, 'push');
            app.CalculateButton.ButtonPushedFcn = createCallbackFcn(app, @CalculateButtonPushed, true);
            app.CalculateButton.Position = [348 50 100 22];
            app.CalculateButton.Text = 'Calculate';

            % Create FunctionTextAreaLabel
            app.FunctionTextAreaLabel = uilabel(app.MoistAirTab);
            app.FunctionTextAreaLabel.HorizontalAlignment = 'right';
            app.FunctionTextAreaLabel.Position = [340 236 52 22];
            app.FunctionTextAreaLabel.Text = 'Function';

            % Create FunctionTextArea
            app.FunctionTextArea = uitextarea(app.MoistAirTab);
            app.FunctionTextArea.Position = [425 200 132 60];

            % Create ambienttemperatureCEditFieldLabel_2
            app.ambienttemperatureCEditFieldLabel_2 = uilabel(app.MoistAirTab);
            app.ambienttemperatureCEditFieldLabel_2.HorizontalAlignment = 'right';
            app.ambienttemperatureCEditFieldLabel_2.Position = [39 238 135 22];
            app.ambienttemperatureCEditFieldLabel_2.Text = 'ambient temperature [C]';

            % Create ambienttemperatureCEditField
            app.ambienttemperatureCEditField = uieditfield(app.MoistAirTab, 'numeric');
            app.ambienttemperatureCEditField.Position = [189 238 100 22];

            % Create relativehumidityEditFieldLabel
            app.relativehumidityEditFieldLabel = uilabel(app.MoistAirTab);
            app.relativehumidityEditFieldLabel.HorizontalAlignment = 'right';
            app.relativehumidityEditFieldLabel.Position = [61 200 113 22];
            app.relativehumidityEditFieldLabel.Text = 'relative humidity [%]';

            % Create relativehumidityEditField
            app.relativehumidityEditField = uieditfield(app.MoistAirTab, 'numeric');
            app.relativehumidityEditField.Position = [189 200 100 22];

            % Create ambientpressurePaEditFieldLabel_2
            app.ambientpressurePaEditFieldLabel_2 = uilabel(app.MoistAirTab);
            app.ambientpressurePaEditFieldLabel_2.HorizontalAlignment = 'right';
            app.ambientpressurePaEditFieldLabel_2.Position = [51 160 123 22];
            app.ambientpressurePaEditFieldLabel_2.Text = 'ambient pressure [Pa]';

            % Create ambientpressurePaEditField
            app.ambientpressurePaEditField = uieditfield(app.MoistAirTab, 'numeric');
            app.ambientpressurePaEditField.Position = [189 160 100 22];

            % Create densitykgm3EditFieldLabel
            app.densitykgm3EditFieldLabel = uilabel(app.MoistAirTab);
            app.densitykgm3EditFieldLabel.HorizontalAlignment = 'right';
            app.densitykgm3EditFieldLabel.Position = [325 160 86 22];
            app.densitykgm3EditFieldLabel.Text = 'density [kg/m3]';

            % Create densitykgm3EditField
            app.densitykgm3EditField = uieditfield(app.MoistAirTab, 'numeric');
            app.densitykgm3EditField.Position = [426 160 131 22];

            % Create InputLabel
            app.InputLabel = uilabel(app.MoistAirTab);
            app.InputLabel.FontSize = 36;
            app.InputLabel.FontWeight = 'bold';
            app.InputLabel.Position = [129 318 93 45];
            app.InputLabel.Text = {'Input'; ''};

            % Create OutputLabel
            app.OutputLabel = uilabel(app.MoistAirTab);
            app.OutputLabel.HorizontalAlignment = 'center';
            app.OutputLabel.FontSize = 36;
            app.OutputLabel.FontWeight = 'bold';
            app.OutputLabel.Position = [380 318 123 45];
            app.OutputLabel.Text = {'Output'; ''};

            % Create Tab2
            app.Tab2 = uitab(app.TabGroup);
            app.Tab2.Title = 'Tab2';

            % Create Tab3
            app.Tab3 = uitab(app.TabGroup);
            app.Tab3.Title = 'Tab3';
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