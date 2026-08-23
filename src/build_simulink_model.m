% build_simulink_model.m
% This script programmatically generates the eDRis Simulink Block Diagram!
% Run this script in the MATLAB Command Window to automatically build and 
% save the 'simulate_bandwidth_controller.slx' file.

function build_simulink_model()
    mdl = 'simulate_bandwidth_controller';
    
    % Close if already open
    if bdIsLoaded(mdl)
        close_system(mdl, 0);
    end
    
    fprintf('Creating new Simulink model: %s.slx...\n', mdl);
    new_system(mdl);
    open_system(mdl);
    
    % Add Inports
    add_block('simulink/Sources/In1', [mdl '/Raw_HD_Payload'], 'Position', [100, 100, 130, 114]);
    add_block('simulink/Sources/In1', [mdl '/Network_Speed_Mbps'], 'Position', [100, 170, 130, 184]);
    
    % Add Compressor (Using a Gain block to visually represent compression ratio)
    add_block('simulink/Math Operations/Gain', [mdl '/Adaptive_Compressor'], ...
        'Gain', '0.15', 'Position', [250, 200, 310, 230]);
    
    % Add Switch (The Traffic Cop)
    add_block('simulink/Signal Routing/Switch', [mdl '/Bandwidth_Router'], ...
        'Criteria', 'u2 >= Threshold', 'Threshold', '5', ...
        'Position', [450, 130, 500, 190]);
        
    % Add Outport
    add_block('simulink/Sinks/Out1', [mdl '/Transmitted_Payload'], 'Position', [600, 153, 630, 167]);
    
    % Connect the blocks with auto-routing
    fprintf('Wiring the blocks together...\n');
    add_line(mdl, 'Raw_HD_Payload/1', 'Bandwidth_Router/1', 'autorouting', 'on'); % Top port (True: >= 5Mbps)
    add_line(mdl, 'Network_Speed_Mbps/1', 'Bandwidth_Router/2', 'autorouting', 'on'); % Middle port (Condition)
    add_line(mdl, 'Raw_HD_Payload/1', 'Adaptive_Compressor/1', 'autorouting', 'on'); % Send raw to compressor
    add_line(mdl, 'Adaptive_Compressor/1', 'Bandwidth_Router/3', 'autorouting', 'on'); % Bottom port (False: < 5Mbps)
    add_line(mdl, 'Bandwidth_Router/1', 'Transmitted_Payload/1', 'autorouting', 'on'); % Output
    
    % Save it
    savePath = fullfile(fileparts(mfilename('fullpath')), [mdl '.slx']);
    save_system(mdl, savePath);
    
    fprintf('Success! Simulink model saved to: %s\n', savePath);
    fprintf('You can now take a screenshot of this model for your Pitch Deck!\n');
end
