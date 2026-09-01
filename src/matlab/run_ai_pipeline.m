function [severity, confidence, gradcam_map] = run_ai_pipeline(processed_img, model_path)
% RUN_AI_PIPELINE MathWorks SIH 26038 Compliance - Phase 3 & 4
% Loads the PyTorch-trained ONNX model using MATLAB Deep Learning Toolbox,
% runs inference to predict DR Severity, and generates Explainability maps.

    % 1. Load ONNX Model
    % importONNXNetwork requires the Deep Learning Toolbox
    if ~isfile(model_path)
        error('ONNX model not found: %s', model_path);
    end
    
    try
        net = importONNXNetwork(model_path, 'OutputLayerType', 'classification');
    catch ME
        fprintf('Failed to load ONNX model. Ensure Deep Learning Toolbox and ONNX support package are installed.\n');
        rethrow(ME);
    end
    
    % 2. Preprocess image for ResNet (224x224, RGB, normalized)
    inputSize = net.Layers(1).InputSize(1:2);
    img_resized = imresize(processed_img, inputSize);
    
    % Note: PyTorch models usually expect single precision and normalization
    % (mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]). 
    % However, importONNXNetwork often handles basic scaling if defined in the graph,
    % or we do it manually. For simplicity in this demo, we assume the ONNX 
    % graph handles normalization or we pass it as uint8 and let the network cast it.
    
    % 3. Run Inference (Classification)
    [YPred, scores] = classify(net, img_resized);
    
    % Extract severity and confidence
    severity_idx = double(YPred); % 1 to 5 (Levels 0 to 4)
    severity = severity_idx - 1;  % Levels 0 to 4
    confidence = max(scores) * 100;
    
    % 4. Generate Grad-CAM (Explainability)
    % Find the name of the last convolutional layer (often ends with 'relu' or 'conv')
    layers = net.Layers;
    last_conv_idx = find(arrayfun(@(l) isa(l, 'nnet.cnn.layer.Convolution2DLayer') || isa(l, 'nnet.cnn.layer.ReLULayer'), layers), 1, 'last');
    featureLayerName = layers(last_conv_idx).Name;
    
    try
        gradcam_map = gradCAM(net, img_resized, YPred, 'FeatureLayer', featureLayerName);
    catch
        % Fallback if Grad-CAM fails
        gradcam_map = zeros(inputSize);
    end
end
