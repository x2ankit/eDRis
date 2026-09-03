function [severity, confidence, gradcam_map] = run_ai_pipeline(processed_img, model_path)
% RUN_AI_PIPELINE MathWorks SIH 26038 Compliance - Phase 3 & 4
% Loads the PyTorch-trained ONNX model using MATLAB Deep Learning Toolbox,
% runs inference to predict DR Severity, and generates Explainability maps.

    % 1. Load ONNX Model
    if ~isfile(model_path)
        error('ONNX model not found: %s', model_path);
    end
    
    try
        % Use the modern dlnetwork importer required for PyTorch models
        net = importNetworkFromONNX(model_path);
    catch ME
        fprintf('Failed to load ONNX model. Ensure Deep Learning Toolbox and ONNX support package are installed.\n');
        rethrow(ME);
    end
    
    % 2. Preprocess image for ResNet
    inputSize = [224, 224];
    img_resized = imresize(processed_img, inputSize);
    
    % PyTorch Normalization (mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
    img_double = double(img_resized) / 255.0;
    img_norm = zeros(size(img_double));
    img_norm(:,:,1) = (img_double(:,:,1) - 0.485) / 0.229;
    img_norm(:,:,2) = (img_double(:,:,2) - 0.456) / 0.224;
    img_norm(:,:,3) = (img_double(:,:,3) - 0.406) / 0.225;
    
    % Convert to dlarray with SSCB format (Spatial, Spatial, Channel, Batch)
    dlImg = dlarray(single(img_norm), 'SSCB');
    
    % 3. Run Inference
    logits = predict(net, dlImg);
    
    % Convert logits to probabilities using softmax
    probs = exp(extractdata(logits)) ./ sum(exp(extractdata(logits)));
    
    % Extract severity and confidence (0-indexed for DR levels)
    [max_prob, max_idx] = max(probs);
    severity = max_idx - 1;  % Levels 0 to 4
    confidence = max_prob * 100;
    
    % 4. Generate Grad-CAM (Explainability)
    % Find the last convolutional or ReLU layer name
    layers = net.Layers;
    last_conv_idx = find(arrayfun(@(l) isa(l, 'nnet.cnn.layer.Convolution2DLayer') || isa(l, 'nnet.cnn.layer.ReLULayer'), layers), 1, 'last');
    reductionLayerName = layers(end).Name;
    
    try
        if isempty(last_conv_idx)
            % Fallback for some ONNX converted names
            gradcam_map = gradCAM(net, dlImg, max_idx, 'ReductionLayer', reductionLayerName);
        else
            featureLayerName = layers(last_conv_idx).Name;
            gradcam_map = gradCAM(net, dlImg, max_idx, 'FeatureLayer', featureLayerName, 'ReductionLayer', reductionLayerName);
        end
    catch ME
        fprintf('   -> Grad-CAM warning: %s\n', ME.message);
        gradcam_map = zeros(inputSize);
    end
end
