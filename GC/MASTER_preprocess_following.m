% ALERT! This script can take ~40 minutes to run

%% Preprocess data for MVGC toolbox
% Lucas Klein
% Edited January 2022

% This script reads in data from each participant stored as text files and
% assigns that data to variables with the following convention: 

clear variables

% ~~~ CHANGE THESE ~~~
which_piece = 1; % 1 for DB, 2 for ITG
section = 'whole';

if which_piece == 1
    piece = 'Danny Boy';
else
    piece = 'In The Garden';
end


%% FIND DATA
% Make sure these filenames match those of the experiment we're running

addpath(genpath('~/Desktop/Following/ANALYSIS/'))
data_folder = ['~/Desktop/Following/ANALYSIS/',piece,'/'];
cd(data_folder)
path_perf = [data_folder,'Txts_P',section];
path_stim = [data_folder,'Txts_S',section];

path_contents = dir(path_perf); % struct
num_participants = size(path_contents,1) - 3; % This takes away the 3 nonsense entries


%% PARAMETERS
sf = 44100;
ds_targets = [8];
plotting_flag = 0;


%% Make a list of participants
participants = string(zeros(1,num_participants)); % empty list
for p = 4:length(path_contents) % Because the 1st, 2nd and 3rd elements in data_folder.name are nonsense
    par = path_contents(p).name;
    participants(p-3) = par; % fill the participant list
end
% 'participants' is now an arrray of strings with all participants' names

% We will save the data to a cell array with one cell for each participant
D = cell(1,numel(participants));


%% GET DATA
% Loop through each participant's folder and find all .txt files
% (trials)
for p = 1:numel(participants)
    participant_folder_perf = append(path_perf,'/',participants(p));
    participant_folder_stim = append(path_stim,'/',participants(p));
    addpath(participant_folder_perf);
    addpath(participant_folder_stim);
    filenames = dir(fullfile(participant_folder_perf,'*.txt'));
    filenames_stim = dir(fullfile(participant_folder_stim,'*.txt'));
    
    DATA = cell(1,numel(filenames)); % Preallocate a temporary cell array

    for trial = 1:numel(filenames)
        filename = filenames(trial).name;
        filename_stim = filenames_stim(trial).name; % CHANGED: trial=1
        X = load(filename);
        stim = load(filename_stim);
        %X = X(:,1); % Which column to use? (1 or 2)
        %stim = X(:,1); % Which column to use? (1 or 2)
        
        % Truncate both time series to the length of the shortest
        trunc = min(length(X),length(stim));
        X = X(1:trunc,1);
        stim = stim(1:trunc,1);
        
        % Check the data
        if plotting_flag == 1
            plot(X)
            hold on
            plot(stim)
        end
        
        %% For this trial, loop through all the downsampling rates we want to check
        % For each one, downsample and z-score both the stimulus and
        % performance using the prepare_following function
        for ds_target = ds_targets
            
            % Downsample and z-score the data
            stim_prep = prepare_following(stim, ds_target, sf, plotting_flag);
            X_prep = prepare_following(X, ds_target, sf, plotting_flag);

            combined = cat(3,X_prep,stim_prep);
            
            % Within consecutive cells in DATA (cell array), make a new struct
            % for each trial and load data into a field within each
            ds_label = ['ds_prep_' + string(ds_target)];
            DATA{trial}.(ds_label) = combined; % Make new field for each trial
            DATA{trial}.participant = participants(p);
            %DATA{trial}.fields = fieldnames(DATA{trial});

        end
        
    end
    % At this point, DATA has a cell for each trial, each of which contain
    % one struct for each downsample target (and one for participant name)

    %% SAVE THE DATA
    % Save a NEW variable D that contains a cell for each participant, each of
    % which contains one struct with fields for each downsample target.
    % Each field is a (nvars x nobs x ntrials) matrix

    %plotting_flag = 0; % Set to 1 if you want to plot all the matrices
    
    for ds_tar = ds_targets
        M_label = ['M_' + string(ds_tar)];
        D{p}.(M_label) = create_matrix_following(DATA, ds_tar, plotting_flag);
        D{p}.participant = participants(p);
    end 
        
end


% Now take this variable D over to the mvgc toolbox for GC!
%save(['/Users/lucas/Desktop/Following/ANALYSIS/D',piece],'D')
save([data_folder,'D_',piece,'_',section],'D')

