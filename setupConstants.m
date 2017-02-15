function constants = setupConstants(input, ip)
defaults = ip.UsingDefaults; 

constants.exp_onset = GetSecs; % record the time the experiment began
constants.device = [];
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
expose = {'subject', 'dominantEye'}; % list of arguments to be exposed to the gui
if any(ismember(defaults, expose))
    % call gui for input
    guiInput = getSubjectInfo('subject', struct('title', 'Subject Number', 'type', 'textinput', 'validationFcn', subjectValidator), ...
        'dominantEye', struct('title' ,'dominantEye', 'type', 'dropdown', 'values', {{'Right','Left'}}));
    if isempty(guiInput)
        % exit_stat = 1;
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
constants.subDir = fullfile(constants.savePath, ['subject', num2str(input.subject)]);
if ~exist(fullfile(constants.subDir), 'dir')
    mkdir(fullfile(constants.subDir));
end
constants.fName = fullfile(constants.subDir,...
    strjoin({'subject', num2str(input.subject)},'_'));


end


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
