% simulate_bandwidth_controller.m
% Layer 2: Simulink Orchestrator Logic Simulation
% Dynamically checks network bandwidth and determines whether to send HD 
% raw images or compressed features to prevent rural network timeouts.

function [transmitted_payload, compression_ratio] = simulate_bandwidth_controller(image_matrix)
    % Simulate network check (in a real scenario, this would ping a server)
    % Let's randomly simulate a connection speed in Mbps (1 to 20 Mbps)
    current_bandwidth_mbps = randi([1, 20]);
    
    fprintf('Detected Network Bandwidth: %d Mbps\n', current_bandwidth_mbps);
    
    if current_bandwidth_mbps >= 5
        % 4G/Broadband: Transmit Raw HD Image
        fprintf('Connection Status: GOOD. Transmitting RAW HD Image...\n');
        transmitted_payload = image_matrix;
        compression_ratio = 1.0;
    else
        % 2G/3G/Poor Rural Connection: Compress before transmission
        fprintf('Connection Status: POOR. Activating Compression Protocol...\n');
        % Simple simulation of JPEG compression via quality reduction
        % In actual implementation, we might extract CNN features here at the edge.
        compression_ratio = 0.15; % Compress to 15% original size
        
        % We simulate compression by resizing down and up (lossy)
        % or just returning a smaller matrix proxy.
        resized = imresize(image_matrix, compression_ratio);
        transmitted_payload = resized;
        fprintf('Image compressed successfully for low-bandwidth transmission.\n');
    end
end
