% SETUP_DEMO_FOLDER.M
% Run this script once to automatically create a perfectly labeled
% 'demo_images' folder for your Hackathon presentation.

clc; clear;

demo_dir = fullfile('..', '..', 'datasets', 'demo_images');
train_dir = fullfile('..', '..', 'datasets', '1. Classification - APTOS', 'train_images');
csv_path = fullfile('..', '..', 'datasets', '1. Classification - APTOS', 'train.csv');

if ~exist(demo_dir, 'dir')
    mkdir(demo_dir);
    fprintf('Created directory: %s\n', demo_dir);
end

fprintf('Reading training labels from %s...\n', csv_path);
opts = detectImportOptions(csv_path);
opts.VariableNamingRule = 'preserve';
data = readtable(csv_path, opts);

% Define the severities we want to demo
levels = [0, 1, 2, 3, 4];
names = {'0_Healthy', '1_Mild', '2_Moderate_Referable', '3_Severe_Referable', '4_Proliferative_Referable'};

% Find and copy one perfect example for each severity
for i = 1:length(levels)
    lvl = levels(i);
    idx = find(data.diagnosis == lvl, 1);
    
    if ~isempty(idx)
        img_name = [data.id_code{idx}, '.png'];
        src_path = fullfile(train_dir, img_name);
        
        if isfile(src_path)
            dest_name = sprintf('Demo_%s.png', names{i});
            dest_path = fullfile(demo_dir, dest_name);
            copyfile(src_path, dest_path);
            fprintf('Copied %s -> %s\n', img_name, dest_name);
            
            % Generate a blurry image from the Level 0 image to test Gatekeeper
            if lvl == 0
                fprintf('Generating a synthetic blurry image to test the Quality Gatekeeper...\n');
                img = imread(src_path);
                blurry_img = imgaussfilt(img, 12); % Apply heavy blur
                blur_path = fullfile(demo_dir, 'Demo_Reject_Blurry.png');
                imwrite(blurry_img, blur_path);
                fprintf('Created Demo_Reject_Blurry.png\n');
            end
        else
            fprintf('Warning: Image %s not found.\n', src_path);
        end
    end
end

% Generate an out-of-context image (Random Noise)
noise_img = uint8(rand(1024, 1024, 3) * 255);
noise_path = fullfile(demo_dir, 'Demo_Reject_OutOfContext.png');
imwrite(noise_img, noise_path);
fprintf('Created Demo_Reject_OutOfContext.png\n');

fprintf('\n=== Demo Folder Setup Complete! ===\n');
fprintf('You can now open the Virtual Clinic App and upload these specific images for the judges!\n');
