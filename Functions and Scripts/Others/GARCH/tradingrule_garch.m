function [w] = tradingrule_garch(prediction_vol,lvl1,lvl2,lv3,lv4,lv5)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
if nargin > 4
    w = 1;
    if prediction_vol> lvl1 && prediction_vol<=lvl2
        w = 0.9;
    elseif prediction_vol>lvl2 && prediction_vol<=lv3
        w = 0.65;
    elseif prediction_vol>lv3 && prediction_vol<=lv4
        w = 0.55;
    elseif prediction_vol>lv4 && prediction_vol<=lv5
        w = 0.3;
    elseif prediction_vol>lv5
        w = 0.1;
    end
end 

if nargin <= 4
    w = 1;
    if prediction_vol> lvl1 && prediction_vol<=lvl2
        w = 0.7;
    elseif prediction_vol>lvl2 && prediction_vol<=lv3
        w = 0.5;
    elseif prediction_vol>lv3
        w = 0.2;
    end
end

end

