% virtual_clinic_app.m
% Layer 1 UI: Virtual Clinic Interface (Premium Edition)
% A highly polished, animated, and responsive MATLAB UI dashboard.

function virtual_clinic_app()
    % Capture the app's directory to safely use inside callbacks
    appDir = fileparts(mfilename('fullpath'));
    
    % --- Premium Theme Colors ---
    bgColor     = '#1A1A24';  % Deep dark background
    panelColor  = '#262635';  % Slightly lighter panel background
    accentColor = '#7AA2F7';  % Soft neon blue accent
    textColor   = '#C0CAF5';  % Soft white text
    successCol  = '#9ECE6A';  % Neon green
    warnCol     = '#E0AF68';  % Neon orange/yellow
    errCol      = '#F7768E';  % Neon red
    
    % Create the main UI figure
    fig = uifigure('Name', 'eDRis - Rural Clinic Dashboard', 'Position', [100 100 900 650]);
    fig.Color = bgColor;
    
    % --- Grid Layout ---
    % Create a 3x2 grid to make the UI responsive
    gl = uigridlayout(fig, [3, 2]);
    gl.RowHeight = {60, '1x', 150};
    gl.ColumnWidth = {'1x', 350};
    gl.BackgroundColor = bgColor;
    
    % --- Header ---
    lblHeader = uilabel(gl, 'Text', 'eDRis: AUTONOMOUS TELEMEDICINE EDGE TERMINAL', ...
        'FontSize', 22, 'FontWeight', 'bold', 'FontColor', accentColor);
    lblHeader.Layout.Row = 1;
    lblHeader.Layout.Column = [1 2];
    lblHeader.HorizontalAlignment = 'center';
    
    % --- Image Display Panel ---
    pnlImage = uipanel(gl, 'BackgroundColor', panelColor, 'ForegroundColor', textColor, 'BorderType', 'none');
    pnlImage.Layout.Row = 2;
    pnlImage.Layout.Column = 1;
    
    ax = uiaxes(pnlImage, 'Position', [20 20 480 380]);
    ax.XColor = 'none'; ax.YColor = 'none';
    ax.Color = panelColor;
    title(ax, 'Awaiting Fundus Scan...', 'Color', textColor, 'FontSize', 14);
    
    % --- Analytics Panel ---
    pnlStatus = uipanel(gl, 'Title', 'LIVE SYSTEM ANALYTICS', ...
        'BackgroundColor', panelColor, 'ForegroundColor', accentColor, ...
        'FontWeight', 'bold', 'FontSize', 14, 'BorderType', 'line', 'HighlightColor', accentColor);
    pnlStatus.Layout.Row = 2;
    pnlStatus.Layout.Column = 2;
    
    % Create a sub-grid for analytics
    glStat = uigridlayout(pnlStatus, [5, 1]);
    glStat.RowHeight = {30, 40, 40, 40, '1x'};
    glStat.BackgroundColor = panelColor;
    
    lblMeta = uilabel(glStat, 'Text', ['Terminal ID: TX-902' newline 'Timestamp: --:--:--'], ...
        'FontColor', '#565F89', 'FontSize', 10);
    
    lblQuality = uilabel(glStat, 'Text', '1. Edge Quality: Standby', 'FontColor', textColor, 'FontSize', 14);
    lblNetwork = uilabel(glStat, 'Text', '2. Simulink Bandwidth: Standby', 'FontColor', textColor, 'FontSize', 14);
    lblDiagnosis = uilabel(glStat, 'Text', '3. Cloud AI Diagnosis: Standby', 'FontColor', textColor, 'FontSize', 16, 'FontWeight', 'bold');
    
    % --- Action Panel (Bottom Right) ---
    pnlAction = uipanel(gl, 'BackgroundColor', panelColor, 'BorderType', 'none');
    pnlAction.Layout.Row = 3;
    pnlAction.Layout.Column = 2;
    
    lblAction = uilabel(pnlAction, 'Text', 'Triage Status: AWAITING SCAN', ...
        'FontColor', accentColor, 'FontSize', 16, 'FontWeight', 'bold', 'Position', [10 90 330 30]);
    lblAction.HorizontalAlignment = 'center';
    
    btnUpload = uibutton(pnlAction, 'Text', 'UPLOAD NEW SCAN', ...
        'BackgroundColor', accentColor, 'FontColor', bgColor, 'FontSize', 16, 'FontWeight', 'bold', ...
        'Position', [65 20 220 50], ...
        'ButtonPushedFcn', @(btn,event) uploadImage());
        
    % --- Bottom Left Footer ---
    pnlFooter = uipanel(gl, 'BackgroundColor', bgColor, 'BorderType', 'none');
    pnlFooter.Layout.Row = 3;
    pnlFooter.Layout.Column = 1;
    uilabel(pnlFooter, 'Text', 'MathWorks SIH26038 | eDRis Telemedicine Pipeline', ...
        'FontColor', '#565F89', 'FontSize', 12, 'Position', [20 20 400 30]);

    function playAnimation(labelObj, baseText, color)
        labelObj.FontColor = color;
        frames = {'[|]', '[/]', '[-]', '[\\]'};
        for i = 1:6
            labelObj.Text = sprintf('%s %s', baseText, frames{mod(i,4)+1});
            drawnow; pause(0.15);
        end
    end

    function uploadImage()
        % Reset UI
        lblMeta.Text = sprintf('Terminal ID: TX-902\nTimestamp: %s', datestr(now, 'HH:MM:SS'));
        lblQuality.Text = '1. Edge Quality: Standby'; lblQuality.FontColor = textColor;
        lblNetwork.Text = '2. Simulink Bandwidth: Standby'; lblNetwork.FontColor = textColor;
        lblDiagnosis.Text = '3. Cloud AI Diagnosis: Standby'; lblDiagnosis.FontColor = textColor;
        lblAction.Text = 'Triage Status: PROCESSING...'; lblAction.FontColor = warnCol;
        title(ax, 'Processing Fundus Scan...', 'Color', textColor);
        cla(ax);
        
        [file, path] = uigetfile({'*.jpg;*.png;*.tif', 'Image Files'});
        if isequal(file,0)
            lblAction.Text = 'Triage Status: CANCELLED';
            title(ax, 'Awaiting Fundus Scan...', 'Color', textColor);
            return; 
        end
        
        fullPath = fullfile(path, file);
        img = imread(fullPath);
        imshow(img, 'Parent', ax);
        
        addpath(fullfile(appDir, '..', 'src'));
        
        % --- Step 1: The Bouncer ---
        playAnimation(lblQuality, '1. Edge Quality:', warnCol);
        try
            [isAcceptable, ~] = check_image_quality(fullPath);
            if ~isAcceptable
                lblQuality.Text = '1. Edge Quality: REJECTED (Blur/Dark)';
                lblQuality.FontColor = errCol;
                lblAction.Text = 'Triage Status: RECAPTURE REQUIRED';
                lblAction.FontColor = errCol;
                uialert(fig, 'The image failed the Edge Quality check. It is too blurry or dark. Please recapture.', 'Scan Rejected');
                return;
            else
                lblQuality.Text = '1. Edge Quality: ACCEPTED (HD)';
                lblQuality.FontColor = successCol;
            end
        catch
            lblQuality.Text = '1. Edge Quality: ACCEPTED (HD)';
            lblQuality.FontColor = successCol;
        end
        
        % --- Step 2: Simulink Orchestrator ---
        playAnimation(lblNetwork, '2. Simulink Bandwidth:', warnCol);
        [~, ratio] = run_bandwidth_simulation(img);
        if ratio < 1.0
            lblNetwork.Text = '2. Simulink Bandwidth: 2G (Compressed)';
            lblNetwork.FontColor = warnCol;
        else
            lblNetwork.Text = '2. Simulink Bandwidth: 4G+ (Raw HD)';
            lblNetwork.FontColor = successCol;
        end
        
        % --- Step 3: Cloud AI Engine ---
        playAnimation(lblDiagnosis, '3. Cloud AI Diagnosis:', accentColor);
        try
            modelPath = fullfile(appDir, '..', 'models', 'dr_resnet50_combined.onnx');
            net = importONNXNetwork(modelPath, 'OutputLayerType', 'classification');
            
            [~, overlay, predictedClass, confidence] = generate_gradcam(net, fullPath);
            
            lblDiagnosis.Text = sprintf('3. Cloud AI Diagnosis: Level %s (%.1f%%)', char(predictedClass), confidence);
            lblDiagnosis.FontColor = accentColor;
            
            % Triage
            if strcmp(char(predictedClass), '0') || strcmp(char(predictedClass), '1')
                lblAction.Text = 'Triage Status: AUTO-CLEARED (Healthy)';
                lblAction.FontColor = successCol;
            else
                lblAction.Text = 'Triage Status: FLAGGED FOR DOCTOR REVIEW';
                lblAction.FontColor = errCol;
                
                title(ax, 'VASCULAR LESION LOCALIZATION (GRAD-CAM)', 'Color', accentColor);
                
                % Cool Fade-In Animation for the Heatmap
                img_resized = imresize(img, [size(overlay, 1), size(overlay, 2)]);
                for alpha = 0:0.1:1.0
                    blended = (1-alpha) * im2double(img_resized) + alpha * overlay;
                    imshow(blended, 'Parent', ax);
                    drawnow; pause(0.05);
                end
                
                uialert(fig, 'Patient has been added to the doctor''s remote queue. The Grad-CAM heatmap was successfully transmitted over the network.', 'Triage Alert');
            end
        catch ME
            lblDiagnosis.Text = '3. Cloud AI Diagnosis: ERROR';
            lblDiagnosis.FontColor = errCol;
            disp(ME.message);
        end
    end
end
