function [estimatedEPs, medianLambda, lambdaVec] = TikhonovFunction(bsp, A, minLambda, maxLambda)
% TikhonovFunction
% -------------------------------------------------------------------------
% Performs 0th-order Tikhonov regularization using the L-curve method
% to select a regularization parameter λ for each time frame, then uses
% the median λ across all frames to compute the final EP estimates.
%
%   min_x ||A x - b||_2^2 + λ^2 ||x||_2^2
%
% INPUTS:
%   bsp        - Body surface potentials       [nLeads x nFrames]
%   A          - Forward matrix (sock matrix)  [nLeads x nSources]
%   minLambda  - Minimum allowed λ (optional; default: 5e-6)
%   maxLambda  - Maximum allowed λ (optional; default: 2)
%
% OUTPUTS:
%   estimatedEPs  - Estimated EPs              [nSources x nFrames]
%   medianLambda  - Median λ across frames     (scalar)
%   lambdaVec     - Per-frame λ values         [1 x nFrames]
%
% Notes:
%   - Uses RegTools functions: csvd, l_curve, tikhonov.
%   - This is a "single-λ for all frames" strategy (median λ).
%     Later, you can extend this to per-frame λ or smoothed λ.
% -------------------------------------------------------------------------

    % ----- Defaults for λ range -----
    if nargin < 3 || isempty(minLambda)
        minLambda = 1e-3;   % was 5e-6
    end
    if nargin < 4 || isempty(maxLambda)
        maxLambda = 0.2;    % was 2
    end


    % ----- Check that RegTools is available -----
    if exist('l_curve', 'file') ~= 2 || exist('csvd', 'file') ~= 2 || exist('tikhonov', 'file') ~= 2
        error('RegTools functions (l_curve, csvd, tikhonov) not found on path.');
    end

    % ----- Dimensions -----
    [nLeads, nFrames] = size(bsp);   %#ok<NASGU>  % nLeads not used below but kept for clarity
    nSources = size(A, 2);

    % ----- Preallocate -----
    lambdaVec   = zeros(1, nFrames);
    estimatedEPs = zeros(nSources, nFrames);

    % ----- Precompute SVD of A (CSV decomposition) -----
    % A = U * diag(s) * V'
    [U, s, V] = csvd(A);

    % ---------------------------------------------------------------------
    % STEP 1: λ selection per frame via L-curve (with clamping)
    % ---------------------------------------------------------------------
    for i = 1:nFrames
        b = bsp(:, i);

        % L-curve to suggest λ for this frame
        try
            [lambdaOpt, ~, ~, ~] = l_curve(U, s, b);
        catch
            % If l_curve fails (rare), fall back to previous λ or a safe default
            if i == 1
                warning('l_curve failed at frame %d. Using λ = %g (minLambda).', i, minLambda);
                lambdaOpt = minLambda;
            else
                warning('l_curve failed at frame %d. Reusing λ from previous frame.', i);
                lambdaOpt = lambdaVec(i-1);
            end
        end

        % Handle NaN or empty λ from l_curve
        if isempty(lambdaOpt) || isnan(lambdaOpt)
            if i == 1
                warning('Invalid λ at frame %d (NaN/empty). Using λ = %g (minLambda).', i, minLambda);
                lambdaOpt = minLambda;
            else
                warning('Invalid λ at frame %d (NaN/empty). Reusing λ from previous frame.', i);
                lambdaOpt = lambdaVec(i-1);
            end
        end

        % Clamp λ into [minLambda, maxLambda]
        % Reject tiny or invalid λ from L-curve
        if isempty(lambdaOpt) || isnan(lambdaOpt) || lambdaOpt < minLambda
            if i == 1
                % If first frame, use a safe default (middle of range)
                lambdaOpt = sqrt(minLambda * maxLambda);
            else
                % Otherwise, reuse previous λ
                lambdaOpt = lambdaVec(i-1);
            end
        end

        % Also clamp to upper bound
        lambdaOpt = min(lambdaOpt, maxLambda);


        lambdaVec(i) = lambdaOpt;
    end

    % ---------------------------------------------------------------------
    % STEP 2: Use median λ across all frames for final reconstruction
    % ---------------------------------------------------------------------
    medianLambda = median(lambdaVec);

    for i = 1:nFrames
        b = bsp(:, i);
        estimatedEPs(:, i) = tikhonov(U, s, V, b, medianLambda);
    end

end
