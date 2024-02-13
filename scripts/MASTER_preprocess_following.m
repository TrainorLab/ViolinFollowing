% ALERT! This script can take ~40 minutes to run

%% Preprocess data for MVGC toolbox
% Lucas Klein
% Edited December 2023

% Saves a .mat file for a specific piece

% REQUIREMENTS
% piece, section


%% ~~~~~~~~~~ FIND DATA ~~~~~~~~~~
datadir = ['../data/',piece,'/'];
path_perf = [datadir,'Performance_',section];
path_stim = [datadir,'Stim_out_',section];
path_contents = dir(path_perf); % struct

participants = {}; %string(zeros(1,num_participants)); % empty list
for par = 4:length(path_contents) % Because the 1st, 2nd and 3rd elements in data_folder.name are placeholders
    participants = [participants; path_contents(par).name];
end
% 'participants' is now a cell array with all participants' names


%% ~~~~~~~~~~ SETUP ~~~~~~~~~~
% Parameters
sf = 44100;

% To save data
Feats = struct(); % struct to save stimulus features
for i = 1:numel(participants)
    Feats(i).piece = piece;
    Feats(i).name = 'Participant_' + string(i);
    Feats(i).ds_targets = ds_targets;
    %Feat(i).raw_wavs = []; % takes lots of disk space
    for f = 1:length(features)
        feature = features{f};
        for dst = ds_targets
            Feats(i).(['ds_', num2str(dst)]).(feature).matrix = ''; % for saving GC-ready matrix of all trials
            Feats(i).(['ds_', num2str(dst)]).(feature).pval = '';
            Feats(i).(['ds_', num2str(dst)]).(feature).cd_data = '';
            Feats(i).(['ds_', num2str(dst)]).(feature).GC_data = '';
            Feats(i).(['ds_', num2str(dst)]).(feature).CC_data_full = '';
            Feats(i).(['ds_', num2str(dst)]).(feature).CC_data_wcc = '';
            Feats(i).(['ds_', num2str(dst)]).(feature).morder = '';
            %Feats(i).(['ds_', num2str(dst)]).env.alltrials = ''; % for saving cell array of all trials separated
        end
    end
end


%% ~~~~~~~~~~ GET DATA ~~~~~~~~~~
for p = 1:numel(participants) % Loop through each participant's folder
    disp(['Computing: participant ' num2str(p) '/' num2str(numel(participants))]);

    files_perf = [path_perf '/Part' num2str(p) '/']; % paths to audio files
    files_stim = [path_stim '/Part' num2str(p) '/'];

    % Preallocate temporary cell arrays for saving features
    DATA_env = cell(length(ds_targets),8); % ds_targets x trials
    DATA_specflux = cell(length(ds_targets),8); % ds_targets x trials
    %DATA = cell(1,8); % for envs and specfluxs as matrices of all trials combined
    for trial = 1:8 % loop over trials to find each successive audio file
        filename_perf = [files_perf num2str(p) 'P_T' num2str(trial) '.wav'];
        filename_stim = [files_stim num2str(p) 'S_T' num2str(trial) '.wav'];
        
        % Import
        [perf, fs_perf] = audioread([filename_perf]);
        if size(perf, 2) > 1 % conver to mono if audio is stereo
            perf = mean(perf, 2); 
        end
        [stim, fs_stim] = audioread([filename_stim]);
        if size(stim, 2) > 1 % conver to mono if audio is stereo
            stim = mean(stim, 2);
        end
        
        
        %% COMPUTE AUDIO FEATURES
        % Amplitude envelope
        env_perf = envelope(perf);
        env_stim = envelope(stim);

        % Spectral flux
        specflux_perf = spectralFlux(perf, fs_perf); % this uses ~440 windows
        specflux_stim = spectralFlux(stim, fs_stim); % because default is 100 Hz
        % NOTE: do we need to add a zero? eg. [0; spectralFlux(perf, fs_perf)];
% Resulting time series is 8076 data points
% ~80s/8076 ~= 0.01 s ~= 100 data points per second --> 100 Hz
        
        % Check the data
        if plotting_flag == 1
            plot_feats(specflux_perf_prep, fs_perf)
        end

        fs = 100; % default sampling rate of specflux function
        % this means the specflux time series is at 100 Hz
        
        for ds_ind = 1:length(ds_targets) % loop through indicies
            ds_target = ds_targets(ds_ind);
            if ds_target ~= 0 % downsample both time series
                env_perf_prep = resample(env_perf, ds_target, fs_perf);
                env_stim_prep = resample(env_stim, ds_target, fs_stim);
    
                specflux_perf_prep = resample(specflux_perf, ds_target, fs);
                specflux_stim_prep = resample(specflux_stim, ds_target, fs);
            else
                env_perf_prep = env_perf;
                env_stim_prep = env_stim;
                specflux_perf_prep = specflux_perf;
                specflux_stim_prep = specflux_stim;
            end
        
            % Truncate both time series to the length of the shortest
            [env_perf_prep, env_stim_prep] = prepare_following(env_perf_prep, env_stim_prep);
            [specflux_perf_prep, specflux_stim_prep] = prepare_following(specflux_perf_prep, specflux_stim_prep);
           
            % Combine and save - For now try both ways
            DATA_env{ds_ind,trial} = cat(3,env_perf_prep,env_stim_prep);
            DATA_specflux{ds_ind,trial} = cat(3,specflux_perf_prep,specflux_stim_prep);

            %DATA_env{trial} = cat(3,env_perf_prep,env_stim_prep); % for saving raw data
            %DATA_specflux{trial} = cat(3,specflux_perf_prep,specflux_stim_prep);
            
        end % end of downsampling loop
    end
  
    %Feat(p).(['ds_', num2str(ds_target)]).env.alltrials = DATA_env;
    %Feat(p).(['ds_', num2str(ds_target)]).specflux.alltrials = DATA_specflux;
    %Feats(p).(['ds_', num2str(ds_target)]).env.matrix = create_matrix_following(DATA, 'env', plotting_flag);
    %Feats(p).(['ds_', num2str(ds_target)]).specflux.matrix = create_matrix_following(DATA, 'specflux', plotting_flag);
    
    for ds_ind = 1:length(ds_targets) % loop through indicies
        ds_target = ds_targets(ds_ind);
        Feats(p).(['ds_', num2str(ds_target)]).env.matrix = create_matrix_following(DATA_env(ds_ind,:), plotting_flag);
        Feats(p).(['ds_', num2str(ds_target)]).specflux.matrix = create_matrix_following(DATA_specflux(ds_ind,:), plotting_flag);
    end
end


%% SAVE DATA as a .mat file
save(['~/Desktop/Following/analysis/',piece,'/Feats_',piece,'_',section,'.mat'], 'Feats', '-v7.3')


% ~~~~~~~~~~
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

