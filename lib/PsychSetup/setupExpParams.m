function expParams = setupExpParams( debugLevel )
%setupDebug setup values specific to debug levels

%% Set parameters that change based on debug level
switch debugLevel
    
    % Level 0: normal experiment
    case 0
        expParams.mondrianHertz = 8;
        expParams.iti = 1; % seconds to wait between each trial
        expParams.nTrials = 100;
        expParams.arrowDur = 100; % max duration until arrows are at full contrast
        expParams.screen_scale = []; % show at full screen
        expParams.stereoMode = 1;
        % Level 1: instant experiment, useful for checking extreme timing and
        % whether experiment finishes
    case 1
        expParams.testDur = 1; % duration to provide response, in seconds
        expParams.mondrianHertz = 8;
        expParams.iti = 0; % seconds to wait between each trial
        expParams.nTrials = 100;
        expParams.arrowDur = 10; % max duration until arrows are at full contrast
        
        % Level 2: show at half screen
    case 2
        expParams.mondrianHertz = 8;
        expParams.iti = .5; % seconds to wait between each trial
        expParams.nTrials = 10;
        expParams.arrowDur = 10; % max duration until arrows are at full contrast
%         expParams.screen_scale = reshape((window.dims' * [(1/8),(7/8)]),1,[]);
end


%% Set parameters that will be true regardless of debug level
expParams.nTicks = ceil(expParams.arrowDur * expParams.mondrianHertz);

expParams.alpha.mondrian = linspace(1,1,expParams.nTicks); 
expParams.alpha.arrow = linspace(0,1,100); % should always take 100


end
