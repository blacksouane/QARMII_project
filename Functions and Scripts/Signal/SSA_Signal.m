function [S] = SSA_Signal(latentDim, priceSerie, trajectoryLength, varargin)

% INPUT :
    % latentDim : Latent dimension
    % priceSerie : Price series
    % trajectoryLength: Signal Length Computations
 
    
%% Input Parsing
%Create Parser Object
ssaSignalInput = inputParser; 

% Define scale parameters
defaultScale = 1; 
checkScale = @(x) isnumeric(x) && (x <= 10);

% Define MinMax parameters
defaultMinMax =  2; 
checkMinMax = @(x) isnumeric(x) && (x <= 10); 

% Create Parsing Structure
addRequired(ssaSignalInput, 'latentDim');
addRequired(ssaSignalInput, 'priceSerie');
addRequired(ssaSignalInput, 'trajectoryLength'); 
addParameter(ssaSignalInput, 'scale', defaultScale, checkScale); 
addParameter(ssaSignalInput, 'minMax', defaultMinMax, checkMinMax); 

% Parse the inputs
parse(ssaSignalInput, latentDim, priceSerie, trajectoryLength, varargin{:})

%% Parameters
[~, A] = size(priceSerie);
S = zeros(1, A);

for F = 1:A % Loop for each asset
    
    % Standardizing the dataset
    R_X = priceSerie(:, F);
    meanR = mean(R_X); 
    stdR = std(R_X); 
    R_X = (R_X - meanR)./stdR;

    % Compute the trajectory matrix
    covX(:) = xcorr(R_X(:), latentDim-1, 'unbiased');
    C = toeplitz(covX(latentDim:end));    % Estimate Trajectory Matrix
    [RHO,LAMBDA] = eig(C);               % Matrix of eigenvalues
    LAMBDA = diag(LAMBDA);               % extract the diagonal elements
    [~,ind]=sort(LAMBDA,'descend');      % sort eigenvalues
    RHO = RHO(:,ind);                    % and eigenvectors
    
    % Reconstruct Components
    Y=zeros(trajectoryLength-latentDim+1,latentDim);
    for m=1:latentDim
      Y(:,m) = R_X((1:trajectoryLength-latentDim+1)+m-1);
    end

    PC = Y*RHO;
    S(1, F) = (PC(end, 1) - PC(1, 1))/PC(end, 1); %Extract trend of the first PC
end

% Rescaling weights
S = rescale(S,- ssaSignalInput.Results.scale, ssaSignalInput.Results.scale, ...
    'InputMin', -ssaSignalInput.Results.minMax, 'InputMax', ssaSignalInput.Results.minMax);
end

