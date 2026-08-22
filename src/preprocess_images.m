% preprocess_images.m
% This script reads raw fundus images, resizes them, applies CLAHE, and saves them.
% Designed for APTOS 2019 and IDRiD datasets.

function preprocess_images(inputDir, outputDir, targetSize)
    if nargin < 3
        targetSize = [512, 512]; % Default resizing dimension
    end
    
    if ~exist(outputDir, 'dir')
        mkdir(outputDir);
    end
    
    % Get all typical image formats
    imageFiles = [dir(fullfile(inputDir, '*.png')); 
                  dir(fullfile(inputDir, '*.jpeg')); 
                  dir(fullfile(inputDir, '*.jpg'))];
              
    numFiles = length(imageFiles);
    fprintf('Found %d images to process.\n', numFiles);
    
    for i = 1:numFiles
        fileName = imageFiles(i).name;
        filePath = fullfile(inputDir, fileName);
        
        try
            % 1. Read Image
            img = imread(filePath);
            
            % 2. Resize Image
            img_resized = imresize(img, targetSize);
            
            % 3. Extract Green Channel (Best for retinal contrast) or use Lab color space for CLAHE
            % Convert RGB to L*a*b* space to apply CLAHE to luminosity only
            lab_img = rgb2lab(img_resized);
            
            % Extract luminosity channel (L*)
            L = lab_img(:,:,1) / 100; % Scale to [0,1] for adapthisteq
            
            % 4. Apply CLAHE (Contrast Limited Adaptive Histogram Equalization)
            L_clahe = adapthisteq(L, 'NumTiles', [8 8], 'ClipLimit', 0.01);
            
            % Put the enhanced L channel back
            lab_img(:,:,1) = L_clahe * 100;
            
            % Convert back to RGB
            enhanced_img = lab2rgb(lab_img);
            % Convert to uint8 format
            enhanced_img = im2uint8(enhanced_img);
            
            % 5. Save Output
            [~, name, ext] = fileparts(fileName);
            outFileName = sprintf('%s_enhanced%s', name, ext);
            imwrite(enhanced_img, fullfile(outputDir, outFileName));
            
            if mod(i, 100) == 0
                fprintf('Processed %d/%d images...\n', i, numFiles);
            end
            
        catch ME
            warning('Failed to process image %s: %s', fileName, ME.message);
        end
    end
    
    fprintf('Preprocessing complete. Saved to %s\n', outputDir);
end
