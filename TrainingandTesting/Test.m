%% Initialize
clear;
clc;

%% Add paths
addpath('..\DataDriven');
addpath('D:\Academic\METU\MARS_Publication\Development\Data\TestData');
addpath('D:\Academic\METU\MARS_Publication\Development\Data\Models');

% Add MARS package to the path
addpath('D:\Academic\METU\Thesis\Code\ECGITool-main\Test');

%% Manually select the test data file
testDataPath = 'D:\Academic\METU\MARS_Publication\Development\Data\TestData';
[testFileName, testFilePath] = uigetfile(fullfile(testDataPath, '*.mat'), 'Select Test Data File');
load(fullfile(testFilePath, testFileName));  % Load the selected test data file

%% Manually select the trained model file
modelPath = 'D:\Academic\METU\MARS_Publication\Development\Data\Models';
[modelFileName, modelFilePath] = uigetfile(fullfile(modelPath, 'Model_*.mat'), 'Select Trained Model File');
load(fullfile(modelFilePath, modelFileName));  % Load the selected model

%% Test and estimation
numBeats = length(test_data);  % Number of beats in the test data
estimations = struct();

for i = 1:numBeats
    originalEPs = test_data(i).ep;  % Get original EPs from test data
    bspm = test_data(i).bsp';       % Get BSPM from test data (transpose for correct dimensions)

    % Initialize array to store estimated EPs for each lead
    estimatedEPs = zeros(size(originalEPs));  % size of originalEPs is (247 x T)

    for j = 1:247  % Loop over all leads (247 leads)
        % Predict EP for each lead using the trained model
        estimatedEPs(j, :) = earthModel(j).predict(bspm);  % bspm is (T x N)
    end

    % Store original and estimated EPs in the struct
    estimations(i).originalEPs = originalEPs;
    estimations(i).estimatedEPs = estimatedEPs;
    estimations(i).BSPs = bspm';
end

%% Choose destination folder to save the estimations
destPath = uigetdir(testFilePath, 'Select Destination Folder for Saving Estimations');
if destPath == 0  % If user cancels the folder selection
    disp('Destination folder selection canceled. Saving to the test data folder by default.');
    destPath = testFilePath;
end

%% Save the estimations
saveFileName = ['Estimation_', testFileName(1:end-4), '_', modelFileName(1:end-4), '.mat'];  % Save with test and model name
save(fullfile(destPath, saveFileName), 'estimations');

disp(['Estimations saved to ', fullfile(destPath, saveFileName)]);

%% Visualization (for the first beat)
beatIdx = 3;  % Index of the beat to visualize
leadIdx = 150; % Lead to visualize (change to any lead number)

figure;
plot(estimations(beatIdx).originalEPs(leadIdx, :), 'b', 'LineWidth', 1.5); hold on;
plot(estimations(beatIdx).estimatedEPs(leadIdx, :), 'r--', 'LineWidth', 1.5);
legend('Original EP', 'Estimated EP');
xlabel('Time Samples');
ylabel('Voltage (mV)');
title(['Lead ', num2str(leadIdx), ' - Beat ', num2str(beatIdx)]);
grid on;
