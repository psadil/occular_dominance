function window = setupWindow(input, constants, expParams)

PsychDefaultSetup(2); % assert OpenGL install, unify keys, fix color range
ListenChar(-1);
HideCursor;

window.screenNumber = max(Screen('Screens')); % Choose a monitor to display on
window.res = Screen('Resolution',window.screenNumber); % get screen resolution

try
    %     Screen('Preference', 'ConserveVRAM', 4096);
    
    PsychImaging('PrepareConfiguration');
    %     PsychImaging('AddTask', 'LeftView', 'StereoCrosstalkReduction', 'SubtractOther', 1);
    %     PsychImaging('AddTask', 'RightView', 'StereoCrosstalkReduction', 'SubtractOther', 1);
    
    
    window.bgColor = GrayIndex(window.screenNumber);
    [window.pointer, window.winRect] = PsychImaging('OpenWindow',...
        window.screenNumber, window.bgColor, [], [], [], expParams.stereoMode);
    %     [window.pointer, window.winRect] = Screen('OpenWindow', ...
    %         window.screenNumber, ...
    %         window.bgColor, round(window.screen_scale),...
    %         [], []); % final value is stereo mode. To be adjusted
    Screen('BlendFunction', window.pointer, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
    %     Priority(MaxPriority(window.pointer));
    Priority(1);
    
    
    % define some landmark locations to be used throughout
    [window.xCenter, window.yCenter] = RectCenter(window.winRect);
    window.center = [window.xCenter, window.yCenter];
    window.left_half=[window.winRect(1),window.winRect(2),window.winRect(3)/2,window.winRect(4)];
    window.right_half=[window.winRect(3)/2,window.winRect(2),window.winRect(3),window.winRect(4)];
    window.top_half=[window.winRect(1),window.winRect(2),window.winRect(3),window.winRect(4)/2];
    window.bottom_half=[window.winRect(1),window.winRect(4)/2,window.winRect(3),window.winRect(4)];
    
    % Get some the inter-frame interval, refresh rate, and the size of our window
    window.ifi = Screen('GetFlipInterval', window.pointer);
    window.hertz = FrameRate(window.pointer); % hertz = 1 / ifi
    [window.width, window.height] = Screen('DisplaySize', window.screenNumber); %in mm CAUTION, MIGHT BE WRONG!!
    
    checkRefreshRate(window.hertz, input.refreshRate, constants);
    
    % Font Configuration
    Screen('TextFont',window.pointer, 'Arial');  % Set font to Arial
    Screen('TextSize',window.pointer, 28);       % Set font size to 28
    Screen('TextStyle', window.pointer, 1);      % 1 = bold font
    Screen('TextColor', window.pointer, [0 0 0]); % Black text
catch
    psychrethrow(psychlasterror);
    windowCleanup(window)
end
end

function checkRefreshRate(trueHertz, requestedHertz, constants)

if abs(trueHertz - requestedHertz) > 2
    windowCleanup(constants);
    disp('Set the refresh rate to the requested rate')
end

end
