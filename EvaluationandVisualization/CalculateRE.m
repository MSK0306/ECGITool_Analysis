function [RE, mnRE, stdRE] = CalculateRE(original, estimate)
    % CALCULATE_RE Calculates the Relative Error (RE)
    % Inputs:
    %   original - Original data matrix (nLeads x nSamples)
    %   estimate - Estimated data matrix (nLeads x nSamples)
    % Outputs:
    %   RE - Column vector of RE values for each sample
    %   mnRE - Median RE value
    %   stdRE - Standard deviation of RE values

    % Input validation
    if size(original) ~= size(estimate)
        error('Input matrices must have the same dimensions.');
    end

    % Dimensions of the input matrices
    [nLeads, nSamples] = size(original);

    % Initialize the RE vector
    RE = zeros(nSamples, 1);

    % Calculate RE for each sample
    for sampleIdx = 1:nSamples
        % Compute RE for the current sample
        RE(sampleIdx) = norm(original(:, sampleIdx) - estimate(:, sampleIdx)) / norm(original(:, sampleIdx));
    end

    % Compute summary statistics
    mnRE = median(RE); % Median RE value across samples
    stdRE = std(RE);   % Standard deviation of RE values
end
