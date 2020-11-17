function e = sarimax_errors(parameters,p,q,constant,seasonal,y,x,sigma)
% PURPOSE:
%   Likelihood function for armaxfilter
%
% USAGE:
%   [LLF, LIKELIHOODS, ERRORS] = armaxfilter_likelihood(PARAMETERS,P,Q,CONSTANT,Y,X,M)
%   [LLF, LIKELIHOODS, ERRORS] = armaxfilter_likelihood(PARAMETERS,P,Q,CONSTANT,Y,X,M)
%
% INPUTS:
%   PARAMETERS  - A vector of GARCH process aprams of the form [constant, arch, garch]
%   P           - Vector containing lag indices of the AR component
%   Q           - Vector containing lag indices of the MA component
%   CONSTANT    - Value indicating whether the model contains a constant (1) or not (0)
%   Y           -
%   X           -
%   M           - Index to first element to use in the recursive residual calculation
%   SIGMA       - T by 1 vector
%
% OUTPUTS:
%   LLF         - Minus 1 times the log likelihood
%   LIKELIHOODS - Time series of likelihoods
%   ERRORS      - Time series of model errors
%
% COMMENTS:
%
% See also armaerrors

% Author: Kevin Sheppard
% kevin.sheppard@economics.ox.ac.uk
% Revision: 3    Date: 4/1/2004

m = size(x,2);
[armaParameters, p, q] = sarma2arma(parameters(m+1:length(parameters)), p, q, seasonal);
parameters = [parameters(1:m);armaParameters];
e = armaxerrors(parameters,p,q,constant,y,x,m,sigma);
