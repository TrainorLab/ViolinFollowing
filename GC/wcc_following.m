%% Musical following study - Cross-correlation script
% Lucas Klein
% Updated: April 2022

clc
cd '~/Desktop/Following/ANALYSIS/GC';
addpath(genpath('~/Desktop/Following/ANALYSIS/'));


%% Carry in vars and load data
% ~~~ CHANGE THESE ~~~
% Carry in variables from preprocessing script, or change them?
carry_over = 1; % 1 for yes (default), 0 for no
save_flag = 0;

if carry_over == 0 % if we don't carry over, say which piece we're analyzing here
    piece = 'Danny Boy'; % Which piece are we analyzing?
    section = 'whole'; % What section?
    ds_targets = [8]; % [4, 5, 6, 7, 8, 9, 10, 12];
    
    % LOAD in matrix X
    load(['D_',piece,'_',section,'.mat']); % This loads a cell array called 'D'.
    % Each cell is a participant, each with a field for each downsampling
    % rate. Those field contian matrices of size 2 (directions) x 646 (obs) x 8 (trials)
end


%% Set parameters
%C = {}; % Empty array

% Which method should we use? 
switch 0
    case 0
        method_flag='wcc';
    case 1
        method_flag='gc_order';
end

% Window size:
% Danny Boy in 4/4
% 55 BPM = .917 BPS --> 2 bars = 8 beats = 8.73 s

% In The Garden in 6/8
% 130 BPM = 2.167 BPS --> 2 bars = 12 beats = 5.54 s

if strcmp(method_flag,'wcc') % Set parameters for windowed method
    sr = 8;
    sr100 = 100;
    if strcmp(piece,'Danny Boy')
        win_len = 8.73; % Target window length in seconds (2 measures)
        max_lag = win_len/8; % Apprx. 1 beat (2 measures = 8 quarter notes)
    else
        win_len = 5.54; % Target window length in seconds (2 measures)
        max_lag = win_len/4; %win_len/12; % Apprx. 1 beat (2 measures = 12 eighth notes)
    end
end


%% Find data and setup for both methods
counter = 0;
for participanti = 1:numel(D) % Loop through all participants
    for ds_target = ds_targets % Loop through downsampling targets
        label = ['M_' + string(ds_target)]; % Find the field for this ds rate
        X = D{participanti}.(label); % obtain matrix of observations
        
        corvals = []; % create empty vector to store correlation coefficients
        counter = counter + 1; % increment the counter

        switch method_flag
            case 'wcc'
                window = round(win_len*sr); % # of data points
                maxlag = round(max_lag*sr);
                overlap = round(window/2); % half a window overlap
            case 'gc_order'
                label_morder = [label + '_morder'];
                morder = D{participanti}.(label_morder);
                %maxlag = 17; % or cycle through all m_orders using counter
                maxlag = morders(counter); % lag is the same as the model order for gc
                window = length(X); % # of observations in entire piece
                overlap=0; % No overlap
                corvals = zeros(length(ds_targets), size(X,3), numel(D));
        end

        
        %% Run CC

        cor_vals = zeros(size(X,3),1); % num_trials x num_participants

        for triali = 1:size(X,3) % Loop through trials
            switch method_flag
                case 'wcc'
                    A = X(1,:,triali);
                    B = X(2,:,triali);
                    [wcc,l,t] = corrgram(A,B,maxlag,window,overlap);
                    cor_val = max(abs(wcc),[],'all');
                    cor_vals(triali,1) = cor_val;
                    %cor_vals = max(abs(corrgram(A,B, maxlag, window, overlap)),[],'all');


                case 'gc_order'
                    % Cross-covariance: similarity between vector x and
                    % shifted (lagged) copies of vector y as fxn of the
                    % lag. Adds zeros to shorter vector so x and y have
                    % same length
                    [c,l] = xcov(X(1,:,triali),X(2,:,triali),morder,'coef');
                    cor_vals(triali)=max(abs(c));
            end
        end
            
        % CROSS-CORRELATION
        cc_label = ['cc_' + string(ds_target) + method_flag];
        
        D{participanti}.(cc_label) = cor_vals;
        
        % Dobri's method:
        %sr = 8;
        %[c,l,t] = corrgram(X(1,:,triali),X(2,:,triali),round(sr*1),round(sr*5),round(sr*5*.5));
       
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
        cc_lab = 'cc_' + string(ds_target) + method_flag; % find CC values within each participant's cell in D
        % corvals_reconfig = cat(1,corvals_reconfig,D{parti}.(cc_lab));
        corvals_reconfig = [corvals_reconfig;D{parti}.(cc_lab)];
    end
end

if save_flag == 1
    T = table(participant, downsample, trial, corvals_reconfig);
    T.Properties.VariableNames = {'Participant','Downsample','Trial','CCvals'};
    filename = ['~/Desktop/Following/ANALYSIS/3R/following_cc',piece,'.csv'];
    writetable(T,filename);
end
