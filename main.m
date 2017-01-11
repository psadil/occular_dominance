function exit_stat = main(varargin)

exit_stat = 1; %#ok<NASGU> assume that we exited badly if ever exit before this gets reassigned
% use the inputParser class to deal with arguments
ip = inputParser;
%#ok<*NVREPL> dont warn about addParamValue
addParamValue(ip,'subject', 0, @isnumeric);
addParamValue(ip,'group', 1, @is.numeric);
addParamValue(ip,'refreshRate', 60, @isnumeric);
addParamValue(ip,'debugLevel',1, @isnumeric);
parse(ip,varargin{:});
input = ip.Results;

rng('shuffle'); % set up and seed the randon number generator, so lists get properly permuted


constants = setupConstants(input, ip);

if input.debugLevel >= 1
    inputHandler = makeInputHandlerFcn('GoodRobot');
elseif input.debugLevel == 0
    inputHandler = makeInputHandlerFcn('KbQueue');
end


[window, constants] = windowSetup(constants, input);

% data = experimentWrapper(input);
% 
% writeTable(data, [constants.fName, '.csv'])

%% end of the experiment %%
windowCleanup(constants)
exit_stat=0;
end % end main()

%%
function overwriteCheck = makeSubjectDataChecker(directory, extension, debugLevel)
% makeSubjectDataChecker function closer factory, used for the purpose
% of enclosing the directory where data will be stored. This way, the
% function handle it returns can be used as a validation function with getSubjectInfo to
% prevent accidentally overwritting any data.
    function [valid, msg] = subjectDataChecker(value, ~)
        % the actual validation logic
        
        subnum = str2double(value);
        if (~isnumeric(subnum) || isnan(subnum)) && ~isnumeric(value);
            valid = false;
            msg = 'Subject Number must be greater than 0';
            return
        end
        
        filePathGlobUpper = fullfile(directory, ['*Subject', value, '*', extension]);
        filePathGlobLower = fullfile(directory, ['*subject', value, '*', extension]);
        if ~isempty(dir(filePathGlobUpper)) || ~isempty(dir(filePathGlobLower)) && debugLevel <= 2
            valid= false;
            msg = strjoin({'Data file for Subject',  value, 'already exists!'}, ' ');
        else
            valid= true;
            msg = 'ok';
        end
    end

overwriteCheck = @subjectDataChecker;
end

%%
function windowCleanup(constants)
sca; % alias for screen('CloseAll')
rmpath(constants.lib_dir,constants.root_dir);
end

%%
function [window, constants] = windowSetup(constants, input)
PsychDefaultSetup(2); % assert OpenGL install, unify keys, fix color range

constants.screenNumber = max(Screen('Screens')); % Choose a monitor to display on
constants.res=Screen('Resolution',constants.screenNumber); % get screen resolution
constants.dims = [constants.res.width constants.res.height];
if any(input.debugLevel == [0, 1])
    % Set the size of the PTB window based on screen size and debug level
    constants.screen_scale = [];
else
    constants.screen_scale = reshape((constants.dims' * [(1/8),(7/8)]),1,[]);
end

try
%     PsychImaging('PrepareConfiguration');
%     PsychImaging('AddTask', 'LeftView', 'StereoCrosstalkReduction', 'SubtractOther', 1);
%     PsychImaging('AddTask', 'RightView', 'StereoCrosstalkReduction', 'SubtractOther', 1);
%     
    
    [window, constants.winRect] = Screen('OpenWindow', ...
        constants.screenNumber, ...
        (2/3)*WhiteIndex(constants.screenNumber) , round(constants.screen_scale),...
        [], []); % final value is stereo mode. To be adjusted
%     Screen(p.window,'BlendFunction','GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
    Priority(MaxPriority(window));
    
    
    % define some landmark locations to be used throughout
    [constants.xCenter, constants.yCenter] = RectCenter(constants.winRect);
    constants.center = [constants.xCenter, constants.yCenter];
    constants.left_half=[constants.winRect(1),constants.winRect(2),constants.winRect(3)/2,constants.winRect(4)];
    constants.right_half=[constants.winRect(3)/2,constants.winRect(2),constants.winRect(3),constants.winRect(4)];
    constants.top_half=[constants.winRect(1),constants.winRect(2),constants.winRect(3),constants.winRect(4)/2];
    constants.bottom_half=[constants.winRect(1),constants.winRect(4)/2,constants.winRect(3),constants.winRect(4)];
    
    % Get some the inter-frame interval, refresh rate, and the size of our window
    constants.ifi = Screen('GetFlipInterval', window);
    constants.hertz = FrameRate(window); % hertz = 1 / ifi
%     constants.nominalHertz = Screen('NominalFrameRate', window); %
    %        pretty sure this just does the same thing as the line above...
    [constants.width, constants.height] = Screen('DisplaySize', constants.screenNumber); %in mm CAUTION, MIGHT BE WRONG!!
    
    checkRefreshRate(constants, input);
    
    % Font Configuration
    Screen('TextFont',window, 'Arial');  % Set font to Arial
    Screen('TextSize',window, 28);       % Set font size to 28
    Screen('TextStyle', window, 1);      % 1 = bold font
    Screen('TextColor', window, [0 0 0]); % Black text
catch
    psychrethrow(psychlasterror);
    windowCleanup(constants)
end
end

%%
function checkRefreshRate(constants, input)

if abs(constants.hertz - input.refreshRate) > 2
    windowCleanup(constants);
    disp('Set the refresh rate to the requested rate')
end

end

%%
function constants = setupConstants(input, ip)
defaults = ip.UsingDefaults; % If any input was not given, ask for it!

constants.exp_onset = GetSecs; % record the time the experiment began

% Get full path to the directory the function lives in, and add it to the path
constants.root_dir = fileparts(mfilename('fullpath'));
constants.lib_dir = fullfile(constants.root_dir, 'lib');
path(path,constants.root_dir);
path(path, genpath(constants.lib_dir));

% Make the data directory if it doesn't exist (but it should!)
if ~exist(fullfile(constants.root_dir, 'data'), 'dir')
    mkdir(fullfile(constants.root_dir, 'data'));
end

% Define the location of some directories we might want to use
constants.stimDir=fullfile(constants.root_dir,'stimuli');
constants.savePath=fullfile(constants.root_dir,'data');

% instantiate the subject number validator function
subjectValidator = makeSubjectDataChecker(constants.savePath, '.csv', input.debugLevel);

%% -------- GUI input option ----------------------------------------------------
expose = {'subject', 'group'}; % list of arguments to be exposed to the gui
if any(ismember(defaults, expose))
    % call gui for input
    guiInput = getSubjectInfo('subject', struct('title', 'Subject Number', 'type', 'textinput', 'validationFcn', subjectValidator), ...
        'group', struct('title' ,'Group', 'type', 'dropdown', 'values', {{'immediate','delay'}}));
    if isempty(guiInput)
        exit_stat = 1;
        return
    else
        input = filterStructs(input,guiInput);
        input.subject = str2double(input.subject);
    end
else
    [validSubNum, msg] = subjectValidator(input.subject, '.csv', input.debugLevel);
    assert(validSubNum, msg)
end

% now that we have all the input and it has passed validation, we can have
% a file path!
constants.fName = fullfile(constants.savePath,...
    strjoin({'Subject', num2str(input.subject), 'Group',num2str(input.group)},'_'));


end