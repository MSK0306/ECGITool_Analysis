%% Initialize
clear
clc

%% Directories for all interventions
ep_dir_I1 = 'D:\Academic\METU\MARS_Publication\Development\Data\Utah-10-03-02\Interventions\I1-Demand_Ischemia-350to275Hz\I1_Time_Signals\Sock_\';
bsp_dir_I1 = 'D:\Academic\METU\MARS_Publication\Development\Data\Utah-10-03-02\Interventions\I1-Demand_Ischemia-350to275Hz\I1_Time_Signals\Tank_\';

ep_dir_I2 = 'D:\Academic\METU\MARS_Publication\Development\Data\Utah-10-03-02\Interventions\I2-Supply_Ischemia-20to5ml\I2_Time_Signals\Sock_\';
bsp_dir_I2 = 'D:\Academic\METU\MARS_Publication\Development\Data\Utah-10-03-02\Interventions\I2-Supply_Ischemia-20to5ml\I2_Time_Signals\Tank_\';

ep_dir_I3 = 'D:\Academic\METU\MARS_Publication\Development\Data\Utah-10-03-02\Interventions\I3-Demand_Ischemia-350to275Hz\I3_Time_Signals\Sock_\';
bsp_dir_I3 = 'D:\Academic\METU\MARS_Publication\Development\Data\Utah-10-03-02\Interventions\I3-Demand_Ischemia-350to275Hz\I3_Time_Signals\Tank_\';

ep_dir_I4 = 'D:\Academic\METU\MARS_Publication\Development\Data\Utah-10-03-02\Interventions\I4-Supply_Ischemia-20to5ml\I4_Time_Signals\Sock_\';
bsp_dir_I4 = 'D:\Academic\METU\MARS_Publication\Development\Data\Utah-10-03-02\Interventions\I4-Supply_Ischemia-20to5ml\I4_Time_Signals\Tank_\';

%% Run ranges for each intervention
run_range_I1a = 16:20;
run_range_I1b = 27:31;
run_range_I1c = 38:42;
run_range_I1d = 49:53;

run_range_I2a = 66:70;
run_range_I2b = 77:81;
run_range_I2c = 88:92;
run_range_I2d = 99:103;

run_range_I3a = 116:120;
run_range_I3b = 127:131;
run_range_I3c = 138:142;
run_range_I3d = 149:153;

run_range_I4a = 166:170;
run_range_I4b = 177:181;
run_range_I4c = 188:192;
run_range_I4d = 199:203;


%% Save test data for each intervention and subgroup

% I1
save_test_data(ep_dir_I1, bsp_dir_I1, run_range_I1a, 'D:\Academic\METU\MARS_Publication\Development\Data\TestData\TestI1a.mat');
save_test_data(ep_dir_I1, bsp_dir_I1, run_range_I1b, 'D:\Academic\METU\MARS_Publication\Development\Data\TestData\TestI1b.mat');
save_test_data(ep_dir_I1, bsp_dir_I1, run_range_I1c, 'D:\Academic\METU\MARS_Publication\Development\Data\TestData\TestI1c.mat');
save_test_data(ep_dir_I1, bsp_dir_I1, run_range_I1d, 'D:\Academic\METU\MARS_Publication\Development\Data\TestData\TestI1d.mat');

% I2
save_test_data(ep_dir_I2, bsp_dir_I2, run_range_I2a, 'D:\Academic\METU\MARS_Publication\Development\Data\TestData\TestI2a.mat');
save_test_data(ep_dir_I2, bsp_dir_I2, run_range_I2b, 'D:\Academic\METU\MARS_Publication\Development\Data\TestData\TestI2b.mat');
save_test_data(ep_dir_I2, bsp_dir_I2, run_range_I2c, 'D:\Academic\METU\MARS_Publication\Development\Data\TestData\TestI2c.mat');
save_test_data(ep_dir_I2, bsp_dir_I2, run_range_I2d, 'D:\Academic\METU\MARS_Publication\Development\Data\TestData\TestI2d.mat');

% I3
save_test_data(ep_dir_I3, bsp_dir_I3, run_range_I3a, 'D:\Academic\METU\MARS_Publication\Development\Data\TestData\TestI3a.mat');
save_test_data(ep_dir_I3, bsp_dir_I3, run_range_I3b, 'D:\Academic\METU\MARS_Publication\Development\Data\TestData\TestI3b.mat');
save_test_data(ep_dir_I3, bsp_dir_I3, run_range_I3c, 'D:\Academic\METU\MARS_Publication\Development\Data\TestData\TestI3c.mat');
save_test_data(ep_dir_I3, bsp_dir_I3, run_range_I3d, 'D:\Academic\METU\MARS_Publication\Development\Data\TestData\TestI3d.mat');

% I4
save_test_data(ep_dir_I4, bsp_dir_I4, run_range_I4a, 'D:\Academic\METU\MARS_Publication\Development\Data\TestData\TestI4a.mat');
save_test_data(ep_dir_I4, bsp_dir_I4, run_range_I4b, 'D:\Academic\METU\MARS_Publication\Development\Data\TestData\TestI4b.mat');
save_test_data(ep_dir_I4, bsp_dir_I4, run_range_I4c, 'D:\Academic\METU\MARS_Publication\Development\Data\TestData\TestI4c.mat');
save_test_data(ep_dir_I4, bsp_dir_I4, run_range_I4d, 'D:\Academic\METU\MARS_Publication\Development\Data\TestData\TestI4d.mat');

%% Function to load and save test data
function save_test_data(ep_dir, bsp_dir, run_range, file_name)
    test_data = [];
    i = 1;
    for run_id = run_range
        % Load EP data
        ep_file = sprintf('%sRun%04d-cs.mat', ep_dir, run_id);
        ep_data = load(ep_file);
        ep_signals = ep_data.ts.potvals; % 247 x 572
        
        % Load BSP data
        bsp_file = sprintf('%sRun%04d-ts.mat', bsp_dir, run_id);
        bsp_data = load(bsp_file);
        bsp_signals = bsp_data.ts.potvals; % 192 x 572

        test_data(i).ep = ep_signals;
        test_data(i).bsp = bsp_signals;

        i = i + 1;
    end

    % Save test data
    save(file_name, 'test_data');
end
