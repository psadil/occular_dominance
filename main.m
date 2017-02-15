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
addParamValue(ip,'responder', 'user', @(x) sum(strcmp(x, {'user','robot'}))==1)
parse(ip,varargin{:});
input = ip.Results;


%% setup
rng('shuffle'); % set up and seed the randon number generator
PsychDefaultSetup(2); % assert OpenGL install, unify keys, fix color range
constants = setupConstants(input, ip);
expParams = setupExpParams(input.debugLevel);

[demographics] = getDemographics(constants);

window = setupWindow(input, constants, expParams);

data = setupDataTable(expParams, input, demographics);
keys = setupKeys;
[mondrians, window] = makeMondrianTexes(window);
arrows = makeArrowTexes(window);

responseHandler = makeInputHandlerFcn(input.responder);


%% main experimental loop

giveInstruction(window, keys, responseHandler, constants);


for trial = 1:expParams.nTrials
    
    % function that presents arrow stim and collects response
    [ data.response(trial), data.rt(trial), exit_flag] = ...
        elicitArrowResponse(window, responseHandler,...
        arrows(data.correctDirection(trial)).tex, data.rightEye(trial),...
        keys, mondrians, expParams, constants);
    
    % inter-trial-interval
    iti(window, expParams.iti);
    
    if exit_flag==1
        break;
    end
end

%% save data and exit
writetable(data, [constants.fName, '.csv'])

% end of the experiment
windowCleanup(constants)
end

function [] = giveInstruction(window, keys, responseHandler, constants)

for eye = 0:1
    Screen('SelectStereoDrawBuffer',window.pointer,eye);
    DrawFormattedText(window.pointer,'Use the arrow keys to say which direction you think the arrow faced.',...
        'center', 'center',[],[],[],[],1.5);
    DrawFormattedText(window.pointer, '[Press Space to Continue]', ...
        'center', window.winRect(4)*.8);
end
Screen('Flip', window.pointer);
waitForSpace(keys,constants,responseHandler);

for eye = 0:1
    Screen('SelectStereoDrawBuffer',window.pointer,eye);
    DrawFormattedText(window.pointer,'Keep your eyes focused on the center white square',...
        'center', 'center',[],[],[],[],1.5);
    DrawFormattedText(window.pointer, '[Press Space to Continue]', ...
        'center', window.winRect(4)*.8);
end
Screen('Flip', window.pointer);
waitForSpace(keys,constants,responseHandler);

iti(window, 1);

end

function iti(window, dur)

for eye = 0:1
    Screen('SelectStereoDrawBuffer',window.pointer,eye);
    Screen('FillRect',window.pointer,1,CenterRect([0 0 8 8],window.shifts));
end
Screen('Flip', window.pointer);
WaitSecs(dur);
for eye = 0:1
    Screen('SelectStereoDrawBuffer',window.pointer,eye);
    Screen('FillRect',window.pointer,1,CenterRect([0 0 8 8],window.shifts));
end
Screen('Flip', window.pointer);

% end
end

function [] = waitForSpace(keys,constants,responseHandler)

KbQueueCreate(constants.device, keys.space);
KbQueueStart(constants.device);
while 1
    
    [keys_pressed, ~] = responseHandler(constants.device);
    
    if ~isempty(keys_pressed)
        % There should ideally be only one, keypress ever. If there happens
        % to be more than one keypress, only take the first one.
        % Add the direction just pressed to the input
        % string, and record the timestamp of its keypress.
        % For arrow response, this will produce either 'left' or 'right'
        
        break;
        
    end
end
end