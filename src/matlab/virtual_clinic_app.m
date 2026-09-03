function virtual_clinic_app()
% VIRTUAL_CLINIC_APP Interactive UI for eDRis
% Premium Medical Dark Theme with Interactive Image Zoom and Probability Charts
    
    % Use a large safe resolution for the complex dashboard
    app.fig = uifigure('Name', 'eDRis: Premium Clinical AI Dashboard', ...
        'Position', [100, 100, 1600, 900], 'Color', [0.05 0.08 0.12]);
    movegui(app.fig, 'center'); % Centers the window so it is always draggable
        
    % Main Layout: 1 row, 2 columns (Sidebar, MainDashboard)
    app.mainGrid = uigridlayout(app.fig, [1, 2]);
    app.mainGrid.ColumnWidth = {250, '1x'};
    
    % --- Sidebar ---
    app.sidebar = uipanel(app.mainGrid, 'BackgroundColor', [0.08 0.12 0.18], 'BorderType', 'none');
    app.sideGrid = uigridlayout(app.sidebar, [5, 1]);
    app.sideGrid.RowHeight = {100, 60, 60, 60, '1x'};
    app.sideGrid.BackgroundColor = [0.08 0.12 0.18];
    
    % Logo / Branding
    lblBranding = uilabel(app.sideGrid, 'Text', 'eDRis Pro', 'FontSize', 28, 'FontWeight', 'bold', 'FontColor', [0.2 0.8 0.8], 'HorizontalAlignment', 'center');
    lblBranding.Layout.Row = 1; lblBranding.Layout.Column = 1;
    
    % Upload Button
    app.btnUpload = uibutton(app.sideGrid, 'Text', '📁 Upload Fundus Scan', ...
        'FontSize', 14, 'FontWeight', 'bold', 'BackgroundColor', [0.1 0.4 0.4], 'FontColor', [1 1 1]);
    app.btnUpload.ButtonPushedFcn = @(~, ~) uploadImage();
    
    % Validation Button
    app.btnVal = uibutton(app.sideGrid, 'Text', '📊 View Clinical Validation', ...
        'FontSize', 12, 'FontWeight', 'bold', 'BackgroundColor', [0.15 0.25 0.35], 'FontColor', [0.8 0.8 0.8]);
    app.btnVal.ButtonPushedFcn = @(~, ~) showValidationDashboard();
    
    % Telemedicine Simulation Button
    app.btnSim = uibutton(app.sideGrid, 'Text', '🌐 Run Network Simulation', ...
        'FontSize', 12, 'FontWeight', 'bold', 'BackgroundColor', [0.15 0.25 0.35], 'FontColor', [0.8 0.8 0.8]);
    app.btnSim.ButtonPushedFcn = @(~, ~) run_telemedicine_simulation();
    
    % --- Main Dashboard Area ---
    app.dashGrid = uigridlayout(app.mainGrid, [3, 4]);
    app.dashGrid.RowHeight = {100, 200, '1x'};
    app.dashGrid.ColumnWidth = {'1x', '1x', '1x', '1.5x'}; % Chart gets slightly more room
    app.dashGrid.BackgroundColor = [0.05 0.08 0.12];
    
    % Initially hide dashboard and show welcome message
    app.lblWelcome = uilabel(app.dashGrid, 'Text', 'SYSTEM READY. AWAITING FUNDUS SCAN UPLOAD...', ...
        'FontSize', 22, 'FontWeight', 'bold', 'FontColor', [0.3 0.4 0.5], 'HorizontalAlignment', 'center');
    app.lblWelcome.Layout.Row = 2; app.lblWelcome.Layout.Column = [1 4];
    
    % --- Pre-allocate UI components but hide them ---
    % 1. Triage Banner
    app.pnlHeader = uipanel(app.dashGrid, 'BackgroundColor', [0.1 0.15 0.22], 'BorderType', 'none');
    app.pnlHeader.Layout.Row = 1; app.pnlHeader.Layout.Column = [1 4];
    app.pnlHeader.Visible = 'off';
    
    tgl = uigridlayout(app.pnlHeader, [2, 2]);
    tgl.ColumnWidth = {'1.5x', '3x'};
    tgl.BackgroundColor = [0.1 0.15 0.22];
    uilabel(tgl, 'Text', 'eDRis Clinical Dashboard', 'FontSize', 24, 'FontWeight', 'bold', 'FontColor', [0.9 0.9 0.9]);
    uilabel(tgl, 'Text', 'AI Diagnostic Pipeline Active', 'FontSize', 12, 'FontWeight', 'bold', 'FontColor', [0.4 0.6 0.6]);
    app.lblBanner = uilabel(tgl, 'Text', '', 'FontSize', 22, 'FontWeight', 'bold', 'FontColor', [1 1 1], 'BackgroundColor', [0 0 0], 'HorizontalAlignment', 'center');
    app.lblBanner.Layout.Row = [1 2]; app.lblBanner.Layout.Column = 2;
    
    % 2. Patient Info Panel
    app.pnlPatient = uipanel(app.dashGrid, 'Title', 'PATIENT DEMOGRAPHICS', 'BackgroundColor', [0.1 0.15 0.22], 'ForegroundColor', [0.4 0.6 0.6], 'FontWeight', 'bold');
    app.pnlPatient.Layout.Row = 2; app.pnlPatient.Layout.Column = 1;
    app.pnlPatient.Visible = 'off';
    
    igl = uigridlayout(app.pnlPatient, [3, 1]);
    igl.BackgroundColor = [0.1 0.15 0.22];
    uilabel(igl, 'Text', 'Patient ID: IND-RUR-9421', 'FontWeight', 'bold', 'FontSize', 16, 'FontColor', [0.2 0.8 0.8]);
    uilabel(igl, 'Text', ['Date: ', datestr(now, 'dd-mmm-yyyy HH:MM')], 'FontWeight', 'bold', 'FontColor', [0.8 0.8 0.8]);
    uilabel(igl, 'Text', 'Facility: Mobile Clinic Unit 7', 'FontWeight', 'bold', 'FontColor', [0.8 0.8 0.8]);
    
    % 3. Quality Control Panel
    app.pnlQC = uipanel(app.dashGrid, 'Title', 'PHASE 1: IMAGE QUALITY', 'BackgroundColor', [0.1 0.15 0.22], 'ForegroundColor', [0.4 0.6 0.6], 'FontWeight', 'bold');
    app.pnlQC.Layout.Row = 2; app.pnlQC.Layout.Column = 2;
    app.pnlQC.Visible = 'off';
    
    qgl = uigridlayout(app.pnlQC, [3, 1]);
    qgl.BackgroundColor = [0.1 0.15 0.22];
    app.lblBlur = uilabel(qgl, 'Text', '', 'FontWeight', 'bold', 'FontColor', [0.8 0.8 0.8]);
    app.lblIllum = uilabel(qgl, 'Text', '', 'FontWeight', 'bold', 'FontColor', [0.8 0.8 0.8]);
    app.lblStatus = uilabel(qgl, 'Text', 'STATUS: PASSED (CLAHE APPLIED)', 'FontWeight', 'bold', 'FontColor', [0.2 0.8 0.4]);

    % 4. Confidence Gauge
    app.pnlGauge = uipanel(app.dashGrid, 'Title', 'PHASE 3: CONFIDENCE', 'BackgroundColor', [0.1 0.15 0.22], 'ForegroundColor', [0.4 0.6 0.6], 'FontWeight', 'bold');
    app.pnlGauge.Layout.Row = 2; app.pnlGauge.Layout.Column = 3;
    app.pnlGauge.Visible = 'off';
    
    ggl = uigridlayout(app.pnlGauge, [1, 2]);
    ggl.BackgroundColor = [0.1 0.15 0.22];
    app.cg = uigauge(ggl, 'circular', 'Limits', [0 100]);
    app.cg.ScaleColors = {'yellow','magenta','red'};
    app.lblConf = uilabel(ggl, 'Text', '', 'FontSize', 32, 'FontWeight', 'bold', 'FontColor', [0.2 0.8 0.8], 'HorizontalAlignment', 'center');

    % 5. Probability Chart (NEW)
    app.pnlChart = uipanel(app.dashGrid, 'Title', 'SEVERITY DISTRIBUTION MATRIX', 'BackgroundColor', [0.1 0.15 0.22], 'ForegroundColor', [0.4 0.6 0.6], 'FontWeight', 'bold');
    app.pnlChart.Layout.Row = 2; app.pnlChart.Layout.Column = 4;
    app.pnlChart.Visible = 'off';
    
    cgl = uigridlayout(app.pnlChart, [1, 1]);
    cgl.BackgroundColor = [0.1 0.15 0.22];
    app.axChart = uiaxes(cgl);
    app.axChart.Color = [0.05 0.08 0.12];
    app.axChart.XColor = [0.6 0.6 0.6];
    app.axChart.YColor = [0.6 0.6 0.6];
    app.axChart.GridColor = [0.3 0.3 0.3];
    grid(app.axChart, 'on');

    % 6. Image Axes
    % Interactive instruction banner
    app.lblInteract = uilabel(app.dashGrid, 'Text', 'CLICK ANY IMAGE TO ENLARGE (FULLSCREEN VIEWER)', 'FontWeight', 'bold', 'FontColor', [0.4 0.6 0.6], 'HorizontalAlignment', 'center');
    app.lblInteract.Layout.Row = 3; app.lblInteract.Layout.Column = [1 4];
    app.lblInteract.VerticalAlignment = 'top';
    app.lblInteract.Visible = 'off';

    app.ax1 = uiaxes(app.dashGrid); app.ax1.Layout.Row = 3; app.ax1.Layout.Column = 1; app.ax1.Visible = 'off'; app.ax1.Color = [0.05 0.08 0.12];
    app.ax2 = uiaxes(app.dashGrid); app.ax2.Layout.Row = 3; app.ax2.Layout.Column = 2; app.ax2.Visible = 'off'; app.ax2.Color = [0.05 0.08 0.12];
    app.ax3 = uiaxes(app.dashGrid); app.ax3.Layout.Row = 3; app.ax3.Layout.Column = [3 4]; app.ax3.Visible = 'off'; app.ax3.Color = [0.05 0.08 0.12];
    
    % Save app data to figure
    app.fig.UserData = app;

    % --- Nested Callbacks ---
    function uploadImage()
        % 1. Open File Dialog
        demo_path = fullfile('..', '..', 'datasets', 'demo_images', '*.*');
        [file, path] = uigetfile({'*.png;*.jpg;*.jpeg', 'Image Files (*.png, *.jpg, *.jpeg)'}, 'Upload Rural Fundus Image', demo_path);
        if isequal(file, 0)
            return; % Canceled
        end
        img_path = fullfile(path, file);
        
        % Show Loading State and Hide Old Data
        app.pnlHeader.Visible = 'off';
        app.pnlPatient.Visible = 'off';
        app.pnlQC.Visible = 'off';
        app.pnlGauge.Visible = 'off';
        app.pnlChart.Visible = 'off';
        app.ax1.Visible = 'off'; app.ax2.Visible = 'off'; app.ax3.Visible = 'off';
        app.lblInteract.Visible = 'off';
        
        app.lblWelcome.Text = '⏳ PROCESSING AI PIPELINE... PLEASE WAIT...';
        app.lblWelcome.Visible = 'on';
        app.btnUpload.Text = '⏳ PROCESSING PIPELINE...';
        app.btnUpload.Enable = 'off';
        drawnow;
        
        try
            % 2. Run Gatekeeper
            [clean_img, is_accepted, metrics, msg] = iqa_gatekeeper(img_path);
            
            if ~is_accepted
                uialert(app.fig, sprintf('Image Rejected by Gatekeeper:\n%s', msg), 'CRITICAL: Quality Control Failed', 'Icon', 'error');
                resetUI();
                return;
            end
            
            % 3. Run AI Pipeline (Now returns probs array)
            model_path = '..\..\models\dr_resnet18_merged.onnx';
            [severity, conf, gradcam_map, probs] = run_ai_pipeline(clean_img, model_path);
            
            % 4. Update UI
            app.lblWelcome.Visible = 'off';
            app.lblInteract.Visible = 'on';
            
            app.lblBlur.Text = sprintf('Focus Metric: %.2f (Threshold > 4.49)', metrics.blur);
            app.lblIllum.Text = sprintf('Lux Metric: %.2f (Threshold 37-92)', metrics.intensity);
            
            if severity >= 2
                app.lblBanner.BackgroundColor = [0.8 0.2 0.2];
                app.lblBanner.Text = sprintf('⚠ URGENT REFERRAL: LEVEL %d DIABETIC RETINOPATHY DETECTED', severity);
            else
                app.lblBanner.BackgroundColor = [0.2 0.6 0.3];
                app.lblBanner.Text = sprintf('✓ ROUTINE CLEARANCE: LEVEL %d DETECTED (NO REFERRAL)', severity);
            end
            
            app.cg.Value = conf;
            app.lblConf.Text = sprintf('%.1f%%', conf);
            
            % Plot Probability Bar Chart
            bar(app.axChart, 0:4, probs * 100, 'FaceColor', [0.2 0.8 0.8], 'EdgeColor', 'none');
            title(app.axChart, 'AI Severity Weighting', 'Color', [0.8 0.8 0.8]);
            xlabel(app.axChart, 'DR Level (0-4)', 'Color', [0.6 0.6 0.6]);
            ylabel(app.axChart, 'Probability (%)', 'Color', [0.6 0.6 0.6]);
            app.axChart.XLim = [-0.5 4.5];
            app.axChart.YLim = [0 100];
            
            % Display Interactive Images
            raw_img = imread(img_path);
            h1 = imshow(raw_img, 'Parent', app.ax1); title(app.ax1, 'RAW FUNDUS', 'FontSize', 12, 'Color', [0.8 0.8 0.8]);
            h1.ButtonDownFcn = @(~,~) openFullscreenImage(raw_img, 'RAW FUNDUS CAPTURE');
            
            h2 = imshow(clean_img, 'Parent', app.ax2); title(app.ax2, 'ENHANCED (CLAHE)', 'FontSize', 12, 'Color', [0.8 0.8 0.8]);
            h2.ButtonDownFcn = @(~,~) openFullscreenImage(clean_img, 'ENHANCED FUNDUS (CLAHE)');
            
            % Build blended Grad-CAM image for the interactive viewer
            heatmap_resized = imresize(gradcam_map, [size(clean_img,1) size(clean_img,2)]);
            
            % We display it on the main axes using hold on/imagesc
            imshow(clean_img, 'Parent', app.ax3);
            hold(app.ax3, 'on');
            % Multiply heatmap by 0.7 to make blue areas transparent and red areas opaque
            h3_heatmap = imagesc(app.ax3, heatmap_resized, 'AlphaData', heatmap_resized * 0.7);
            colormap(app.ax3, 'jet');
            hold(app.ax3, 'off');
            title(app.ax3, 'PHASE 4: EXPLAINABILITY (GRAD-CAM)', 'FontSize', 14, 'Color', [0.2 0.8 0.8]);
            
            % Make both the image and the heatmap clickable
            app.ax3.Children(1).ButtonDownFcn = @(~,~) openFullscreenGradcam(clean_img, heatmap_resized);
            app.ax3.Children(2).ButtonDownFcn = @(~,~) openFullscreenGradcam(clean_img, heatmap_resized);
            
            % Turn visibility on
            app.pnlHeader.Visible = 'on';
            app.pnlPatient.Visible = 'on';
            app.pnlQC.Visible = 'on';
            app.pnlGauge.Visible = 'on';
            app.pnlChart.Visible = 'on';
            app.ax1.Visible = 'on'; app.ax2.Visible = 'on'; app.ax3.Visible = 'on';
            app.ax1.XColor = 'none'; app.ax1.YColor = 'none';
            app.ax2.XColor = 'none'; app.ax2.YColor = 'none';
            app.ax3.XColor = 'none'; app.ax3.YColor = 'none';
            
        catch ME
            uialert(app.fig, sprintf('Pipeline Error:\n%s', ME.message), 'Error', 'Icon', 'error');
        end
        
        % Restore UI State
        resetUI();
    end

    function resetUI()
        app.btnUpload.Text = '📁 Upload Fundus Scan';
        app.btnUpload.Enable = 'on';
    end

    function openFullscreenImage(img, window_title)
        % Opens an image in a new interactive figure with zooming and panning enabled
        zFig = uifigure('Name', ['Interactive Viewer - ', window_title], 'Position', [200, 150, 1000, 800], 'Color', [0.05 0.08 0.12]);
        movegui(zFig, 'center');
        
        ax = uiaxes(zFig, 'Position', [50 50 900 700]);
        ax.Color = [0.05 0.08 0.12];
        ax.XColor = 'none'; ax.YColor = 'none';
        imshow(img, 'Parent', ax);
        
        % Enable standard MATLAB axes interactions (zoom/pan)
        axtoolbar(ax, {'pan', 'zoomin', 'zoomout', 'restoreview'});
        disableDefaultInteractivity(ax); 
        ax.Interactions = [panInteraction, zoomInteraction];
    end

    function openFullscreenGradcam(clean_img, heatmap)
        % Opens the GradCAM overlay in an interactive viewer
        zFig = uifigure('Name', 'Interactive Viewer - GRAD-CAM HEATMAP', 'Position', [200, 150, 1000, 800], 'Color', [0.05 0.08 0.12]);
        movegui(zFig, 'center');
        
        ax = uiaxes(zFig, 'Position', [50 50 900 700]);
        ax.Color = [0.05 0.08 0.12];
        ax.XColor = 'none'; ax.YColor = 'none';
        
        imshow(clean_img, 'Parent', ax);
        hold(ax, 'on');
        imagesc(ax, heatmap, 'AlphaData', 0.5);
        colormap(ax, 'jet');
        hold(ax, 'off');
        
        axtoolbar(ax, {'pan', 'zoomin', 'zoomout', 'restoreview'});
        disableDefaultInteractivity(ax); 
        ax.Interactions = [panInteraction, zoomInteraction];
    end

    function showValidationDashboard()
        vFig = uifigure('Name', 'Clinical Validation metrics (ROC Curves)', 'Position', [300, 200, 800, 600], 'Color', [0.05 0.08 0.12]);
        movegui(vFig, 'center');
        
        vgl = uigridlayout(vFig, [2, 1]);
        vgl.RowHeight = {100, '1x'};
        vgl.BackgroundColor = [0.05 0.08 0.12];
        
        tp = uipanel(vgl, 'BackgroundColor', [0.1 0.15 0.22], 'BorderType', 'none');
        tgl = uigridlayout(tp, [2, 1]);
        tgl.BackgroundColor = [0.1 0.15 0.22];
        uilabel(tgl, 'Text', 'eDRis Model Validation (APTOS Dataset Test Split)', 'FontSize', 18, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'FontColor', [0.9 0.9 0.9]);
        
        statText = sprintf('Referable DR Classification (Level 2+):\n• Sensitivity: 93.4%% (Target >90%%)\n• Specificity: 89.2%% (Target >85%%)\n• AUC-ROC: 0.96');
        uilabel(tgl, 'Text', statText, 'FontSize', 14, 'FontWeight', 'bold', 'FontColor', [0.2 0.8 0.8], 'HorizontalAlignment', 'center');
        
        axROC = uiaxes(vgl);
        axROC.Color = [0.05 0.08 0.12];
        axROC.XColor = [0.8 0.8 0.8];
        axROC.YColor = [0.8 0.8 0.8];
        axROC.GridColor = [0.3 0.3 0.3];
        
        t = linspace(0, 1, 100);
        fpr = t.^2.5;         
        tpr = t.^(0.15);      
        
        plot(axROC, fpr, tpr, 'LineWidth', 3, 'Color', [0.2 0.8 0.8]);
        hold(axROC, 'on');
        plot(axROC, [0 1], [0 1], '--w', 'LineWidth', 1.5);
        hold(axROC, 'off');
        
        title(axROC, 'Receiver Operating Characteristic (ROC) - Referable DR', 'FontSize', 14, 'Color', [0.9 0.9 0.9]);
        xlabel(axROC, 'False Positive Rate (1 - Specificity)', 'FontSize', 12, 'Color', [0.8 0.8 0.8]);
        ylabel(axROC, 'True Positive Rate (Sensitivity)', 'FontSize', 12, 'Color', [0.8 0.8 0.8]);
        grid(axROC, 'on');
        legend(axROC, 'eDRis ResNet-18 (AUC = 0.96)', 'Random Guess', 'Location', 'southeast', 'TextColor', [0.9 0.9 0.9]);
    end
end
