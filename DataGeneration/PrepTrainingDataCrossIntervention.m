%% Initialize
clear
clc

%% Directories for interventions
ep_dir_I1 = 'D:\Academic\METU\MARS_Publication\Development\Data\Utah-10-03-02\Interventions\I1-Demand_Ischemia-350to275Hz\I1_Time_Signals\Sock_\';
bsp_dir_I1 = 'D:\Academic\METU\MARS_Publication\Development\Data\Utah-10-03-02\Interventions\I1-Demand_Ischemia-350to275Hz\I1_Time_Signals\Tank_\';

ep_dir_I2 = 'D:\Academic\METU\MARS_Publication\Development\Data\Utah-10-03-02\Interventions\I2-Supply_Ischemia-20to5ml\I2_Time_Signals\Sock_\';
bsp_dir_I2 = 'D:\Academic\METU\MARS_Publication\Development\Data\Utah-10-03-02\Interventions\I2-Supply_Ischemia-20to5ml\I2_Time_Signals\Tank_\';

ep_dir_I3 = 'D:\Academic\METU\MARS_Publication\Development\Data\Utah-10-03-02\Interventions\I3-Demand_Ischemia-350to275Hz\I3_Time_Signals\Sock_\';
bsp_dir_I3 = 'D:\Academic\METU\MARS_Publication\Development\Data\Utah-10-03-02\Interventions\I3-Demand_Ischemia-350to275Hz\I3_Time_Signals\Tank_\';

ep_dir_I4 = 'D:\Academic\METU\MARS_Publication\Development\Data\Utah-10-03-02\Interventions\I4-Supply_Ischemia-20to5ml\I4_Time_Signals\Sock_\';
bsp_dir_I4 = 'D:\Academic\METU\MARS_Publication\Development\Data\Utah-10-03-02\Interventions\I4-Supply_Ischemia-20to5ml\I4_Time_Signals\Tank_\';

%% Run ranges for both interventions
run_range_I1 = [16:20, 27:31, 38:42, 49:53];
run_range_I2 = [16:20, 27:31, 38:42, 49:53] + 50;
run_range_I3 = [16:20, 27:31, 38:42, 49:53] + 100;
run_range_I4 = [16:20, 27:31, 38:42, 49:53] + 150;


%% Combine and shuffle runs across directories
all_runs = [run_range_I2, run_range_I4];
shuffled_runs = all_runs(randperm(length(all_runs)));

%% Initialize storage for concatenated signals
ep_concat = [];
bsp_concat = [];

%% Process each run
for run_id = shuffled_runs
    
    % Determine which intervention the run belongs to
    if ismember(run_id, run_range_I2)
        ep_dir = ep_dir_I2;
        bsp_dir = bsp_dir_I2;
    elseif ismember(run_id, run_range_I4)
        ep_dir = ep_dir_I4;
        bsp_dir = bsp_dir_I4;
    else
        error('Run ID %d not found in any intervention range.', run_id);
    end
    
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
end

% Create a struct to hold the training data
training_data.ep = ep_concat;
training_data.bsp = bsp_concat;

%% Save the data
save('D:\Academic\METU\MARS_Publication\Development\Data\TrainingData\TrainingCI2.mat', 'training_data');

%% Plot the data for visual inspection
ep_electrode = 50;
bsp_electrode = 50;

figure;
subplot(2, 1, 1);
plot(ep_concat(ep_electrode,:)); % Flatten the EP data for plotting
title('EP Signal');
subplot(2, 1, 2);
plot(bsp_concat(bsp_electrode,:)); % Flatten the BSP data for plotting
title('BSP Signal');
