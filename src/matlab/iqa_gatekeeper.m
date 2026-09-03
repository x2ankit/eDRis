function [processed_img, is_accepted, metrics, message] = iqa_gatekeeper(img_path)
% IQA_GATEKEEPER MathWorks SIH 26038 Compliance - Phase 1 & 2
% Evaluates image quality based on statistically derived thresholds 
% from the APTOS 2019 dataset. Rejects blurry images and applies CLAHE 
% rescue to poorly illuminated images.

    % 1. Load the image
    if ~isfile(img_path)
        error('Image file not found: %s', img_path);
    end
    img = imread(img_path);
    
    % Convert to grayscale for metric calculations
    if size(img, 3) == 3
        gray_img = rgb2gray(img);
    else
        gray_img = img;
    end
    
    % 2. Calculate Laplacian Variance (Focus Metric)
    % MUST be calculated before denoising, otherwise the variance drops artificially
    lap = fspecial('laplacian');
    img_lap = imfilter(double(gray_img), lap, 'replicate');
    variance_of_laplacian = var(img_lap(:));
    
    % 1.5 Denoising (SIH Requirement)
    % Apply median filter to remove salt-and-pepper sensor noise
    denoised_img = medfilt2(gray_img, [3 3]);
    
    % 1.7 Field of View (FOV) Validation (SIH Requirement)
    % A valid fundus image should have a large illuminated circular area.
    % We threshold the image to find the retina mask.
    retina_mask = denoised_img > 10; % Background is usually near 0
    fov_ratio = sum(retina_mask(:)) / numel(retina_mask);
    
    % 3. Calculate Mean Pixel Intensity (Illumination Metric)
    mean_intensity = mean2(denoised_img);
    
    % Pre-defined Statistical Thresholds (Derived from Python Script)
    % Adjusted for clinical realism (some referable cases are slightly out of focus)
    BLUR_THRESHOLD = 2.50;
    DARK_THRESHOLD = 37.49;
    BRIGHT_THRESHOLD = 92.90;
    
    % Initialize outputs
    metrics = struct('blur', variance_of_laplacian, 'intensity', mean_intensity);
    processed_img = img;
    
    % 4. Evaluation Logic
    if fov_ratio < 0.20 || fov_ratio > 0.90
        % Reject due to improper FOV (either too small, or a full-bleed non-fundus image like a desktop screenshot)
        is_accepted = false;
        message = sprintf('REJECTED: Invalid Field of View (FOV: %.2f%%). Image does not appear to be a circular retinal scan.', fov_ratio * 100);
        return;
    end
    
    if variance_of_laplacian < BLUR_THRESHOLD
        % Reject immediately due to severe blur
        is_accepted = false;
        message = sprintf('REJECTED: Image is too blurry (Blur: %.2f < %.2f). Please recapture.', variance_of_laplacian, BLUR_THRESHOLD);
        return;
    end
    
    if variance_of_laplacian > 1000
        % Reject random noise, text, or non-retinal images (they have massive edge variance)
        is_accepted = false;
        message = sprintf('REJECTED: Image appears to be random noise or out of context (Variance: %.2f).', variance_of_laplacian);
        return;
    end
    
    if mean_intensity < DARK_THRESHOLD || mean_intensity > BRIGHT_THRESHOLD
        % Borderline Lighting - Rescue via CLAHE
        is_accepted = true;
        message = sprintf('RESCUED: Poor illumination (Intensity: %.2f). Applied CLAHE Enhancement.', mean_intensity);
        
        % Convert to LAB color space for targeted contrast enhancement
        cform2lab = makecform('srgb2lab');
        lab_img = applycform(img, cform2lab);
        
        % Apply CLAHE to the L (Lightness) channel only
        L = lab_img(:,:,1);
        % adapthisteq is MATLAB's native CLAHE implementation (Requires Image Processing Toolbox)
        L_clahe = adapthisteq(L, 'NumTiles', [8 8], 'ClipLimit', 0.01);
        
        % Recombine and convert back to RGB
        lab_img(:,:,1) = L_clahe;
        cform2srgb = makecform('lab2srgb');
        processed_img = applycform(lab_img, cform2srgb);
    else
        % Perfectly gradeable image
        is_accepted = true;
        message = sprintf('ACCEPTED: Image quality is excellent (Blur: %.2f, Intensity: %.2f).', variance_of_laplacian, mean_intensity);
    end
end
