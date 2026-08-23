% test_gradcam.m
% Tests the Grad-CAM module on a single test image to visualize explainability.

function test_gradcam(imagePath, modelPath)
    if nargin < 2
        modelPath = fullfile(fileparts(mfilename('fullpath')), '..', 'models', 'dr_resnet50_combined.onnx'); % Robust path
    end
    if nargin < 1
        % Default to a sample image if not provided
        imagePath = fullfile(fileparts(mfilename('fullpath')), '..', 'datasets', 'classification', 'aptos2019', 'train_images', '000c1434d8d7.png');
    end
    
    fprintf('Loading model from %s...\n', modelPath);
    try
        net = importONNXNetwork(modelPath, 'OutputLayerType', 'classification');
    catch ME
        error('Failed to import ONNX model:\n%s\n\nEnsure that you have installed the "Deep Learning Toolbox Converter for ONNX Model Format" add-on in MATLAB.', ME.message);
    end
    
    fprintf('Processing test image: %s...\n', imagePath);
    
    % The generate_gradcam function handles reading the image, 
    % running inference, generating the heatmap, and displaying the dashboard.
    try
        [heatmap, overlay, predictedClass, confidence] = generate_gradcam(net, imagePath);
        fprintf('Successfully completed test. Model predicted %s with %.1f%% confidence.\n', char(predictedClass), confidence);
    catch ME
        error('Error generating Grad-CAM visualization:\n%s', ME.message);
    end
end
