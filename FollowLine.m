%% PRIMARY LINE-FOLLOWING LOOP
function [at_intrsctn] = FollowLine(bot, ir_cal_data)

% DEFINE CONSTANTS
BUZZER_PIN = 14;
IR_RR = 1;
IR_CR = 2;
IR_CL = 3;
IR_LL = 4;
IR_OUTER_WEIGHT = 2.5;
MTR_R = 3;
MTR_L = 4;
% INITIALiZE VARIABLES
at_intrsctn = 0;
intrsctn_thr = 0.75;
lost_thr = 0.2;
r_mtr_cmd = 0;
l_mtr_cmd = 0;
error = 0;
error_delta = 0;
prev_error = 0;
% count = 0;
% FOLLOW LINE UNTIL INTERSECTION DETECTED
while true
    bot.setRGB(0, 0, 255);
    % Get reflectance sensor reading and offset it with calibration data
    ref = CalibrateRefReading(bot.readReflectance(), ir_cal_data);
    % Check for intersection
    if ref(IR_RR) > intrsctn_thr && ref(IR_CR) > intrsctn_thr ...
                 && ref(IR_CL) > intrsctn_thr && ref(IR_LL) > intrsctn_thr
            bot.motor(MTR_R, 0);
            bot.motor(MTR_L, 0);
            fprintf("INTERSECTION DETECTED!\n");
            at_intrsctn = 1;
            bot.motor(MTR_L, 0);
            bot.motor(MTR_R, 0);
            bot.setRGB(0, 255, 225);
            bot.digitalWrite(BUZZER_PIN, 1);
            pause(0.1);
            bot.digitalWrite(BUZZER_PIN, 0);
            pause(0.2);
            bot.digitalWrite(BUZZER_PIN, 1);
            pause(0.1);
            bot.digitalWrite(BUZZER_PIN, 0);
            pause(0.05);
            return;
    % Check if path was lost
    elseif ref(IR_RR) < lost_thr && ref(IR_CR) < lost_thr ...
            && ref(IR_CL) < lost_thr && ref(IR_LL) < lost_thr
        bot.motor(MTR_R, 0);
        bot.motor(MTR_L, 0);
        fprintf("OH NO!  WHERE'S THE LINE?!  WHERE AM I?\n");
        bot.setRGB(255, 0, 0);
        bot.digitalWrite(BUZZER_PIN, 1);
        pause(0.2);
        bot.digitalWrite(BUZZER_PIN, 0);
        pause(0.05);
        bot.setRGB(210,45,0);
        line_found = RecoverLine(bot, ir_cal_data);
        if line_found
            continue;
        else
            fprintf("PATH LOST!  ;(\n");
            bot.setRGB(255, 0, 0);
            bot.digitalWrite(BUZZER_PIN, 1);
            pause(0.5);
            bot.digitalWrite(BUZZER_PIN, 0);
            pause(0.05);
            return;
        end
        return;
    end
    % Calculate error from reflectance readings & weighted outer sensors
    error = -IR_OUTER_WEIGHT * ref(IR_RR) - ref(IR_CR) + ref(IR_CL) + IR_OUTER_WEIGHT * ref(IR_LL);
    % Calculate the error rate of change
    error_delta = error - prev_error;
    % Save the error for next loop
    prev_err = error;
    % Get motor commands from PD-controller
    r_mtr_cmd = MtrRefCtrl(error, error_delta);
    l_mtr_cmd = MtrRefCtrl(-error, -error_delta);
    % Update motor commands
    bot.motor(MTR_R, r_mtr_cmd);
    bot.motor(MTR_L, l_mtr_cmd);
    % Occasionally print error and motor commands
%     if mod(count,12) == 0
%         fprintf("Err = %.2f | R = %i | L = %i\n", round(error,2), r_mtr_cmd, l_mtr_cmd);
%     end
%     count = count + 1;
    
end

end
