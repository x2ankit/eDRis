% virtual_clinic_app.m
% Layer 1 UI: Virtual Clinic Interface
% This is the programmatic equivalent of the App Designer .mlapp file.
% It provides the interface for the rural nurse to upload images,
% checks image quality using the "Bouncer", and simulates the entire pipeline.

function virtual_clinic_app()
    % Create the main UI figure
    fig = uifigure('Name', 'eDRis - Rural Clinic Dashboard', 'Position', [100 100 800 600]);
    
    % Header Label
    uilabel(fig, 'Text', 'eDRis Rural Clinic Dashboard', ...
        'FontSize', 24, 'FontWeight', 'bold', 'Position', [250 540 400 40]);
    
    % Image Display Axes
    ax = uiaxes(fig, 'Position', [50 150 400 350]);
    title(ax, 'Fundus Image');
    
    % Status Panel
    statusPanel = uipanel(fig, 'Title', 'System Status', 'Position', [500 300 250 200]);
    
    % Status Labels
    lblQuality = uilabel(statusPanel, 'Text', 'Image Quality: Pending', 'Position', [10 140 200 22]);
    lblNetwork = uilabel(statusPanel, 'Text', 'Network Check: Pending', 'Position', [10 100 200 22]);
    lblDiagnosis = uilabel(statusPanel, 'Text', 'AI Diagnosis: Pending', 'Position', [10 60 200 22], 'FontWeight', 'bold');
    lblAction = uilabel(statusPanel, 'Text', 'Action: Pending', 'Position', [10 20 200 22], 'FontColor', 'blue');
    
    % Buttons
    btnUpload = uibutton(fig, 'Text', '1. Upload Image', ...
        'Position', [500 200 250 40], ...
        'ButtonPushedFcn', @(btn,event) uploadImage(ax, lblQuality, lblNetwork, lblDiagnosis, lblAction));
        
    function uploadImage(ax, lblQuality, lblNetwork, lblDiagnosis, lblAction)
        % Let user select image
        [file, path] = uigetfile({'*.jpg;*.png;*.tif', 'Image Files'});
        if isequal(file,0)
            return; % User canceled
        end
        
        fullPath = fullfile(path, file);
        img = imread(fullPath);
        imshow(img, 'Parent', ax);
        
        % Step 1: Check Image Quality (The Bouncer)
        lblQuality.Text = 'Image Quality: Checking...';
        drawnow;
        
        % We call the check_image_quality function
        % For demonstration in UI, we'll assume it returns a struct with isAcceptable
        try
            [isAcceptable, metrics] = check_image_quality(fullPath);
            if ~isAcceptable
                lblQuality.Text = 'Image Quality: REJECTED (Blur/Illum)';
                lblQuality.FontColor = 'red';
                lblAction.Text = 'Action: PLEASE RECAPTURE IMAGE';
                uialert(fig, 'The image is too blurry or poorly lit. Please recapture.', 'Image Rejected');
                return;
            else
                lblQuality.Text = 'Image Quality: ACCEPTED';
                lblQuality.FontColor = 'green';
            end
        catch
            % If check_image_quality isn't fully returning these, we mock success for UI demo
            lblQuality.Text = 'Image Quality: ACCEPTED (Demo)';
            lblQuality.FontColor = 'green';
        end
        
        % Step 2: Simulate Bandwidth Controller
        lblNetwork.Text = 'Network Check: Simulating...';
        drawnow;
        pause(1); % fake delay
        % Call the bandwidth controller
        [payload, ratio] = simulate_bandwidth_controller(img);
        if ratio < 1.0
            lblNetwork.Text = 'Network: 2G/3G (Compression Active)';
            lblNetwork.FontColor = '#D95319'; % Orange
        else
            lblNetwork.Text = 'Network: 4G+ (Transmitting HD)';
            lblNetwork.FontColor = 'green';
        end
        
        % Step 3: Cloud AI Simulation
        lblDiagnosis.Text = 'AI Diagnosis: Processing...';
        drawnow;
        pause(2); % fake delay
        
        % Randomly assign a DR level for the demo
        levels = {'Level 0: Healthy', 'Level 1: Mild', 'Level 2: Moderate', 'Level 3: Severe', 'Level 4: Proliferative'};
        predIdx = randi([1, 5]);
        lblDiagnosis.Text = ['AI Diagnosis: ', levels{predIdx}];
        
        % Auto-Triage Logic
        if predIdx == 1
            lblAction.Text = 'Action: Auto-Generated PDF Sent';
            lblAction.FontColor = 'green';
        else
            lblAction.Text = 'Action: Flagged for Doctor Queue';
            lblAction.FontColor = 'red';
            
            % Generate Grad-CAM Heatmap
            title(ax, 'Grad-CAM Heatmap');
            % For demo, we just apply a colormap overlay since the real model might not be trained yet
            heatmap = ind2rgb(gray2ind(rgb2gray(img), 256), jet(256));
            blended = imlincomb(0.5, double(img)/255, 0.5, heatmap);
            imshow(blended, 'Parent', ax);
            uialert(fig, 'Patient has been added to the doctor''s remote queue with Grad-CAM heatmap.', 'Triage Alert');
        end
    end
end
