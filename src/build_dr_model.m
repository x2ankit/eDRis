% build_dr_model.m
% Constructs the Deep Learning architecture for DR Severity Grading (Levels 0-4)
% Uses Transfer Learning with ResNet-50, adapted for Medical Imaging classification.

function [lgraph, options] = build_dr_model(numClasses, initialLearnRate)
    if nargin < 1
        numClasses = 5; % 0: No DR, 1: Mild, 2: Moderate, 3: Severe, 4: Proliferative
    end
    if nargin < 2
        initialLearnRate = 1e-4;
    end
    
    fprintf('Loading pre-trained ResNet-50...\n');
    try
        net = resnet50;
    catch
        error('Deep Learning Toolbox Model for ResNet-50 Network is not installed. Please install it via Add-On Explorer.');
    end
    
    lgraph = layerGraph(net);
    
    % Find the names of the layers to replace
    % ResNet-50's final layers are 'fc1000', 'fc1000_softmax', and 'ClassificationLayer_fc1000'
    
    % Define new layers for our specific 5-class medical task
    newFc = fullyConnectedLayer(numClasses, ...
        'Name', 'dr_fc', ...
        'WeightLearnRateFactor', 10, ... % Learn faster on the new medical layer
        'BiasLearnRateFactor', 10);
        
    newSoftmax = softmaxLayer('Name', 'dr_softmax');
    newClassLayer = classificationLayer('Name', 'dr_classification');
    
    % Replace the original ImageNet fully connected layers with our DR layers
    lgraph = replaceLayer(lgraph, 'fc1000', newFc);
    lgraph = replaceLayer(lgraph, 'fc1000_softmax', newSoftmax);
    lgraph = replaceLayer(lgraph, 'ClassificationLayer_fc1000', newClassLayer);
    
    fprintf('Model architecture adapted for %d-class Diabetic Retinopathy classification.\n', numClasses);
    
    % Define robust training options for medical images
    % We use SGDM with momentum, and a step learning rate drop to prevent overshooting minima
    options = trainingOptions('sgdm', ...
        'MiniBatchSize', 32, ...
        'MaxEpochs', 30, ...
        'InitialLearnRate', initialLearnRate, ...
        'LearnRateSchedule', 'piecewise', ...
        'LearnRateDropFactor', 0.1, ...
        'LearnRateDropPeriod', 10, ...
        'Shuffle', 'every-epoch', ...
        'Plots', 'training-progress', ...
        'Verbose', true);
        
    fprintf('Training options configured. Ready for training.\n');
end
