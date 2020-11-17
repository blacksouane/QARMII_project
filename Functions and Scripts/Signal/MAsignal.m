function [S] = MAsignal(p,MAS, MAL)

%Get a signal for each asset with a comparison of MA (ST / LT)
MA1 = mean(p(end-MAS+1:end, :), 1); %short term
MA2 = mean(p(end-MAL+1:end, :), 1); %long term

S = double(MA1 > MA2); % 0 si plus petit, 1 si plus grand
S(S == 0) = -1;

end
