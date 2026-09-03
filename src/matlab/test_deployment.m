% TEST_DEPLOYMENT.M
% Final MathWorks SIH 26038 Compliance Test Script
% Simulates the exact workflow from image capture to final AI output.

clc; clear; close all;

fprintf('=== eDRis MATLAB Deployment Pipeline ===\n\n');

% 1. Pick a test image (Simulating rural clinic capture)
% For testing, we use one of our previously processed/test images or any valid dataset image
img_path = '..\..\datasets\1. Classification - APTOS\train_images\000c1434d8d7.png';

% Fallback if file doesn't exist (just to ensure script doesn't crash if they haven't downloaded it)
if ~isfile(img_path)
    fprintf('Test image not found at %s. Please update the img_path variable to a valid image.\n', img_path);
    return;
end

fprintf('1. Running Phase 1 & 2: Image Quality Gatekeeper...\n');
try
    [clean_img, is_accepted, metrics, msg] = iqa_gatekeeper(img_path);
    fprintf('   -> %s\n', msg);
    fprintf('   -> Blur Metric: %.2f (Threshold 4.49)\n', metrics.blur);
    fprintf('   -> Illumination Metric: %.2f (Thresholds 37.49-92.90)\n\n', metrics.intensity);
catch ME
    fprintf('   -> Error in Gatekeeper: %s\n', ME.message);
    return;
end

if ~is_accepted
    fprintf('Workflow terminated. Image rejected by Gatekeeper.\n');
    return;
end

fprintf('2. Running Phase 3 & 4: Dual AI Engine & XAI...\n');
model_path = '..\..\models\dr_resnet18_merged.onnx'; % Path to your exported ONNX model

if ~isfile(model_path)
    fprintf('   -> Model not found at %s.\n', model_path);
    fprintf('   -> Note: Ensure you export the PyTorch model to .onnx and place it in the models directory to run this block.\n');
else
    try
        [severity, conf, gradcam_map] = run_ai_pipeline(clean_img, model_path);
        
        fprintf('   -> Diagnosis: Level %d (Severity)\n', severity);
        fprintf('   -> Confidence: %.2f%%\n\n', conf);
        
        % Plotting the results
        figure('Name', 'eDRis Clinical Dashboard');
        
        subplot(1,3,1);
        imshow(imread(img_path));
        title('Original Rural Capture');
        
        subplot(1,3,2);
        imshow(clean_img);
        title('Gatekeeper (CLAHE) Cleaned');
        
        subplot(1,3,3);
        imshow(clean_img);
        hold on;
        imagesc(imresize(gradcam_map, [size(clean_img,1) size(clean_img,2)]), 'AlphaData', 0.5);
        colormap jet;
        hold off;
        title(sprintf('Level %d (%.1f%%)', severity, conf));
        
    catch ME
        fprintf('   -> Error running AI Pipeline: %s\n', ME.message);
    end
end

fprintf('=== Deployment Test Complete ===\n');
