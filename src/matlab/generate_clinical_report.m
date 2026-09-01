function generate_clinical_report(patient_id, orig_img, cleaned_img, gradcam_map, severity, confidence, od_center, fovea_center)
% GENERATE_CLINICAL_REPORT MathWorks SIH 26038 Compliance
% Automatically generates an annotated PDF report for ophthalmologist review.
% Ensures human-in-the-loop validation can happen in under 30 seconds.

    % Create a hidden figure for the report
    fig = figure('Visible', 'off', 'Position', [100, 100, 800, 1000], 'Color', 'w');
    
    % Title Block
    annotation('textbox', [0.1 0.9 0.8 0.1], 'String', ...
        sprintf('eDRis Automated Clinical Report\nPatient ID: %s | Date: %s', patient_id, datestr(now)), ...
        'EdgeColor', 'none', 'HorizontalAlignment', 'center', 'FontSize', 14, 'FontWeight', 'bold');
        
    % 1. Original vs Cleaned Image
    subplot(3, 2, 1);
    imshow(orig_img);
    title('Original Capture');
    
    subplot(3, 2, 2);
    imshow(cleaned_img);
    title('IQA Gatekeeper (CLAHE)');
    
    % 2. XAI Grad-CAM Overlay
    subplot(3, 2, [3 4]);
    imshow(cleaned_img);
    hold on;
    % Overlay Grad-CAM
    cam_resized = imresize(gradcam_map, [size(cleaned_img, 1), size(cleaned_img, 2)]);
    imagesc(cam_resized, 'AlphaData', 0.5);
    colormap jet;
    
    % Overlay Localized Structures if available
    if nargin >= 7 && ~isempty(od_center) && ~isempty(fovea_center)
        plot(od_center(1), od_center(2), 'y+', 'MarkerSize', 15, 'LineWidth', 2);
        plot(fovea_center(1), fovea_center(2), 'm+', 'MarkerSize', 15, 'LineWidth', 2);
        legend('Optic Disc', 'Fovea', 'Location', 'northeast');
    end
    hold off;
    title('AI Lesion Heatmap (Grad-CAM)');
    
    % 3. Automated Diagnosis Text
    diagnosis_text = sprintf(['AI Severity Grading: Level %d\n', ...
                              'Confidence Score: %.1f%%\n\n', ...
                              'Action Recommended:\n'], severity, confidence);
                              
    if severity >= 2 || confidence < 90
        diagnosis_text = [diagnosis_text, 'REFER TO SPECIALIST IMMEDIATELY (High-risk or Low Confidence)'];
    else
        diagnosis_text = [diagnosis_text, 'NO REFERRAL NEEDED (Routine Annual Follow-up)'];
    end
    
    annotation('textbox', [0.1 0.1 0.8 0.2], 'String', diagnosis_text, ...
        'EdgeColor', 'k', 'BackgroundColor', [0.95 0.95 0.95], ...
        'FontSize', 12, 'FontWeight', 'bold');
        
    % Export to PDF
    out_file = sprintf('report_%s.pdf', patient_id);
    exportgraphics(fig, out_file, 'ContentType', 'vector');
    
    close(fig);
    fprintf('Clinical Report generated successfully: %s\n', out_file);
end
