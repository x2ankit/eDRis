% test_gradcam.m
% Tests the Grad-CAM module on a single test image to visualize explainability.

function test_gradcam(imagePath, modelPath)
    if nargin < 2
        modelPath = fullfile(fileparts(mfilename('fullpath')), '..', 'models', 'dr_resnet50.onnx'); % Robust path
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
    try
        img = imread(imagePath);
    catch
        error('Image not found. Please provide a valid path.');
    end
    
    % Resize to standard ResNet input
    inputSize = net.Layers(1).InputSize(1:2);
    imgResized = imresize(img, inputSize);
    
    % Call the generate_gradcam function
    % In the actual build, we would specify the exact feature layer of our fine-tuned model
    % Using 'Activation_49' or similar as the target layer for ResNet-50
    targetLayer = 'activation_49_relu'; 
    heatmap = generate_gradcam(net, imgResized, targetLayer);
    
    % Plot the results side-by-side
    figure('Name', 'eDRis - Grad-CAM Explainability Test');
    
    subplot(1, 2, 1);
    imshow(imgResized);
    title('Original Image (Resized)');
    
    subplot(1, 2, 2);
    % Overlay heatmap
    cmap = jet(255);
    heatmap_colored = ind2rgb(uint8(heatmap * 255), cmap);
    overlay = imlincomb(0.5, double(imgResized)/255, 0.5, heatmap_colored);
    imshow(overlay);
    title('Grad-CAM Heatmap (Lesions Highlighted)');
    
    fprintf('Test complete. Heatmap visualization opened in new window.\n');
end
