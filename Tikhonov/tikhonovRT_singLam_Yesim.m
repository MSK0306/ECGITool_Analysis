function [X1,X2,lambda,singLambda] = tikhonovRT_singLam(Y, A, frRange)

% Uses a single (mean or median) lambda value at all times.
% At the moment, it is using the mean value. 
%        Make it an option later!
% frRange [init fin] is the range within the matrix (columns) for which we
% take the median of lambda
%
% Modified to have both single lambda and mult lambda as output.
% TIKHONOVRT    Tikhonov Regularization, uses Regularization toolbox

nFrames = size(Y,2);

if nargin < 3
    %exclude = 100;
    %frRange=[exclude nFrames-2*exclude];
    frRange = [1 nFrames];
end

[U,s,V] = csvd(A);
%[U2,sm,XX,V2] = cgsvd(A,L);

% [lambda, lambda2] = deal(zeros(nFrames, 1));
lambda = zeros(nFrames, 1);
%
% [X, X2] = deal(zeros(size(A,2), nFrames));
[X1,X2] = deal(zeros(size(A,2), nFrames));
% X1 = zeros(size(A,2), nFrames);
% X2 = zeros(size(A,2), nFrames);


for fr = 1:nFrames
    [lambda(fr),~,~,~] = l_curve(U, s, Y(:,fr));
    if lambda(fr)>2
        if fr == 1
            lambda(fr) = 0.05;
        else
            lambda(fr)=lambda(fr-1);
        end
    end
    if lambda(fr)<0.000005
        if fr == 1
            lambda(fr) = 0.05;
        else
            lambda(fr)=lambda(fr-1);
        end
    end
    X1(:,fr) = tikhonov(U,s,V,Y(:,fr),lambda(fr));
    
%     if (fr> 434 && fr< 444)
%         fr
%         pause
%     end
    
    % Code for 2nd order Tikh
    %   [lambda2(fr),wii,wii1,wii2] = l_curve(U2,sm,Y(:,fr),'Tikh',L,V2);
    %   XX(:,fr) = tikhonov(U2,sm,V2,Y(:,fr),lambda2(fr));
end

% singLambda = mean(0.1*lambda(frRange(1):frRange(2)));
%singLambda = 0.0121;
% singLambda = median(lambda(frRange(1):frRange(2)));
singLambda = mean(lambda(frRange(1):frRange(2)));

for fr = 1:nFrames
    X2(:,fr) = tikhonov(U,s,V,Y(:,fr),singLambda);
%     X2(:,fr) = tikhonov(U,s,V,Y(:,fr),0.03);

end
