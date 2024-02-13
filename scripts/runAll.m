%% ALL run commands for violin following data
% Run this script line-by-line to go through entire process
% Comment or uncomment lines depending on which variables need to be loaded

clear variables
cd ~/Desktop/Following/analysis/
addpath(genpath('~/Desktop/Following/analysis/scripts'));
addpath(genpath('~/Documents/MATLAB/Toolboxes/mvgc_v1.0'));

% This script loads the audio data, extracts the features, and saves them
% to a .mat file

load_Feats_var = 0; % load in the data from file instead of re-calculating it

plotting_flag = 0;
section = 'whole';
pieces = {'Danny Boy', 'In The Garden'};
features = {'env', 'specflux'};
ds_targets = [5,6,7,8,10,12,15]; % 0 ds_target --> no downsampling

MOs_all = cell(1, length(pieces));
MOs_headers = {'Piece', 'Participant', 'MO_env', 'MO_specflux'};
%MOs = zeros(2*8, 4, 6); % set to # of ds_targets

for pc = 1:length(pieces)
    piece = pieces{pc};
    fprintf("Running script for: %s - section %s \n", piece, section)
    
    %% LOAD & PREPROCESS
    if load_Feats_var == 0 % if not loading from file, need to relcalculate
        MASTER_preprocess_following % this saves Feats.mat for a certain piece
    end
    
    %% RUN GC ANALYSIS
    for f = 1:length(features)
        feature = features{f};
        if load_Feats_var == 1
            data_folder = ['~/Desktop/Following/analysis/',piece,'/'];
            load([data_folder,'Feats_',piece,'_',section,'.mat'], 'Feats');
        end
        mvgc_following % Feats variable adds second feature data on second loop

    end
    
    save([piece,'/GCdata_',piece,'_',section],'Feats', '-v7.3'); % using different name for now

    save_mvgc_following
    MOs_all{pc} = MOs;

end

MOs_table = [MOs_all{1}; MOs_all{2}];
for d = 1:length(ds_targets)
    MOs_sliceCell = num2cell(MOs_table(:, :, d));
    MOs_cellData = [MOs_headers; MOs_sliceCell];
    sheetName = sprintf('ds_%d', d);
    writecell(MOs_cellData, MOs_filename, 'Sheet', sheetName); % use same sheetnames
end


