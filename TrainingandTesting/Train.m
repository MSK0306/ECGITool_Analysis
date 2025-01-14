%% Initialize
clear
clc

%% Add paths
addpath('..\DataDriven')

% Add MARS package to the path
addpath('D:\Academic\METU\Thesis\Code\ECGITool-main\Test');

% Path to training data
trainingDataPath = 'D:\Academic\METU\MARS_Publication\Development\Data\TrainingData';

% Path to save models
modelSavePath = 'D:\Academic\METU\MARS_Publication\Development\Data\Models';

%% Manually select the training data file
[trainingFileName, trainingFilePath] = uigetfile(fullfile(trainingDataPath, '*.mat'), 'Select Training Data File');
load(fullfile(trainingFilePath, trainingFileName));  % Load the selected training file

%% Generate model using the training data
% Access the .ep and .bsp fields from the struct 'training_data'
ep = training_data.ep';
bsp = training_data.bsp';
earthModel = DdModelingMars(ep, bsp);  % Generate model

%% Use the training data file name (without extension) as the model name with 'Model_' prefix
[~, modelName, ~] = fileparts(trainingFileName);  % Get the file name without the extension
modelName = ['Model_' modelName];  % Prepend 'Model_' to the model name
save(fullfile(modelSavePath, [modelName, '.mat']), 'earthModel');

disp(['Model ', modelName, ' saved successfully to ', fullfile(modelSavePath, [modelName, '.mat'])]);
