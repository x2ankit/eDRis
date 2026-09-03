function run_telemedicine_simulation()
    % MathWorks SIH 26038 Compliance
    % Simulates Telemedicine Bandwidth & Queue Bottlenecks
    
    app.fig = uifigure('Name', 'eDRis: Rural Telemedicine Network Simulation', 'Position', [200, 200, 1000, 650], 'Color', [1 1 1]);
    movegui(app.fig, 'center');
    
    mgl = uigridlayout(app.fig, [3, 1]);
    mgl.RowHeight = {100, 80, '1x'};
    
    % Title Panel
    tgl = uigridlayout(uipanel(mgl, 'BackgroundColor', [1 1 1], 'BorderType', 'none'), [2, 1]);
    uilabel(tgl, 'Text', 'Rural Telemedicine Network Simulation (30-Day Outlook)', 'FontSize', 22, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    uilabel(tgl, 'Text', 'MathWorks SIH 26038: Demonstrating Edge AI solving the 2G/3G bandwidth bottleneck', 'FontSize', 12, 'FontColor', [0.4 0.4 0.4], 'HorizontalAlignment', 'center');
    
    % Control Panel
    cgl = uigridlayout(uipanel(mgl, 'Title', 'Simulation Controls', 'BackgroundColor', [0.95 0.95 0.95]), [1, 3]);
    cgl.ColumnWidth = {200, '1x', 200};
    
    uilabel(cgl, 'Text', 'Rural Internet Speed (Mbps):', 'FontWeight', 'bold', 'HorizontalAlignment', 'right');
    app.sldSpeed = uislider(cgl, 'Limits', [1, 10], 'Value', 2, 'MajorTicks', 1:10);
    app.lblSpeed = uilabel(cgl, 'Text', '2 Mbps (2G/3G)', 'FontWeight', 'bold', 'FontColor', [0.8 0.2 0.2]);
    
    % Graph & Metrics Panel
    ggl = uigridlayout(mgl, [1, 2]);
    ggl.ColumnWidth = {'2x', '1x'};
    
    app.ax = uiaxes(ggl);
    title(app.ax, 'Patient Image Upload Queue (Backlog)');
    xlabel(app.ax, 'Days');
    ylabel(app.ax, 'Patients Waiting in Queue');
    grid(app.ax, 'on');
    
    % Metrics Panel
    pgl = uigridlayout(uipanel(ggl, 'Title', 'Performance Metrics', 'BackgroundColor', [1 1 1]), [5, 1]);
    
    uilabel(pgl, 'Text', 'Scenario A: Cloud AI (Legacy)', 'FontWeight', 'bold', 'FontSize', 14, 'FontColor', [0.7 0.2 0.2]);
    app.lblCloudWait = uilabel(pgl, 'Text', 'Queue Time: Calculating...');
    
    uilabel(pgl, 'Text', 'Scenario B: Edge AI (eDRis)', 'FontWeight', 'bold', 'FontSize', 14, 'FontColor', [0.2 0.6 0.2]);
    app.lblEdgeWait = uilabel(pgl, 'Text', 'Queue Time: Calculating...');
    
    app.lblConclusion = uilabel(pgl, 'Text', '', 'FontWeight', 'bold', 'FontColor', [0.1 0.4 0.8], 'WordWrap', 'on');
    
    % Set callback using nested scoping
    app.sldSpeed.ValueChangedFcn = @(~, ~) updateSimulation();
    
    % Initial Run
    updateSimulation();

    function updateSimulation()
        speed = app.sldSpeed.Value;
        
        if speed <= 2
            app.lblSpeed.Text = sprintf('%.1f Mbps (2G Edge)', speed);
            app.lblSpeed.FontColor = [0.8 0.2 0.2];
        elseif speed <= 5
            app.lblSpeed.Text = sprintf('%.1f Mbps (3G Rural)', speed);
            app.lblSpeed.FontColor = [0.8 0.6 0.1];
        else
            app.lblSpeed.Text = sprintf('%.1f Mbps (4G Fast)', speed);
            app.lblSpeed.FontColor = [0.2 0.6 0.2];
        end
        
        % Simulation Constants
        days = 30;
        patients_per_day = 300; % MathWorks rural clinic average target
        image_size_mb = 5;      % 5 Megabytes per high-res fundus image
        
        % Rural networks do not provide 100% theoretical throughput. 
        % Due to packet loss, latency, and intermittent dropouts, we simulate a realistic efficiency.
        rural_network_efficiency = 0.12; % 12% effective throughput uptime
        
        % Network Math: 1 Mbps = 0.125 Megabytes per second
        % Upload rate per day in Megabytes (Assume 8 hour workday = 28800 seconds)
        mbps_to_mb_per_sec = 0.125;
        work_seconds_per_day = 8 * 3600;
        
        effective_mbps = speed * rural_network_efficiency;
        max_upload_mb_per_day = effective_mbps * mbps_to_mb_per_sec * work_seconds_per_day;
        
        % Upload Capacity (Patients per day)
        upload_capacity_per_day = floor(max_upload_mb_per_day / image_size_mb);
        
        % Run simulation
        queue_cloud = zeros(1, days);
        queue_edge = zeros(1, days);
        
        curr_cloud = 0;
        curr_edge = 0;
        
        for d = 1:days
            % Scenario A: 100% patients must be uploaded to Cloud
            curr_cloud = curr_cloud + patients_per_day;
            curr_cloud = max(0, curr_cloud - upload_capacity_per_day);
            queue_cloud(d) = curr_cloud;
            
            % Scenario B: Edge AI filters out 80%. Only 20% Referable uploaded
            edge_patients = round(patients_per_day * 0.20);
            curr_edge = curr_edge + edge_patients;
            curr_edge = max(0, curr_edge - upload_capacity_per_day);
            queue_edge(d) = curr_edge;
        end
        
        % Plotting
        plot(app.ax, 1:days, queue_cloud, 'LineWidth', 3, 'Color', [0.8 0.3 0.3]);
        hold(app.ax, 'on');
        plot(app.ax, 1:days, queue_edge, 'LineWidth', 3, 'Color', [0.2 0.7 0.2]);
        hold(app.ax, 'off');
        title(app.ax, 'Patient Image Upload Queue (Backlog)');
        xlabel(app.ax, 'Day of the Month');
        ylabel(app.ax, 'Patients Waiting (Backlog)');
        legend(app.ax, 'Scenario A: 100% Upload (Cloud AI)', 'Scenario B: 20% Upload (Edge AI)', 'Location', 'northwest');
        grid(app.ax, 'on');
        
        % Update Text Metrics
        app.lblCloudWait.Text = sprintf('Max Backlog: %d patients', max(queue_cloud));
        app.lblEdgeWait.Text = sprintf('Max Backlog: %d patients', max(queue_edge));
        
        if max(queue_cloud) > 1000
            app.lblCloudWait.FontColor = [0.8 0.2 0.2];
            app.lblConclusion.Text = sprintf('CONCLUSION:\nAt %.1f Mbps, a standard Cloud AI model completely crashes the system resulting in infinite backlog. By using eDRis Edge AI, we maintain near-zero backlog, fulfilling the SIH bandwidth constraint!', speed);
        else
            app.lblCloudWait.FontColor = [0.2 0.2 0.2];
            app.lblConclusion.Text = sprintf('CONCLUSION:\nEven at stable %.1f Mbps speeds, eDRis Edge AI is vastly more efficient and uses 80%% less server resources.', speed);
        end
    end
end
