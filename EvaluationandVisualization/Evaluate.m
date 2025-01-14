%% Initialization
clear;
clc;

%% Manually select the input file containing the estimations struct
[inputFileName, inputFilePath] = uigetfile('*.mat', 'Select Input File Containing Estimations');
if inputFileName == 0
    error('No file selected. Exiting script.');
end
load(fullfile(inputFilePath, inputFileName), 'estimations');

%% Initialize output struct
results = estimations;

%% Process each test beat
numBeats = length(estimations);
for i = 1:numBeats
    originalEPs = estimations(i).originalEPs; % True EPs
    estimatedEPs = estimations(i).estimatedEPs; % Predicted EPs

    % Calculate Temporal CCs
    [temporalCCs, medianTemporalCC, stdTemporalCC] = CalculateCC(originalEPs', estimatedEPs');

    % Calculate Spatial CCs
    [spatialCCs, medianSpatialCC, stdSpatialCC] = CalculateCC(originalEPs, estimatedEPs);

    % Calculate REs
    [temporalREs, medianTemporalRE, stdTemporalRE] = CalculateRE(originalEPs', estimatedEPs');
    [spatialREs, medianSpatialRE, stdSpatialRE] = CalculateRE(originalEPs, estimatedEPs);

    % Store results
    results(i).temporalCCs = temporalCCs;
    results(i).medianTemporalCC = medianTemporalCC;
    results(i).stdTemporalCC = stdTemporalCC;

    results(i).spatialCCs = spatialCCs;
    results(i).medianSpatialCC = medianSpatialCC;
    results(i).stdSpatialCC = stdSpatialCC;

    results(i).temporalREs = temporalREs;
    results(i).medianTemporalRE = medianTemporalRE;
    results(i).stdTemporalRE = stdTemporalRE;

    results(i).spatialREs = spatialREs;
    results(i).medianSpatialRE = medianSpatialRE;
    results(i).stdSpatialRE = stdSpatialRE;
end

%% Allow user to choose the folder to save the output file
outputFolderPath = uigetdir(inputFilePath, 'Select Folder to Save Results');
if outputFolderPath == 0
    disp('No folder selected for saving. Exiting script.');
    return;
end

%% Save results with the same file name in the chosen folder
outputFileName = ['Evaluations_' inputFileName];
save(fullfile(outputFolderPath, outputFileName), 'results');

disp(['Results saved to ', fullfile(outputFolderPath, outputFileName)]);
