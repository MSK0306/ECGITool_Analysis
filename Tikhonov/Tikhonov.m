% ========================================================================
%   Inverse ECG – Tikhonov Regularization Evaluation Script
%   -------------------------------------------------------
%   This script loads:
%       • experimental BSP measurements
%       • ground truth EP signals
%       • forward matrix A (sock BEM transformation)
%
%   Then it applies your TikhonovFunction (L-curve based)
%   to reconstruct the epicardial potentials.
%
%   The script includes diagnostic tools to check:
%       • consistency of (EP, BSP, A) triplet
%       • forward projection misfit
%       • correlation between BSP and A*x_true
%       • scaling issues or reference offsets
%
%   These diagnostics are crucial for validating whether
%   inverse reconstruction is *meaningful* before tuning λ.
%
%   Toggle diagnostics with the flag:  runDiagnostics = true/false.
%
% ========================================================================

%% Initialization
clear;  clc;

%% Add RegTools to path
addpath('RegTools');

%% File Paths
dataDir = 'D:\Academic\METU\MARS_Publication\Development\Data\TestData';
forwardMatPath = 'D:\Academic\METU\MARS_Publication\Development\Data\Utah-10-03-02\Forward_Transforms\BEM_forward_transformation_measuredlocations.mat';

%% Load Test Data (EP + BSP)
[inputFileName, inputFilePath] = uigetfile(fullfile(dataDir, '*.mat'), ...
    'Select Input File Containing Estimations');

if inputFileName == 0
    error('No file selected. Exiting script.');
end

load(fullfile(inputFilePath, inputFileName), 'test_data');

%% Load Forward Transform Matrix (A)
load(forwardMatPath, 'scirunmatrix');
A = scirunmatrix;

%% Settings
numBeats = length(test_data);    % total number of beats in file
numBeats = 1;                    % TEMP: limit to 2 for testing
runDiagnostics = true;           % Toggle detailed diagnostics ON/OFF
diagnosticBeat = 1;              % Which beat to inspect in detail
diagnosticFrame = 180;           % Which time frame to inspect (activation peak)
beadToPlot = 20;                 % Bead/Node index for time-series visualization

%% Process Each Beat
for beatIdx = 1:numBeats

    fprintf('\n=============================================\n');
    fprintf('Processing beat %d of %d...\n', beatIdx, numBeats);
    fprintf('=============================================\n');

    % Extract EPs and BSPs for this beat
    ep = test_data(beatIdx).ep;      % true EPs (nSources x nFrames)
    bsp = test_data(beatIdx).bsp;    % measured BSPs (nLeads x nFrames)

    %% --- Solve Inverse Problem (Tikhonov Regularization) ---
    [estimatedEPs, medianLambda, lambdaVec] = TikhonovFunction(bsp, A);


    fprintf('Lambda stats for beat %d: median = %.4g, min = %.4g, max = %.4g\n', ...
        beatIdx, medianLambda, min(lambdaVec), max(lambdaVec));


    %% ===============================================================
    %   DIAGNOSTICS SECTION (runs only for chosen beat)
    %   ---------------------------------------------------------------
    %   Purpose:
    %   --------
    %   • Check whether EP, BSP, and A describe the same physical system
    %   • Compute forward misfit: ||A*x_true - b|| / ||b||
    %   • Compute BSP correlation: corr(b_meas, A*x_true)
    %   • Detect gain mismatch or reference offset issues
    %
    %   Interpretation:
    %   --------------
    %   * High correlation (r > 0.8) and misfit < 0.5 = consistent triplet
    %   * Low correlation or misfit > 1 → A, EP, BSP do NOT match
    % ===============================================================

    if runDiagnostics && (beatIdx == diagnosticBeat)

        frameIdx = diagnosticFrame;

        b_meas = bsp(:, frameIdx);              % BSP at one time frame
        x_true = ep(:, frameIdx);               % true EP snapshot
        x_est  = estimatedEPs(:, frameIdx);     % reconstructed EP snapshot

        % Forward projections
        b_from_true = A * x_true;
        b_from_est  = A * x_est;

        % Relative forward misfits
        relMisfit_true = norm(b_from_true - b_meas) / norm(b_meas);
        relMisfit_est  = norm(b_from_est  - b_meas) / norm(b_meas);

        fprintf('Diagnostics for beat %d, frame %d:\n', beatIdx, frameIdx);
        fprintf('  Forward misfit using TRUE EPs:      %.3f\n', relMisfit_true);
        fprintf('  Forward misfit using Tikhonov EPs:  %.3f (λ = %.4g)\n', ...
            relMisfit_est, medianLambda);

        % ------------------------------------------------------------------
        % Additional diagnostics: scaling + reference offset check
        % ------------------------------------------------------------------

        % (a) Correlation between BSP and A*x_true
        cc = corrcoef(b_meas, b_from_true);
        corr_val = cc(1,2);

        % (b) Optimal scaling factor (global gain mismatch)
        alpha = (b_meas' * b_from_true) / (b_from_true' * b_from_true);
        b_scaled = alpha * b_from_true;
        relMisfit_scaled = norm(b_scaled - b_meas) / norm(b_meas);

        % (c) Mean removal (reference mismatch check)
        b_meas0 = b_meas - mean(b_meas);
        b_true0 = b_from_true - mean(b_from_true);
        alpha0  = (b_meas0' * b_true0) / (b_true0' * b_true0);
        b_scaled0 = alpha0 * b_true0;
        relMisfit_scaled0 = norm(b_scaled0 - b_meas0) / norm(b_meas0);

        fprintf('  Corr(b_meas, A*x_true):             %.3f\n', corr_val);
        fprintf('  Misfit after scaling:               %.3f (alpha = %.3f)\n', ...
            relMisfit_scaled, alpha);
        fprintf('  Misfit after mean-removal+scaling:  %.3f (alpha0 = %.3f)\n', ...
            relMisfit_scaled0, alpha0);

    end % diagnostics



    %% Store results
    estimations(beatIdx).estimatedEPs = estimatedEPs;
    estimations(beatIdx).lambdaVec    = lambdaVec;
    estimations(beatIdx).medianLambda = medianLambda;


    %% Visualization – Bead-wise Time Series
    true_ts = ep(beadToPlot, :);
    est_ts  = estimatedEPs(beadToPlot, :);

    figure;
    plot(true_ts, 'k', 'LineWidth', 1.2); hold on;
    plot(est_ts,  'b', 'LineWidth', 1.2);
    legend('True EP', 'Estimated EP');
    xlabel('Time Frame');
    ylabel('Potential (a.u.)');
    title(sprintf('Bead %d – Beat %d', beadToPlot, beatIdx));
    grid on;

end % beat loop



%% Save Output
outputFolderPath = 'D:\Academic\METU\MARS_Publication\Development\Data\Evaluations';
outputFileName    = 'Tikhonov.mat';
% save(fullfile(outputFolderPath, outputFileName), 'estimations');

disp(['Results saved to: ', fullfile(outputFolderPath, outputFileName)]);
