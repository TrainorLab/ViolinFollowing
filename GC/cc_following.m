%% Musical following study - Cross-correlation script
% Lucas Klein - June 2020

% ~~~ CHANGE THESE ~~~
% Carry in variables from preprocessing script, or change them?
carry_over = 1; % 1 for yes, 0 for no
save_flag = 0;

if carry_over == 0
    piece = 'Danny Boy'; % Which piece are we analyzing?
    section = '22_1'; % What section?
    ds_targets = [8]; % [4, 5, 6, 7, 8, 9, 10, 12];
    
    %% LOAD in matrix X
    load(['D_',piece,'_',section,'.mat']); % This loads a cell array called 'D',
end

clc
cd '~/Desktop/Following/ANALYSIS';
addpath(genpath('~/Documents/MATLAB/Toolboxes/mvgc_v1.0'));
addpath(genpath('~/Documents/MATLAB/Following/ANALYSIS/2GC/CC_analysis'));

%% SETUP
C = {}; % Empty array

for participanti = 1:numel(D) % Loop through all participants
    for ds_target = ds_targets % Loop through downsampling targets
        label = ['M_' + string(ds_target)];
        X = D{participanti}.(label);
        
        % Preallocate some vectors
        maxlag = 17; % 20?
        window = length(X); % number of observations
        overlap = 0;
        corvals = zeros(length(ds_targets), size(X,3), numel(D));
            
        for triali = 1:size(X,3)
            
            % CROSS-CORRELATION
            ds_label = ['cc_' + string(ds_target)];
            C{participanti}.(ds_label)(1,triali) = max(abs(corrgram(X(1,:,triali),X(2,:,triali), maxlag, window, overlap)),[],'all');
            
            % Let's try Dobri's method...
            sr = 8;
            [c,l,t] = corrgram(X(1,:,triali),X(2,:,triali),round(sr*1),round(sr*5),round(sr*5*.5));

        end
       
    end
    
end



%% Save data
% Make arrays for table (all 64 x 1)
participant = repelem([1:numel(D)]', size(X,3)*length(ds_targets));
downsample = repmat(repelem(ds_targets', size(X,3)), numel(D), 1);
trial = repmat([1:size(X,3)]', numel(D)*length(ds_targets), 1);
corvals_reconfig = [];

for parti = 1:numel(D)
    for ds_target = ds_targets
        ds_lab = ['cc_' + string(ds_target)];
        for tri = 1:size(X,3)
            step = C{parti}.(ds_lab)(1,tri);
            corvals_reconfig = [corvals_reconfig; step];
        end
    end
end

if save_flag == 1
    T = table(participant, downsample, trial, corvals_reconfig);
    T.Properties.VariableNames = {'Participant','Downsample','Trial','CCvals'};
    filename = ['~/Desktop/Following/ANALYSIS/3R/following_cc',piece,'.csv'];
    writetable(T,filename);
end

