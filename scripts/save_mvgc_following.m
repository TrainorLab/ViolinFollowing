%% Save data
% Make a table of raw gc scores for Violin --> Recording and Recording -->
% Violin
% For each participant, loop through all 

%ds_targets = Feat(parti).ds_targets;
ds_targets = 8;

% Make two vectors of GC values: one for rec --> perf, one for perf --> rec
GC_r2p = [];
GC_p2r = [];
for parti = 1:numel(Feat)
    for ds_target = ds_targets % Loop through downsampling rates
        save_label = ['ds_', num2str(ds_target),'.',feature,'.gc'];
        % We need this to save data for all downsampling rates
        for trial = 1:size(X,3)
            %step_r2p = Feat(parti).(save_label)(1,2,trial);
            %step_p2r = Feat(parti).(save_label)(2,1,trial);
            step_r2p = Feat(parti).(['ds_', num2str(ds_target)]).(feature).gc(1,2,trial);
            step_p2r = Feat(parti).(['ds_', num2str(ds_target)]).(feature).gc(2,1,trial);
            GC_r2p = [GC_r2p; step_r2p];
            GC_p2r = [GC_p2r; step_p2r];
        end
    end
end

% num of participants = numel(D)
% num of trials = size(X,3)

% Make vector for participant
participant_col = repelem([1:numel(Feat)]',size(X,3)*length(ds_targets));

% Make a vector for downsampling target
%downsample = repmat(repelem(ds_targets,size(X,3))',numel(D),1);
%downsample = repelem(8,64)';

% Make vector for trial
trial_col = repmat([1:ntrials]',numel(Feat)*length(ds_targets),1);

% Make a vector for piece
piece_num = repelem(which_piece, numel(Feat)*size(X,3))';

% Run cc_following.m to calculate CC values
% cc_following_new
% CC = corvals_reconfig;
% CC0 = corvals_reconfig0;
% CC_l = corvals_reconfig_lags;
% CHANGES

% Save an Excel sheet of the data
%T = table(participant, trial, GC_r2p, GC_p2r, CC, CC0, CC_l, piece_num);
%T.Properties.VariableNames = {'Participant','Trial','GC_r2p','GC_p2r','CC','CC0','CC_l','Piece'};

T = table(participant_col, trial_col, GC_r2p, GC_p2r, piece_num);
T.Properties.VariableNames = {'Participant','Trial','GC_r2p','GC_p2r','Piece'};

% case 1
%     wcc_following_lags
%     CC0 = CCs{5};
%     CC1 = CCs{1};
%     CC2 = CCs{2};
%     CC3 = CCs{3};
%     CC4 = CCs{4};

% Save an Excel sheet of the data
%T = table(participant, tri  all, GC_r2p, GC_p2r, CC0, CC1, CC2, CC3, CC4, piece_num); % all CC lags
%T.Properties.VariableNames = {'Participant','Trial','GC_r2p','GC_p2r','CC0','CC1','CC2','CC3','CC4','Piece'}; % without downsample column

xlsxname = ['~/Desktop/Following/analysis/stats/nfollowing_',piece,'_',section,'_8.csv'];

%     if method_flag == 'full' % defined in cc_following script
%         xlsxname = ['~/Desktop/Following/ANALYSIS/Stats/following_',piece,'_',section,'_full.csv'];
%     end
writetable(T,xlsxname);


