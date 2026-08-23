% generate_gradcam.m
% Generates Grad-CAM explainability heatmaps for Diabetic Retinopathy screening.
% This represents the "White-Box" layer (Layer 4) in the eDRis architecture,
% allowing remote ophthalmologists to quickly trust and validate the AI's diagnosis.

function [heatmap, overlay, predictedClass, confidence] = generate_gradcam(net, imgPath)
    % 1. Read and preprocess the image
    try
        img = imread(imgPath);
    catch
        error('Could not read image file: %s', imgPath);
    end
    
    % Extract expected input size from the network (e.g., 224x224 for ResNet-50)
    inputSize = net.Layers(1).InputSize(1:2);
    img_resized = imresize(img, inputSize);
    
    % 2. Get the prediction and confidence score
    [predictedClass, rawScores] = classify(net, img_resized);
    
    % PyTorch exports raw logits, so we apply a Softmax to get probabilities (0-1)
    expScores = exp(rawScores - max(rawScores)); % For numerical stability
    probabilities = expScores / sum(expScores);
    confidence = max(probabilities) * 100;
    
    % 3. Generate the Grad-CAM map
    % MATLAB's gradCAM function automatically identifies the last spatial feature layer.
    % It calculates the gradient of the classification score with respect to the feature map.
    fprintf('Calculating gradient activation maps for class: %s...\n', char(predictedClass));
    try
        scoreMap = gradCAM(net, img_resized, predictedClass);
    catch ME
        error('Failed to generate Grad-CAM. Ensure the Deep Learning Toolbox is installed. Details: %s', ME.message);
    end
    
    % 4. Create the visual heatmap and overlay
    % Normalize the score map to [0, 1] for coloring
    scoreMap = scoreMap - min(scoreMap(:));
    if max(scoreMap(:)) ~= 0
        scoreMap = scoreMap / max(scoreMap(:));
    end
    
    % Convert the normalized score map into a "jet" colored heatmap
    cmap = jet(255);
    heatmap = ind2rgb(uint8(scoreMap * 255), cmap);
    
    % Blend the heatmap with the original image (50% transparency)
    alpha = 0.5;
    overlay = (1 - alpha) * im2double(img_resized) + alpha * heatmap;
    
    % 5. Clinical UI Visualization
    % This simulates what the doctor will see on their dashboard
    figure('Name', 'eDRis: Explainable AI Dashboard', 'NumberTitle', 'off', 'Color', 'w');
    
    subplot(1, 2, 1);
    imshow(img_resized);
    title('Original Preprocessed Image', 'FontSize', 12, 'FontWeight', 'bold');
    
    subplot(1, 2, 2);
    imshow(overlay);
    title(sprintf('Grad-CAM Clinical Evidence\nDiagnosis: %s (%.1f%%)', char(predictedClass), confidence), ...
        'FontSize', 12, 'FontWeight', 'bold', 'Color', [0.8 0 0]);
        
    sgtitle('Automated Diabetic Retinopathy Screening Report', 'FontSize', 16, 'FontWeight', 'bold');
    
    fprintf('Successfully generated explainability report for Doctor Review.\n');
end
