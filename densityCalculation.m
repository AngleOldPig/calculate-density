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