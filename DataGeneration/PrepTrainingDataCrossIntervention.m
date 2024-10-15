% Directories for all interventions
ep_dir_I1 = 'D:\Academic\METU\MARS_Publication\Development\Data\Utah-10-03-02\Interventions\I1-Demand_Ischemia-350to275Hz\I1_Time_Signals\Sock_\';
bsp_dir_I1 = 'D:\Academic\METU\MARS_Publication\Development\Data\Utah-10-03-02\Interventions\I1-Demand_Ischemia-350to275Hz\I1_Time_Signals\Tank_\';

ep_dir_I2 = 'D:\Academic\METU\MARS_Publication\Development\Data\Utah-10-03-02\Interventions\I2-Supply_Ischemia-20to5ml\I2_Time_Signals\Sock_\';
bsp_dir_I2 = 'D:\Academic\METU\MARS_Publication\Development\Data\Utah-10-03-02\Interventions\I2-Supply_Ischemia-20to5ml\I2_Time_Signals\Tank_\';

ep_dir_I3 = 'D:\Academic\METU\MARS_Publication\Development\Data\Utah-10-03-02\Interventions\I3-Demand_Ischemia-350to275Hz\I3_Time_Signals\Sock_\';
bsp_dir_I3 = 'D:\Academic\METU\MARS_Publication\Development\Data\Utah-10-03-02\Interventions\I3-Demand_Ischemia-350to275Hz\I3_Time_Signals\Tank_\';

ep_dir_I4 = 'D:\Academic\METU\MARS_Publication\Development\Data\Utah-10-03-02\Interventions\I4-Supply_Ischemia-20to5ml\I4_Time_Signals\Sock_\';
bsp_dir_I4 = 'D:\Academic\METU\MARS_Publication\Development\Data\Utah-10-03-02\Interventions\I4-Supply_Ischemia-20to5ml\I4_Time_Signals\Tank_\';

% Run ranges for each intervention
run_range_I1 = 16:59;
run_range_I2 = 66:109;
run_range_I3 = 116:159;
run_range_I4 = 166:204;

% Number of total samples
total_samples = 20000;

% Randomize the order of runs for each intervention
shuffled_runs_I1 = run_range_I1(randperm(length(run_range_I1)));
shuffled_runs_I2 = run_range_I2(randperm(length(run_range_I2)));
shuffled_runs_I3 = run_range_I3(randperm(length(run_range_I3)));
shuffled_runs_I4 = run_range_I4(randperm(length(run_range_I4)));

% Initialize storage for concatenated signals
ep_concat = [];
bsp_concat = [];

% Initialize indices to alternate between interventions
i2_index = 1;
i4_index = 1;

% Loop until we have the required number of samples
while size(ep_concat, 2) < total_samples
    
    % Select one beat from I2 (if there are remaining beats)
    if i2_index <= length(shuffled_runs_I2)
        run_id = shuffled_runs_I2(i2_index);
        
        % Load EP data for I2
        ep_file = sprintf('%sRun%04d-cs.mat', ep_dir_I2, run_id);
        ep_data = load(ep_file);
        ep_signals = ep_data.ts.potvals;  % 247 x variable length
        
        % Load BSP data for I2
        bsp_file = sprintf('%sRun%04d-ts.mat', bsp_dir_I2, run_id);
        bsp_data = load(bsp_file);
        bsp_signals = bsp_data.ts.potvals;  % 192 x variable length
        
        % Concatenate the current beat (all channels for this run)
        ep_concat = [ep_concat, ep_signals];
        bsp_concat = [bsp_concat, bsp_signals];
        
        % Move to the next beat for I2
        i2_index = i2_index + 1;
    end
    
    % Check if we have enough samples already
    if size(ep_concat, 2) >= total_samples
        break;
    end
    
    % Select one beat from I4 (if there are remaining beats)
    if i4_index <= length(shuffled_runs_I4)
        run_id = shuffled_runs_I4(i4_index);
        
        % Load EP data for I4
        ep_file = sprintf('%sRun%04d-cs.mat', ep_dir_I4, run_id);
        ep_data = load(ep_file);
        ep_signals = ep_data.ts.potvals;  % 247 x variable length
        
        % Load BSP data for I4
        bsp_file = sprintf('%sRun%04d-ts.mat', bsp_dir_I4, run_id);
        bsp_data = load(bsp_file);
        bsp_signals = bsp_data.ts.potvals;  % 192 x variable length
        
        % Concatenate the current beat (all channels for this run)
        ep_concat = [ep_concat, ep_signals];
        bsp_concat = [bsp_concat, bsp_signals];
        
        % Move to the next beat for I4
        i4_index = i4_index + 1;
    end
end

% Trim to 20000 samples if necessary
ep_concat = ep_concat(:, 1:total_samples);
bsp_concat = bsp_concat(:, 1:total_samples);

% Create a struct to hold the training data
training_data.ep = ep_concat;
training_data.bsp = bsp_concat;

% Optional: Save the data (uncomment to save)
save('D:\Academic\METU\MARS_Publication\Development\Data\TrainingData\TrainingCross-interventionB.mat', 'training_data');

% Plot the data for visual inspection
figure;
subplot(2, 1, 1);
plot(ep_concat(:));  % Flatten the EP data for plotting
title('EP Signal - 20000 Samples (Alternating from I2 and I4)');
subplot(2, 1, 2);
plot(bsp_concat(:));  % Flatten the BSP data for plotting
title('BSP Signal - 20000 Samples (Alternating from I2 and I4)');