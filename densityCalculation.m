classdef densityCalculation < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                  matlab.ui.Figure
        ResetButton               matlab.ui.control.Button
        CalculateButton           matlab.ui.control.Button
        FunctionButtonGroup       matlab.ui.container.ButtonGroup
        MoistAirButton            matlab.ui.control.RadioButton
        NAButton                  matlab.ui.control.RadioButton
        NAAButton                 matlab.ui.control.RadioButton
        ambienttemperatureCEditFieldLabel  matlab.ui.control.Label
        t                         matlab.ui.control.NumericEditField
        relativehumidityLabel     matlab.ui.control.Label
        hr                        matlab.ui.control.NumericEditField
        ambientpressurePaEditFieldLabel  matlab.ui.control.Label
        p                         matlab.ui.control.NumericEditField
        densitykgm3TextAreaLabel  matlab.ui.control.Label
        ro                        matlab.ui.control.TextArea
        FunctionTextAreaLabel     matlab.ui.control.Label
        FunctionTextArea          matlab.ui.control.TextArea
    end

    
    methods (Access = private)
        
        
        function [ro] = air_density(app.t.Value, app.hr.Value, app.p.Value)
        % AIR_DENSITY calculates density of air
        %  Usage :[ro] = air_density(t,hr,p)
        %  Inputs:   t = ambient temperature (ºC)
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

        %-------------------------------------------------------------------------
        T0 = 273.16;         % Triple point of water (aprox. 0ºC)
         T = T0 + app.t;         % Ambient temperature in ºKelvin

        %-------------------------------------------------------------------------
        %-------------------------------------------------------------------------
        % 1) Coefficients values

         R =  8.314510;           % Molar ideal gas constant   [J/(mol.ºK)]
        Mv = 18.015*10^-3;        % Molar mass of water vapour [kg/mol]
        Ma = 28.9635*10^-3;       % Molar mass of dry air      [kg/mol]

         A =  1.2378847*10^-5;    % [ºK^-2]
         B = -1.9121316*10^-2;    % [ºK^-1]
         C = 33.93711047;         %
         D = -6.3431645*10^3;     % [ºK]
 
        a0 =  1.58123*10^-6;      % [ºK/Pa]
        a1 = -2.9331*10^-8;       % [1/Pa]
        a2 =  1.1043*10^-10;      % [1/(ºK.Pa)]
        b0 =  5.707*10^-6;        % [ºK/Pa]
        b1 = -2.051*10^-8;        % [1/Pa]
        c0 =  1.9898*10^-4;       % [ºK/Pa]
        c1 = -2.376*10^-6;        % [1/Pa]
         d =  1.83*10^-11;        % [ºK^2/Pa^2]
         e = -0.765*10^-8;        % [ºK^2/Pa^2]

        %-------------------------------------------------------------------------
        % 2) Calculation of the saturation vapour pressure at ambient temperature, in [Pa]
        psv = exp(A.*(T.^2) + B.*T + C + D./T);   % [Pa]


        %-------------------------------------------------------------------------
        % 3) Calculation of the enhancement factor at ambient temperature and pressure
        fpt = 1.00062 + (3.14*10^-8)*app.p + (5.6*10^-7)*(app.t.^2);


        %-------------------------------------------------------------------------
        % 4) Calculation of the mole fraction of water vapour
         xv = app.hr.*fpt.*psv.*(1./app.p)*(10^-2);


        %-------------------------------------------------------------------------
        % 5) Calculation of the compressibility factor of air
          Z = 1 - ((app.p./T).*(a0 + a1*app.t + a2*(app.t.^2) + (b0+b1*app.t).*xv + (c0+c1*app.t).*(xv.^2))) + ((app.p.^2/T.^2).*(d + e.*(xv.^2)));


        %-------------------------------------------------------------------------
        % 6) Final calculation of the air density in [kg/m^3]
         ro = (app.p.*Ma./(Z.*R.*T)).*(1 - xv.*(1-Mv./Ma));    
        
        end
        
    end
    

    % App initialization and construction
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure
            app.UIFigure = uifigure;
            app.UIFigure.Position = [100 100 700 519];
            app.UIFigure.Name = 'UI Figure';

            % Create ResetButton
            app.ResetButton = uibutton(app.UIFigure, 'push');
            app.ResetButton.Position = [198 57 100 22];
            app.ResetButton.Text = 'Reset';

            % Create CalculateButton
            app.CalculateButton = uibutton(app.UIFigure, 'push');
            app.CalculateButton.Position = [377 57 100 22];
            app.CalculateButton.Text = 'Calculate';

            % Create FunctionButtonGroup
            app.FunctionButtonGroup = uibuttongroup(app.UIFigure);
            app.FunctionButtonGroup.Title = 'Function';
            app.FunctionButtonGroup.Position = [138 318 123 106];

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

            % Create ambienttemperatureCEditFieldLabel
            app.ambienttemperatureCEditFieldLabel = uilabel(app.UIFigure);
            app.ambienttemperatureCEditFieldLabel.HorizontalAlignment = 'right';
            app.ambienttemperatureCEditFieldLabel.Position = [64 247 135 22];
            app.ambienttemperatureCEditFieldLabel.Text = 'ambient temperature [C]';

            % Create t
            app.t = uieditfield(app.UIFigure, 'numeric');
            app.t.Position = [214 247 100 22];

            % Create relativehumidityLabel
            app.relativehumidityLabel = uilabel(app.UIFigure);
            app.relativehumidityLabel.HorizontalAlignment = 'right';
            app.relativehumidityLabel.Position = [86 209 113 22];
            app.relativehumidityLabel.Text = 'relative humidity [%]';

            % Create hr
            app.hr = uieditfield(app.UIFigure, 'numeric');
            app.hr.Position = [214 209 100 22];

            % Create ambientpressurePaEditFieldLabel
            app.ambientpressurePaEditFieldLabel = uilabel(app.UIFigure);
            app.ambientpressurePaEditFieldLabel.HorizontalAlignment = 'right';
            app.ambientpressurePaEditFieldLabel.Position = [76 170 123 22];
            app.ambientpressurePaEditFieldLabel.Text = 'ambient pressure [Pa]';

            % Create p
            app.p = uieditfield(app.UIFigure, 'numeric');
            app.p.Position = [214 170 100 22];

            % Create densitykgm3TextAreaLabel
            app.densitykgm3TextAreaLabel = uilabel(app.UIFigure);
            app.densitykgm3TextAreaLabel.HorizontalAlignment = 'right';
            app.densitykgm3TextAreaLabel.Position = [372 224 86 22];
            app.densitykgm3TextAreaLabel.Text = 'density [kg/m3]';

            % Create ro
            app.ro = uitextarea(app.UIFigure);
            app.ro.Position = [473 188 150 60];

            % Create FunctionTextAreaLabel
            app.FunctionTextAreaLabel = uilabel(app.UIFigure);
            app.FunctionTextAreaLabel.HorizontalAlignment = 'right';
            app.FunctionTextAreaLabel.Position = [406 370 52 22];
            app.FunctionTextAreaLabel.Text = 'Function';

            % Create FunctionTextArea
            app.FunctionTextArea = uitextarea(app.UIFigure);
            app.FunctionTextArea.Position = [473 334 150 60];
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