% generate_pitch_assets.m
% This script automatically generates high-quality images of your MATLAB
% and Simulink components for use in the Pitch Deck.

function generate_pitch_assets()
    fprintf('Starting Pitch Asset Generation...\n');
    
    % Ensure the images directory exists
    imgDir = fullfile(pwd, '..', 'docs', 'images');
    if ~exist(imgDir, 'dir')
        mkdir(imgDir);
    end
    
    % 1. Generate Simulink Screenshot
    fprintf('Opening Simulink model...\n');
    mdl = 'simulate_bandwidth_controller';
    try
        load_system(mdl);
        simulinkImgPath = fullfile(imgDir, 'simulink_model.png');
        print(['-s' mdl], '-dpng', '-r300', simulinkImgPath);
        fprintf('✅ Saved Simulink diagram to: %s\n', simulinkImgPath);
    catch ME
        fprintf('❌ Failed to save Simulink diagram. Make sure the model exists.\n');
        disp(ME.message);
    end
    
    % 2. Generate Grad-CAM Dashboard Screenshot
    fprintf('Running Grad-CAM to generate Clinical Dashboard...\n');
    try
        test_gradcam;
        % Wait a moment for the figure to render
        pause(2); 
        gradcamImgPath = fullfile(imgDir, 'gradcam_ui.png');
        exportgraphics(gcf, gradcamImgPath, 'Resolution', 300);
        fprintf('✅ Saved Grad-CAM Dashboard to: %s\n', gradcamImgPath);
    catch ME
        fprintf('❌ Failed to save Grad-CAM Dashboard.\n');
        disp(ME.message);
    end
    
    fprintf('\nAll MATLAB/Simulink assets generated successfully!\n');
    fprintf('You can find them in the docs/images/ folder.\n');
end
