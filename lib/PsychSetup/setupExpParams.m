function expParams = setupExpParams( debugLevel )
%setupDebug setup values specific to debug levels

% some defaults
expParams.robotDelay = 0;
expParams.screen_scale = []; % show at full screen
expParams.stereoMode = 1;

%% Set parameters that change based on debug level
switch debugLevel
    
    case 0
        % Level 0: normal experiment
        expParams.mondrianHertz = 8;
        expParams.iti = 1; % seconds to wait between each trial
        expParams.nTrials = 150;
        expParams.arrowDur = 100; % max duration until arrows are at full contrast
    case 1
        % Level 1: Run through all trials giving correct answers. Speed at
        % anticipanted slowest subject speed
        
        expParams.mondrianHertz = 8;
        expParams.iti = 1;
        expParams.nTrials = 100;
        expParams.arrowDur = 100;
        expParams.robotDelay = 10;
    case 2
        % Level 2: Like 1, but super fast
        expParams.mondrianHertz = 8;
        expParams.iti = .1;
        expParams.nTrials = 100;
        expParams.arrowDur = .1;
        expParams.robotDelay = .2;
end


%% defaults that need calculating
expParams.nTicks = ceil(expParams.arrowDur * expParams.mondrianHertz);

expParams.alpha.mondrian = linspace(1,1,expParams.nTicks);
expParams.alpha.arrow = linspace(0,1,100); % should always take 100

end
