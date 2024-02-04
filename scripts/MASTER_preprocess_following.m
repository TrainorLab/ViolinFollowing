% ALERT! This script can take ~40 minutes to run

%% Preprocess data for MVGC toolbox
% Lucas Klein
% Edited December 2023

% This script reads in data from each participant stored as text files and
% assigns that data to variables with the following convention:


%% ~~~~~~~~~~ FIND DATA ~~~~~~~~~~
clear variables
cd('~/Desktop/Following/analysis/')
save_flag = 1; % set this to 1 to save the Feat variable to .mat file

% CHANGE THESE!
which_piece = 1; % 1 for Danny Boy, 2 for In The Garden
switch which_piece
    case 1
        piece = 'Danny Boy';
    case 2
        piece = 'In The Garden';
end

section = 'whole';
datadir = ['../data/',piece,'/'];
path_perf = [datadir,'Performance_',section];
path_stim = [datadir,'Stim_out_',section];
path_contents = dir(path_perf); % struct

participants = {}; %string(zeros(1,num_participants)); % empty list
for p = 4:length(path_contents) % Because the 1st, 2nd and 3rd elements in data_folder.name are placeholders
    participants = [participants; path_contents(p).name];
end
% 'participants' is now a cell array with all participants' names


%% ~~~~~~~~~~ SETUP ~~~~~~~~~~
% Parameters
sf = 44100;
ds_targets = [0,6,8,10]; % 0 ds_target --> no downsampling
%M_lab = ['M_' + string(ds_target)];
plotting_flag = 0;

% To save data
Feat = struct();
for i = 1:numel(participants)
    Feat(i).piece = piece;
    Feat(i).name = 'Participant_' + string(i);
    Feat(i).ds_targets = ds_targets;
    %Feat(i).raw_wavs = []; % takes lots of disk space
    for dst = ds_targets
        Feat(i).(['ds_', num2str(dst)]).morder = '';
        Feat(i).(['ds_', num2str(dst)]).env.alltrials = ''; % for saving cell array of all trials separated
        Feat(i).(['ds_', num2str(dst)]).specflux.alltrials = '';
        Feat(i).(['ds_', num2str(dst)]).env.matrix = ''; % for saving GC-ready matrix of all trials
        Feat(i).(['ds_', num2str(dst)]).specflux.matrix = '';
    end
end


%% ~~~~~~~~~~ GET DATA ~~~~~~~~~~
for p = 1:numel(participants) % Loop through each participant's folder
    disp(['Computing: participant ' num2str(p) '/' num2str(numel(participants))]);

    files_perf = [path_perf '/Part' num2str(p) '/']; % paths to audio files
    files_stim = [path_stim '/Part' num2str(p) '/'];
    
    for ds_target = ds_targets

        % Preallocate temporary cell arrays
        DATA_env = cell(1,8); % for saving cell array of all trials separately as envelopes
        DATA_specflux = cell(1,8); % for saving cell array of trials separately as spectral flux
        DATA = cell(1,8); % for envs and specfluxs as matrices of all trials combined
        for trial = 1:8 % loop over trials to find each successive audio file
            filename_perf = [files_perf num2str(p) 'P_T' num2str(trial) '.wav'];
            filename_stim = [files_stim num2str(p) 'S_T' num2str(trial) '.wav'];
            
            % Import
            [perf, fs_perf] = audioread([filename_perf]);
            [stim, fs_stim] = audioread([filename_stim]);
            
            % Check the data
            if plotting_flag == 1
                plot(perf)
                hold off
                plot(stim)
            end
            
            %% COMPUTE AUDIO FEATURES
            % Amplitude envelope
            env_perf_prep = envelope(perf);
            env_stim_prep = envelope(stim);
            
            % Spectral flux
            specflux_perf_prep = spectralFlux(perf, fs_perf); % this uses ~440 windows
            specflux_stim_prep = spectralFlux(stim, fs_stim); % because default is 100 Hz
            % NOTE: do we need to add a zero? eg. [0; spectralFlux(perf, fs_perf)];
% Resulting time series is 8076 data points
% ~80s/8076 ~= 0.01 s ~= 100 data points per second --> 100 Hz
            
            fs = 100; % default sampling rate of specflux function
            % this means the specflux time series is at 100 Hz
            if ds_target ~= 0 % downsample both time series
                env_perf_prep = resample(env_perf_prep, ds_target, fs_perf);
                env_stim_prep = resample(env_stim_prep, ds_target, fs_stim);

                specflux_perf_prep = resample(specflux_perf_prep, ds_target, fs);
                specflux_stim_prep = resample(specflux_stim_prep, ds_target, fs);
            end
            
            % Truncate both time series to the length of the shortest
            [env_perf_prep, env_stim_prep] = prepare_following(env_perf_prep, env_stim_prep);
            [specflux_perf_prep, specflux_stim_prep] = prepare_following(specflux_perf_prep, specflux_stim_prep);
            % trunc = min(length(env_perf_prep),length(env_stim_prep));
            % env_perf_prep = env_perf_prep(1:trunc,1);
            % env_stim_prep = env_stim_prep(1:trunc,1);
            % 
            % trunc = min(length(env_perf_prep),length(env_stim_prep));
            % env_perf_prep = env_perf_prep(1:trunc,1);
            % env_stim_prep = env_stim_prep(1:trunc,1);

            %% SAVE THE DATA
            % Combine and save - For now try both ways
            %DATA_env{trial} = cat(3,env_perf_prep,env_stim_prep); % for saving raw data
            %DATA_specflux{trial} = cat(3,specflux_perf_prep,specflux_stim_prep);
            DATA{trial}.env = cat(3,env_perf_prep,env_stim_prep); % for formatting data into GC matrix
            DATA{trial}.specflux = cat(3,specflux_perf_prep,specflux_stim_prep);
            %DATA{trial}.fields = fieldnames(DATA{trial});
        end
        
        %Feat(p).(['ds_', num2str(ds_target)]).env.alltrials = DATA_env;
        %Feat(p).(['ds_', num2str(ds_target)]).specflux.alltrials = DATA_specflux;
        Feat(p).(['ds_', num2str(ds_target)]).env.matrix = create_matrix_following(DATA, 'env', plotting_flag);
        Feat(p).(['ds_', num2str(ds_target)]).specflux.matrix = create_matrix_following(DATA, 'specflux', plotting_flag);
    end
end

switch save_flag
    case 1
        save(['~/Desktop/Following/analysis/',piece,'/Feat_',piece,'_',section,'.mat'], 'Feat', '-v7.3')
end
% Now take this variable D over to the mvgc toolbox for GC!
%save(['/Users/lucas/Desktop/Following/ANALYSIS/D',piece],'D')
%save([data_folder,'D_',piece,'_',section],'D')


% ~~~~~
function specflux = zeropadSF(specflux_raw, desiredLen)
  lenDiff = desiredLen - length(specflux_raw);
  if lenDiff==0
    specflux = speflux_raw;
  elseif lenDiff>0;
    specflux = [specflux_raw; repmat(0, lenDiff, 1)];
  else
    specflux = specflux_raw(end-lenDiff);
  end
end

