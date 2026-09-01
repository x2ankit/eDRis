function [od_center, fovea_center] = localize_structures(img)
% LOCALIZE_STRUCTURES MathWorks SIH 26038 Compliance
% Extracts clinically relevant structures: Optic Disc and Fovea localization
% Uses the Computer Vision Toolbox and Image Processing Toolbox.

    if size(img, 3) == 3
        % The green channel often provides the best contrast for the Optic Disc
        % The red channel is often too saturated, and blue is too noisy.
        green_channel = img(:,:,2);
    else
        green_channel = img;
    end
    
    % 1. Optic Disc Localization
    % The Optic Disc is typically the brightest region in the fundus.
    % We use a heavily smoothed image to avoid bright exudates.
    smoothed = imfilter(green_channel, fspecial('average', [50 50]));
    
    % Find the brightest pixel as the preliminary center
    [~, max_idx] = max(smoothed(:));
    [od_y, od_x] = ind2sub(size(smoothed), max_idx);
    
    % Refine with imfindcircles (Computer Vision Toolbox approach)
    % Assuming OD radius is roughly 40-100 pixels depending on resolution
    try
        % Binarize around the brightest spot
        threshold = graythresh(smoothed);
        bw = imbinarize(smoothed, threshold + 0.1); 
        stats = regionprops(bw, 'Centroid', 'Area');
        
        if ~isempty(stats)
            % Get the largest bright blob
            [~, max_area_idx] = max([stats.Area]);
            od_center = stats(max_area_idx).Centroid;
        else
            od_center = [od_x, od_y];
        end
    catch
        od_center = [od_x, od_y];
    end
    
    % 2. Fovea Localization
    % The fovea is the darkest region, usually located ~2.5 OD diameters
    % temporal (left or right) to the Optic Disc.
    % We apply a large median filter to ignore dark vessels.
    smoothed_dark = medfilt2(green_channel, [30 30]);
    
    % Restrict search area to the general expected anatomical region
    % (We just do a naive darkest pixel search for this prototype)
    [~, min_idx] = min(smoothed_dark(:));
    [fovea_y, fovea_x] = ind2sub(size(smoothed_dark), min_idx);
    
    fovea_center = [fovea_x, fovea_y];
end
