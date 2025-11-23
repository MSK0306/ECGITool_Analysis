%% Initialization
clear;
clc;

%% Allow user to select the folder containing the .mat files
folderPath = uigetdir('', 'Select Input File Containing Evaluations');
if folderPath == 0
    disp('No folder selected. Exiting script.');
    return;
end

% Get list of all .mat files in the selected folder
matFiles = dir(fullfile(folderPath, '*.mat'));

if isempty(matFiles)
    error('No .mat files found in the selected folder. Exiting script.');
end

%% Initialize structure to hold all results
allResults = struct();

%% Load and bundle all results
for i = 1:length(matFiles)
    % Load each .mat file
    data = load(fullfile(folderPath, matFiles(i).name));
    
    % Ensure that 'results' is in the loaded file
    if isfield(data, 'results')
        allResults(i).results = data.results;
    else
        warning('No "results" found in %s. Skipping this file.', matFiles(i).name);
    end
end

%% Initialize matrices to store CCs and REs for each beat
numFiles = length(allResults);
numBeats = length(allResults(1).results); % Assuming same number of beats in each file

% Initialize matrices to store the CCs and REs
temporalCCs = NaN(numFiles, numBeats);
spatialCCs = NaN(numFiles, numBeats);
temporalREs = NaN(numFiles, numBeats);
spatialREs = NaN(numFiles, numBeats);
stdTemporalCCs = NaN(numFiles, numBeats);
stdSpatialCCs = NaN(numFiles, numBeats);
stdTemporalREs = NaN(numFiles, numBeats);
stdSpatialREs = NaN(numFiles, numBeats);

% Loop through each file and extract CCs and REs for each beat
for i = 1:numFiles
    for j = 1:numBeats
        temporalCCs(i, j) = allResults(i).results(j).medianTemporalCC;
        spatialCCs(i, j) = allResults(i).results(j).medianSpatialCC;
        temporalREs(i, j) = allResults(i).results(j).medianTemporalRE;
        spatialREs(i, j) = allResults(i).results(j).medianSpatialRE;
        
        % Extract the standard deviations from the results struct
        stdTemporalCCs(i, j) = allResults(i).results(j).stdTemporalCC;
        stdSpatialCCs(i, j) = allResults(i).results(j).stdSpatialCC;
        stdTemporalREs(i, j) = allResults(i).results(j).stdTemporalRE;
        stdSpatialREs(i, j) = allResults(i).results(j).stdSpatialRE;
    end
end

%% Calculate mean for each metric (CCs and REs) across all files
meanTemporalCCs = mean(temporalCCs, 2, 'omitnan');
meanSpatialCCs = mean(spatialCCs, 2, 'omitnan');
meanTemporalREs = mean(temporalREs, 2, 'omitnan');
meanSpatialREs = mean(spatialREs, 2, 'omitnan');

%% Calculate the mean of standard deviations for each metric (CCs and REs) across all beats
meanStdTemporalCCs = mean(stdTemporalCCs, 2, 'omitnan');
meanStdSpatialCCs = mean(stdSpatialCCs, 2, 'omitnan');
meanStdTemporalREs = mean(stdTemporalREs, 2, 'omitnan');
meanStdSpatialREs = mean(stdSpatialREs, 2, 'omitnan');

%% Display the calculated means and mean of stds for all metrics
disp('Mean of Temporal CCs across all files:');
disp(meanTemporalCCs);

disp('Mean of Spatial CCs across all files:');
disp(meanSpatialCCs);

disp('Mean of Temporal REs across all files:');
disp(meanTemporalREs);

disp('Mean of Spatial REs across all files:');
disp(meanSpatialREs);

disp('Mean of Standard Deviations of Temporal CCs:');
disp(meanStdTemporalCCs);

disp('Mean of Standard Deviations of Spatial CCs:');
disp(meanStdSpatialCCs);

disp('Mean of Standard Deviations of Temporal REs:');
disp(meanStdTemporalREs);

disp('Mean of Standard Deviations of Spatial REs:');
disp(meanStdSpatialREs);

%% ======= BOX PLOTS: 4 separate figures (no shared axes) =======
% Expects: temporalCCs, spatialCCs, temporalREs, spatialREs  (numFiles x numBeats)

% 1) EDIT THESE labels (one per file/intervention)
interventionLabels = {'20|350','15|350','10|350','5|350'};

% Basic check
if numel(interventionLabels) ~= size(temporalCCs,1)
    error('Number of labels must equal number of files (numFiles=%d).', size(temporalCCs,1));
end

% Helper: wide (numFiles x numBeats) -> long vectors
to_long = @(M) deal( ...
    reshape(repmat(interventionLabels(:).', size(M,2), 1), [], 1), ... % X labels (cellstr)
    reshape(M.', [], 1) );                                             % Y values (double)

% -------- Temporal CC --------
[X, Y] = to_long(temporalCCs);
valid = ~isnan(Y); X = X(valid); Y = Y(valid);
g = gramm('x', X, 'y', Y);
g.stat_boxplot();
g.set_names('x','Flow Rate | Pacing Interval','y','Temporal CC');
g.set_order_options('x', interventionLabels);
figure; g.draw();

% -------- Spatial CC --------
[X, Y] = to_long(spatialCCs);
valid = ~isnan(Y); X = X(valid); Y = Y(valid);
g = gramm('x', X, 'y', Y);
g.stat_boxplot();
g.set_names('x','Flow Rate | Pacing Interval','y','Spatial CC');
g.set_order_options('x', interventionLabels);
figure; g.draw();

% -------- Temporal RE --------
[X, Y] = to_long(temporalREs);
valid = ~isnan(Y); X = X(valid); Y = Y(valid);
g = gramm('x', X, 'y', Y);
g.stat_boxplot();
g.set_names('x','Flow Rate | Pacing Interval','y','Temporal RE');
g.set_order_options('x', interventionLabels);
figure; g.draw();

% -------- Spatial RE --------
[X, Y] = to_long(spatialREs);
valid = ~isnan(Y); X = X(valid); Y = Y(valid);
g = gramm('x', X, 'y', Y);
g.stat_boxplot();
g.set_names('x','Flow Rate | Pacing Interval','y','Spatial RE');
g.set_order_options('x', interventionLabels);
figure; g.draw();
