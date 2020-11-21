function [S] = SSA_Signal(M, R, SIGN)

% Computing the signal by Singular spectral analysis 
% The implementation is strongly inspired by :
% https://www.mathworks.com/matlabcentral/mlc-downloads/downloads/submissions/58967/versions/2/previews/html/SSA_beginners_guide_v7.html

% INPUT :
    % M : Latent dimension
    % R : Price series
    % SIGN: Signal Length Computations
   
[~, A] = size(R);
S = zeros(1, A);

for F = 1:A % Loop for each asset
    
    % Standardizing the dataset
    R_X = R(:, F);
    meanR = mean(R_X); 
    stdR = std(R_X); 
    R_X = (R_X - meanR)./stdR;

    % Compute the trajectory matrix
    covX(:) = xcorr(R_X(:), M-1, 'unbiased');
    C = toeplitz(covX(M:end));           % Estimate Trajectory Matrix
    [RHO,LAMBDA] = eig(C);               % Matrix of eigenvalues
    LAMBDA = diag(LAMBDA);               % extract the diagonal elements
    [~,ind]=sort(LAMBDA,'descend');      % sort eigenvalues
    RHO = RHO(:,ind);                    % and eigenvectors
    
    % Reconstruct Components
    Y=zeros(SIGN-M+1,M);
    for m=1:M
      Y(:,m) = R_X((1:SIGN-M+1)+m-1);
    end
    PC = Y*RHO;
    S(1, F) = (PC(end, M) - PC(1,M))/PC(end, M); %Extract trend of the first PC
end

% Rescaling Weights 
S(S>2) = 2;
S(S<-2) = -2;
S = rescale(S, -1, 1);


end

