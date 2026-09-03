function render_premium_dashboard(img_path, clean_img, metrics, severity, conf, gradcam_map)
% RENDER_PREMIUM_DASHBOARD Builds a professional, light-themed clinical UI

    % Create main UI Figure
    fig = uifigure('Name', 'eDRis: Explainable AI Diabetic Retinopathy Screening System', ...
        'Position', [100, 100, 1200, 800], 'Color', [0.96 0.96 0.96]);
    
    % Main Grid Layout
    gl = uigridlayout(fig, [3, 3]);
    gl.RowHeight = {100, 120, '1x'};
    gl.ColumnWidth = {'1x', '1x', '1x'};
    gl.BackgroundColor = [0.96 0.96 0.96];
    
    % --- Row 1: Header and Triage Banner ---
    titlePanel = uipanel(gl, 'BackgroundColor', [1 1 1], 'BorderType', 'none');
    titlePanel.Layout.Row = 1;
    titlePanel.Layout.Column = [1 3];
    
    tgl = uigridlayout(titlePanel, [2, 2]);
    tgl.RowHeight = {'1x', '1x'};
    tgl.ColumnWidth = {'1.5x', '2x'};
    tgl.BackgroundColor = [1 1 1];
    
    lblTitle = uilabel(tgl, 'Text', 'eDRis Clinical Dashboard', 'FontSize', 24, 'FontWeight', 'bold');
    lblTitle.Layout.Row = 1; lblTitle.Layout.Column = 1;
    
    lblSub = uilabel(tgl, 'Text', 'Automated Rural DR Screening System (MathWorks SIH 26038)', 'FontSize', 12, 'FontColor', [0.4 0.4 0.4]);
    lblSub.Layout.Row = 2; lblSub.Layout.Column = 1;
    
    % Diagnostic Banner Logic
    if severity >= 2
        bannerColor = [0.85 0.3 0.3]; % Red for referable
        bannerText = sprintf('URGENT REFERRAL REQUIRED: Level %d Diabetic Retinopathy Detected', severity);
    else
        bannerColor = [0.3 0.7 0.3]; % Green for non-referable
        bannerText = sprintf('ROUTINE SCREENING: Level %d Diabetic Retinopathy (No Immediate Referral)', severity);
    end
    
    banner = uilabel(tgl, 'Text', bannerText, 'FontSize', 18, 'FontWeight', 'bold', 'FontColor', [1 1 1], ...
        'BackgroundColor', bannerColor, 'HorizontalAlignment', 'center');
    banner.Layout.Row = [1 2]; banner.Layout.Column = 2;
    
    % --- Row 2: Metrics and Gauge ---
    % Patient Info Panel
    infoPanel = uipanel(gl, 'Title', 'Patient Demographics', 'BackgroundColor', [1 1 1], 'FontWeight', 'bold');
    infoPanel.Layout.Row = 2;
    infoPanel.Layout.Column = 1;
    
    igl = uigridlayout(infoPanel, [3, 1]);
    igl.RowHeight = {'1x', '1x', '1x'};
    igl.BackgroundColor = [1 1 1];
    uilabel(igl, 'Text', 'Patient ID: IND-RUR-9421', 'FontWeight', 'bold', 'FontSize', 14);
    uilabel(igl, 'Text', ['Screening Date: ', datestr(now, 'dd-mmm-yyyy')]);
    uilabel(igl, 'Text', 'Location: Mobile Clinic, Primary Health Centre');
    
    % Quality Control Panel (Gatekeeper)
    qcPanel = uipanel(gl, 'Title', 'Phase 1: Image Quality Assessment', 'BackgroundColor', [1 1 1], 'FontWeight', 'bold');
    qcPanel.Layout.Row = 2;
    qcPanel.Layout.Column = 2;
    
    qgl = uigridlayout(qcPanel, [3, 1]);
    qgl.RowHeight = {'1x', '1x', '1x'};
    qgl.BackgroundColor = [1 1 1];
    uilabel(qgl, 'Text', sprintf('Blur (Laplacian Variance): %.2f (Valid > 4.49)', metrics.blur));
    uilabel(qgl, 'Text', sprintf('Illumination (Mean Intensity): %.2f (Valid 37-92)', metrics.intensity));
    uilabel(qgl, 'Text', 'Status: PASSED & ENHANCED (Adaptive CLAHE)', 'FontWeight', 'bold', 'FontColor', [0.1 0.6 0.1]);

    % AI Confidence Gauge
    gaugePanel = uipanel(gl, 'Title', 'Phase 3: Diagnostic Confidence', 'BackgroundColor', [1 1 1], 'FontWeight', 'bold');
    gaugePanel.Layout.Row = 2;
    gaugePanel.Layout.Column = 3;
    
    ggl = uigridlayout(gaugePanel, [1, 2]);
    ggl.ColumnWidth = {'1x', '1x'};
    ggl.BackgroundColor = [1 1 1];
    
    cg = uigauge(ggl, 'circular', 'Limits', [0 100]);
    cg.Value = conf;
    cg.Layout.Row = 1; cg.Layout.Column = 1;
    
    lblConf = uilabel(ggl, 'Text', sprintf('%.1f%%', conf), 'FontSize', 28, 'FontWeight', 'bold', 'FontColor', [0.2 0.2 0.6]);
    lblConf.HorizontalAlignment = 'center';
    lblConf.Layout.Row = 1; lblConf.Layout.Column = 2;

    % --- Row 3: Images ---
    ax1 = uiaxes(gl);
    ax1.Layout.Row = 3; ax1.Layout.Column = 1;
    ax1.XColor = 'none'; ax1.YColor = 'none';
    imshow(imread(img_path), 'Parent', ax1);
    title(ax1, 'Raw Fundus Capture (Non-Mydriatic)', 'FontSize', 12);
    
    ax2 = uiaxes(gl);
    ax2.Layout.Row = 3; ax2.Layout.Column = 2;
    ax2.XColor = 'none'; ax2.YColor = 'none';
    imshow(clean_img, 'Parent', ax2);
    title(ax2, 'Gatekeeper Standardized Image', 'FontSize', 12);
    
    ax3 = uiaxes(gl);
    ax3.Layout.Row = 3; ax3.Layout.Column = 3;
    ax3.XColor = 'none'; ax3.YColor = 'none';
    
    % Overlay Heatmap
    imshow(clean_img, 'Parent', ax3);
    hold(ax3, 'on');
    imagesc(ax3, imresize(gradcam_map, [size(clean_img,1) size(clean_img,2)]), 'AlphaData', 0.5);
    colormap(ax3, 'jet');
    hold(ax3, 'off');
    
    title(ax3, 'Phase 4: Explainability (Grad-CAM)', 'FontSize', 12);
end
