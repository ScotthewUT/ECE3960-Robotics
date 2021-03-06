%% PD controller that takes error terms from reflectance sensor and returns motor duty-cycle commmand.
function [mtr_cmd] = MtrRefCtrl(error, error_delta)

MTR_SPD = 13;
MIN_MTR_SPD = 10;
MAX_MTR_SPD = 18;
KP = 1.9;
KD = 0.4;

mtr_cmd = (KP * error) + (KD * error_delta) + MTR_SPD;
mtr_cmd = round(mtr_cmd);

if mtr_cmd <  MIN_MTR_SPD
    mtr_cmd = MIN_MTR_SPD;
elseif mtr_cmd > MAX_MTR_SPD
    mtr_cmd = MAX_MTR_SPD;
end

end
