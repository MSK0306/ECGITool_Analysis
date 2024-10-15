% Parameters

% TrainingDemandIschemia
% ep_dir = 'D:\Academic\METU\MARS_Publication\Development\Data\Utah-10-03-02\Interventions\I1-Demand_Ischemia-350to275Hz\I1_Time_Signals\Sock_\';
% bsp_dir = 'D:\Academic\METU\MARS_Publication\Development\Data\Utah-10-03-02\Interventions\I1-Demand_Ischemia-350to275Hz\I1_Time_Signals\Tank_\';

% TrainingSupplyIschemia
% ep_dir = 'D:\Academic\METU\MARS_Publication\Development\Data\Utah-10-03-02\Interventions\I2-Supply_Ischemia-20to5ml\I2_Time_Signals\Sock_\';
% bsp_dir = 'D:\Academic\METU\MARS_Publication\Development\Data\Utah-10-03-02\Interventions\I2-Supply_Ischemia-20to5ml\I2_Time_Signals\Tank_\';

% ep_dir = 'D:\Academic\METU\MARS_Publication\Development\Data\Utah-10-03-02\Interventions\I3-Demand_Ischemia-350to275Hz\I3_Time_Signals\Sock_\';
% bsp_dir = 'D:\Academic\METU\MARS_Publication\Development\Data\Utah-10-03-02\Interventions\I3-Demand_Ischemia-350to275Hz\I3_Time_Signals\Tank_\';

ep_dir = 'D:\Academic\METU\MARS_Publication\Development\Data\Utah-10-03-02\Interventions\I4-Supply_Ischemia-20to5ml\I4_Time_Signals\Sock_\';
bsp_dir = 'D:\Academic\METU\MARS_Publication\Development\Data\Utah-10-03-02\Interventions\I4-Supply_Ischemia-20to5ml\I4_Time_Signals\Tank_\';


run_range = 166:198;
total_samples = 20000;

% Randomize the order of runs
shuffled_runs = run_range(randperm(length(run_range)));
shuffled_runs = [shuffled_runs,shuffled_runs];

% Initialize storage for concatenated signals
ep_concat = [];
bsp_concat = [];

% Loop through the shuffled runs and concatenate beats
for run_id = shuffled_runs
    % Load EP data
    ep_file = sprintf('%sRun%04d-cs.mat', ep_dir, run_id);
    ep_data = load(ep_file);
    ep_signals = ep_data.ts.potvals; % 247 x 572
    
    % Load BSP data
    bsp_file = sprintf('%sRun%04d-ts.mat', bsp_dir, run_id);
    bsp_data = load(bsp_file);
    bsp_signals = bsp_data.ts.potvals; % 192 x 572
    
    % Concatenate the beat (all channels for the current run)
    ep_concat = [ep_concat, ep_signals]; % Add EP signals
    bsp_concat = [bsp_concat, bsp_signals]; % Add BSP signals
    
    % Stop once we have enough samples
    if size(ep_concat, 2) >= total_samples
        break;
    end
end

% Trim to 20000 samples if necessary
ep_concat = ep_concat(:, 1:total_samples);
bsp_concat = bsp_concat(:, 1:total_samples);

% Create a struct to hold the training data
training_data.ep = ep_concat;
training_data.bsp = bsp_concat;

% Optional: Save the data (commented out for now)
save('D:\Academic\METU\MARS_Publication\Development\Data\TrainingData\TrainingPartialI4.mat', 'training_data');

% Plot the data for visual inspection
figure;
subplot(2, 1, 1);
plot(ep_concat(:)); % Flatten the EP data for plotting
title('EP Signal - 20000 Samples');
subplot(2, 1, 2);
plot(bsp_concat(:)); % Flatten the BSP data for plotting
title('BSP Signal - 20000 Samples');
