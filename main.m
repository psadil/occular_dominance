function main(varargin)

% Screen('Preference', 'SkipSyncTests', 1);

%% collect input
% use the inputParser class to deal with arguments
ip = inputParser;
%#ok<*NVREPL> dont warn about addParamValue
addParamValue(ip,'subject', 0, @isnumeric);
addParamValue(ip,'dominantEye', 'Right', @(x) sum(strcmp(x, {'Left','Right'}))==1);
addParamValue(ip,'refreshRate', 120, @isnumeric);
addParamValue(ip,'debugLevel',0, @(x) isnumeric(x) && x >= 0);
addParamValue(ip,'responder', 'user', @(x) sum(strcmp(x, {'user','simpleKeypressRobot'}))==1)
parse(ip,varargin{:});
input = ip.Results;


%% setup
rng('shuffle'); % set up and seed the randon number generator
PsychDefaultSetup(2); % assert OpenGL install, unify keys, fix color range
constants = setupConstants(input, ip);
expParams = setupExpParams(input.debugLevel);

demographics = getDemographics(constants);

window = setupWindow(input, constants, expParams);

data = setupDataTable(expParams, input, demographics);
keys = setupKeys;
[mondrians, window] = makeMondrianTexes(window);
arrows = makeArrowTexes(window);

responseHandler = makeInputHandlerFcn(input.responder);


%% main experimental loop

giveInstruction(window, keys, responseHandler, constants, expParams);

answers = [{'LeftArrow'}, {'RightArrow'}];
for trial = 1:expParams.nTrials
    
    % function that presents arrow stim and collects response
    [ data.response(trial), data.rt(trial), exit_flag] = ...
        elicitArrowResponse(window, responseHandler,...
        arrows(data.correctDirection(trial)).tex, data.rightEye(trial),...
        keys, mondrians, expParams, constants, answers(data.correctDirection(trial)));
    
    if exit_flag==1
        break;
    end
    
    if mod(trial,10)==0 && trial ~= expParams.nTrial
        showReminder(window, 'Remember to keep your eyes focusd on the center white square',...
            keys,constants,responseHandler,expParams);
    end
    
    % inter-trial-interval
    iti(window, expParams.iti);
       
end

%% save data and exit
writetable(data, [constants.fName, '.csv'])

% end of the experiment
windowCleanup(constants)
end

function [] = giveInstruction(window, keys, responseHandler, constants, expParams)

showReminder(window, 'Use the arrow keys to say which direction you think the arrow faced.',...
    keys,constants,responseHandler,expParams);
showReminder(window, 'Keep your eyes focused on the center white square',...
    keys,constants,responseHandler,expParams);

iti(window, 1);

end

function iti(window, dur)

drawFixation(window);
Screen('Flip', window.pointer);
WaitSecs(dur);
drawFixation(window);
Screen('Flip', window.pointer);

end

function [] = showReminder(window, prompt, keys,constants,responseHandler,expParams)

for eye = 0:1
    Screen('SelectStereoDrawBuffer',window.pointer,eye);
    DrawFormattedText(window.pointer,prompt,...
        'center', 'center');
    DrawFormattedText(window.pointer, '[Press Space to Continue]', ...
        'center', window.winRect(4)*.8);
end
Screen('Flip', window.pointer);
waitForSpace(keys,constants,responseHandler, expParams);

end

function [] = waitForSpace(keys,constants,responseHandler, expParams)

KbQueueCreate(constants.device, keys.space);
KbQueueStart(constants.device);
while 1
    
    [keys_pressed, ~] = responseHandler(constants.device, 'SPACE', expParams.robotDelay);
    
    if ~isempty(keys_pressed)
        break;
    end
end
end

