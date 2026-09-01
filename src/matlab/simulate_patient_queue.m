function simulate_patient_queue()
% SIMULATE_PATIENT_QUEUE MathWorks SIH 26038 Compliance
% Simulates telemedicine pipeline scaling for 100,000+ rural patients annually.
% Models image acquisition rates, bandwidth constraints, and doctor review capacity.
% Uses Statistics and Machine Learning Toolbox.

    % Simulation Parameters
    num_patients = 100000;
    days_in_year = 365;
    clinic_hours_per_day = 8;
    
    % Arrival rate modeled as a Poisson process
    % average patients per hour across the district
    lambda_per_hour = num_patients / (days_in_year * clinic_hours_per_day); 
    
    fprintf('=== eDRis Telemedicine Scalability Simulation ===\n');
    fprintf('Target: %d patients annually.\n', num_patients);
    fprintf('Average Arrival Rate: %.2f patients/hour\n\n', lambda_per_hour);
    
    % 1. Image Acquisition & Gatekeeper Rejection (Bandwidth Savings)
    % Historically, ~15-20% of rural fundus images are ungradeable.
    % We use a normal distribution to simulate the blur variance of incoming images.
    % Assuming Gatekeeper rejects anything below threshold 4.49.
    blur_scores = normrnd(6.0, 2.5, [num_patients, 1]); % Mean 6.0, std 2.5
    
    rejected_idx = blur_scores < 4.49;
    num_rejected = sum(rejected_idx);
    num_accepted = num_patients - num_rejected;
    
    % Assuming each raw HD image is ~5 MB
    img_size_mb = 5.0;
    bandwidth_saved_gb = (num_rejected * img_size_mb) / 1024;
    
    fprintf('--- 1. Bandwidth Optimization (Edge Gatekeeper) ---\n');
    fprintf('Images Rejected at Edge (No 2G transmission): %d (%.1f%%)\n', num_rejected, (num_rejected/num_patients)*100);
    fprintf('Bandwidth Saved: %.2f GB\n\n', bandwidth_saved_gb);
    
    % 2. AI Processing Throughput
    % Accepted images are transmitted to the Cloud AI Engine
    % Processing 1 image takes ~0.5 seconds on a standard GPU
    total_ai_compute_hours = (num_accepted * 0.5) / 3600;
    fprintf('--- 2. AI Processing Throughput (Cloud Engine) ---\n');
    fprintf('Total AI Compute Time for %d images: %.2f hours\n\n', num_accepted, total_ai_compute_hours);
    
    % 3. Ophthalmologist Review Capacity
    % Assuming a 27% prevalence rate of referable DR (Level 2+) in the screened population.
    % Only Level 2+ or Low Confidence images are sent to the doctor queue.
    is_referable = rand(num_accepted, 1) < 0.27;
    num_doctor_reviews = sum(is_referable);
    num_auto_reported = num_accepted - num_doctor_reviews;
    
    % A doctor takes ~30 seconds to review an Explainable Grad-CAM report,
    % versus ~3 minutes to grade a raw fundus image from scratch.
    time_per_xai_review_mins = 0.5;
    time_per_manual_review_mins = 3.0;
    
    total_xai_review_hours = (num_doctor_reviews * time_per_xai_review_mins) / 60;
    total_manual_review_hours = (num_accepted * time_per_manual_review_mins) / 60;
    
    hours_saved = total_manual_review_hours - total_xai_review_hours;
    
    fprintf('--- 3. Human-in-the-Loop Review Capacity ---\n');
    fprintf('Auto-Generated Normal Reports (No Doctor Needed): %d\n', num_auto_reported);
    fprintf('Flagged for Doctor Review (Level 2+): %d\n', num_doctor_reviews);
    fprintf('Total Doctor Time (eDRis XAI Workflow): %.2f hours\n', total_xai_review_hours);
    fprintf('Total Doctor Time (Traditional Manual Workflow): %.2f hours\n', total_manual_review_hours);
    fprintf('Ophthalmologist Hours Saved Annually: %.2f hours\n', hours_saved);
    
    % Visualization
    figure('Name', 'eDRis District Level Scalability');
    
    subplot(1,2,1);
    pie([num_rejected, num_auto_reported, num_doctor_reviews], ...
        {'Rejected at Edge', 'Auto-Reported (Level 0-1)', 'Doctor Review (Level 2+)'});
    title('Telemedicine Routing Distribution');
    
    subplot(1,2,2);
    b = bar([total_manual_review_hours, total_xai_review_hours]);
    b.FaceColor = 'flat';
    b.CData(1,:) = [0.8 0.2 0.2]; % Red for manual
    b.CData(2,:) = [0.2 0.8 0.2]; % Green for eDRis
    ylabel('Ophthalmologist Hours Required');
    set(gca, 'XTickLabel', {'Manual Grading', 'eDRis AI Workflow'});
    title('Clinical Time Optimization');
end
