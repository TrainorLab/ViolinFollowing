%% Save data
% Make a table of raw gc scores for Violin --> Recording and Recording -->
% Violin

% REQUIREMENTS: piece, piece_num (pc)

xlsx_filename = ['following_',piece,'_',section,'.xlsx'];
MOs_filename = ['followingMOs_',piece,'_',section,'.xlsx'];
ds_targets = Feats(1).ds_targets;

T = zeros(numel(Feats)*ntrials, 8, length(ds_targets));
MOs = zeros(numel(Feats), 4, length(ds_targets)); % length: 8 participants x ? ds_targets
tables = cell(1,length(features));
headers = {'Participant','Trial','GC_r2p','GC_p2r','CC','ds_target','Piece','Feature'};

for ds_index = 1:length(ds_targets) % Loop through downsampling rates
    ds_target = ds_targets(ds_index);

    MOs(:,1,ds_index) = repelem(pc, numel(Feats))'; % piece number
    MOs(:,2,ds_index) = [1:numel(Feats)]'; % participant number

    for f = 1:length(features)
        feature = features{f};

        % Make columns - each should be 8 x 8 = 64 long
        T(:,1,ds_index) = repelem([1:numel(Feats)]', ntrials); % participants
        T(:,2,ds_index) = repmat([1:ntrials]', numel(Feats), 1); % trials
        T(:,6,ds_index) = repelem(ds_target, numel(Feats)*ntrials)'; % downsampling target (all the same)
        T(:,7,ds_index) = repelem(pc, numel(Feats)*ntrials)'; % piece (all the same)
        T(:,8,ds_index) = repelem(f, numel(Feats)*ntrials)'; % feature
        
        GC_r2p = [];
        GC_p2r = [];
        maxCCs_all = [];
        for parti = 1:numel(Feats)
            MOs(parti,2+f,ds_index) = Feats(parti).(['ds_', num2str(ds_target)]).(feature).morder;

            for trial = 1:ntrials
                step_r2p = Feats(parti).(['ds_', num2str(ds_target)]).(feature).GC_data(1,2,trial);
                step_p2r = Feats(parti).(['ds_', num2str(ds_target)]).(feature).GC_data(2,1,trial);
                GC_r2p = [GC_r2p; step_r2p];
                GC_p2r = [GC_p2r; step_p2r];
            end
            
            maxCCs_all = [maxCCs_all; Feats(parti).(['ds_', num2str(ds_target)]).(feature).CC_data_full'];
            


        end
        T(:,3,ds_index) = GC_r2p;
        T(:,4,ds_index) = GC_p2r;
        T(:,5,ds_index) = maxCCs_all;
        tables{f} = T;
    end
    S = [tables{1}; tables{2}]; % stack tables for each features on top of one another
    % Table is now 128 long

    %% Save each table to a different slice in an Excel spreadsheet
    %slice = ; 
    sliceCell = num2cell(S(:, :, ds_index)); % this slice is now 256 long because it includes data for both features
    cellData = [headers; sliceCell];
    sheetName = sprintf('ds_%d', ds_target); % data for each ds_target on a different sheet
    writecell(cellData, xlsx_filename, 'Sheet', sheetName); % Write slice to the specified sheet in the Excel file
end


%% Calculate CC values

% Run cc_following.m to calculate CC values
% cc_following_new
% CC = corvals_reconfig;
% CC0 = corvals_reconfig0;
% CC_l = corvals_reconfig_lags;

% case 1
%     wcc_following_lags
%     CC0 = CCs{5};
%     CC1 = CCs{1};
%     CC2 = CCs{2};
%     CC3 = CCs{3};
%     CC4 = CCs{4};

%writetable(T,xlsxname);

