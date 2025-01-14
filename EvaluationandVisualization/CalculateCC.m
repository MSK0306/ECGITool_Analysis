function [CC, medianCC, stdCC] = CalculateCC(original, estimate)
% CALCULATE_CC    Calculates the correlation coefficient (CC) between the 
%                 original data and its estimate.
%
% Usage:
%   [CC, meanCC, stdCC] = calculate_cc(original, estimate)
%
% Inputs:
%   original    (nVariables x nSamples) Matrix of original data.
%   estimate    (nVariables x nSamples) Matrix of estimated data.
%
% Outputs:
%   CC          (nSamples x 1) Column vector of CC values for each sample.
%   meanCC      Median CC value across all samples.
%   stdCC       Standard deviation of CC values across all samples.
%
% Notes:
%   - The function is generalized for use in both spatial and temporal CC 
%     calculations, where "variables" and "samples" refer to leads and time 
%     frames, respectively, or vice versa.
%   - Assumes input matrices have the same dimensions.

    % Input validation
    if size(original) ~= size(estimate)
        error('Input matrices must have the same dimensions.');
    end

    % Dimensions of the input matrices
    [nVariables, nSamples] = size(original);

    % Initialize the CC vector
    CC = zeros(nSamples, 1);

    % Calculate CC for each sample
    for sampleIdx = 1:nSamples
        % Extract data for the current sample
        origSample = original(:, sampleIdx);
        estSample = estimate(:, sampleIdx);

        % Compute terms for the CC formula
        sumOrig = sum(origSample);
        sumEst = sum(estSample);

        numerator = nVariables * (origSample' * estSample) - (sumOrig * sumEst);
        denominator = sqrt((nVariables * sum(origSample .^ 2) - sumOrig^2) * ...
                           (nVariables * sum(estSample .^ 2) - sumEst^2));

        % Calculate CC for the current sample
        CC(sampleIdx) = numerator / denominator;
    end

    % Compute summary statistics
    medianCC = median(CC);  % Median CC value across samples
    stdCC = std(CC);      % Standard deviation of CC values
end
