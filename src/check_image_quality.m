% check_image_quality.m
% This represents the "Bouncer" layer at the Virtual Edge.
% It evaluates if a raw image is blurry or too dark/bright before uploading.

function [isAcceptable, metrics] = check_image_quality(imagePath)
    try
        img = imread(imagePath);
        if size(img, 3) == 3
            gray_img = rgb2gray(img);
        else
            gray_img = img;
        end
        
        % 1. Measure Blur (Variance of Laplacian)
        % A low variance indicates fewer edges, hence a blurry image.
        laplacian_filter = fspecial('laplacian', 0.2);
        laplacian_img = imfilter(double(gray_img), laplacian_filter, 'replicate');
        blur_score = var(laplacian_img(:));
        
        % 2. Measure Illumination
        % Check if the image is too dark or washed out based on mean intensity
        mean_intensity = mean(gray_img(:));
        
        % Thresholds (tuned specifically for Fundus images)
        BLUR_THRESHOLD = 5.0; % Retinal images have large smooth areas, so variance is naturally lower
        MIN_INTENSITY = 15.0;   % Fundus images have large black masks, lowering the mean intensity
        MAX_INTENSITY = 220.0;  % Too bright
        
        isBlurry = blur_score < BLUR_THRESHOLD;
        isPoorlyLit = (mean_intensity < MIN_INTENSITY) || (mean_intensity > MAX_INTENSITY);
        
        % Determine final acceptability
        isAcceptable = ~(isBlurry || isPoorlyLit);
        
        % Return metrics for logging or debugging
        metrics.blur_score = blur_score;
        metrics.mean_intensity = mean_intensity;
        metrics.isBlurry = isBlurry;
        metrics.isPoorlyLit = isPoorlyLit;
        
        if ~isAcceptable
            fprintf('Image %s REJECTED: ', imagePath);
            if isBlurry
                fprintf('Too Blurry (Score: %.2f) ', blur_score);
            end
            if isPoorlyLit
                fprintf('Poor Lighting (Mean Intensity: %.2f)', mean_intensity);
            end
            fprintf('\n');
        else
            fprintf('Image %s ACCEPTED.\n', imagePath);
        end
        
    catch ME
        warning('Error evaluating image quality: %s', ME.message);
        isAcceptable = false;
        metrics = struct();
    end
end
