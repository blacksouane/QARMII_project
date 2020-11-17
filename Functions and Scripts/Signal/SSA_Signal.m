function [S] = SSA_Signal(M, R, MO, SIGN)

% Computing the signal by Singular spectral analysis 
% The implementation is strongly inspired by :
% https://www.mathworks.com/matlabcentral/mlc-downloads/downloads/submissions/58967/versions/2/previews/html/SSA_beginners_guide_v7.html

% INPUT :
    % M : Latent dimension
    % R : Price series
    % MO: Momentum Length
    % SIGN: Signal Length Computations
[~, A] = size(R);
S = zeros(1, A); 
for F = 1:A
    % Standardizing the dataset
    R_X = R(:, F);
    meanR = mean(R_X); 
    stdR = std(R_X); 
    R_X = (R_X - meanR)./stdR;

    % Compute the covariance matrix
    covX(:) = xcorr(R_X(:), M-1, 'unbiased');
    C = toeplitz(covX(M:end)); 
    [RHO,LAMBDA] = eig(C);
    LAMBDA = diag(LAMBDA);               % extract the diagonal elements
    [~,ind]=sort(LAMBDA,'descend'); % sort eigenvalues
    RHO = RHO(:,ind);                    % and eigenvectors

    Y=zeros(MO-M+1,M);
    for m=1:M
      Y(:,m) = R_X((1:MO-M+1)+m-1);
    end
    PC = Y*RHO;

    S(1, F) = (PC(end, 1) - PC(end-SIGN-1,1))/PC(end, 1);
    
end


S(S>2) = 2;
S(S<-2) = -2;
S = rescale(S, -1, 1);

end

