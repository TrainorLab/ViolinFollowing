%% Musical following study - Granger Causality script
% Lucas Klein - June 2020

% This script runs the final step of the Granger causality analysis on the
% musical following study data.

% Importantly, the data should already have been preprocessed using the
% MASTER_preprocess script
% To plot everything, set plotting_flag = 1
% To save the ouput to a .csv file, set save_flag = 1

addpath(genpath('~/Desktop/Following/ANALYSIS/GC'));
addpath(genpath('~/Documents/MATLAB/Toolboxes/mvgc_v1.0'));


%% SETTINGS

% Did you just run the MASTER_preprocess_following.m script?
carry_over = 0; % 0 for no, 1 for yes
save_flag = 0; % Set to 1 if you want this loop to save a spreadsheet. If not, set to 0.
% ALERT! This will overwrite existing files with the same save name!

plotting_flag = 0;

which_piece = 1; % Which piece are we analyzing?


%% FIND DATA
switch carry_over
    case 0

        if which_piece == 1
            piece = 'Danny Boy';
        else
            piece = 'In The Garden';
        end

        section = 'whole';
        
        data_folder = ['~/Desktop/Following/ANALYSIS/',piece,'/'];
        cd(data_folder)

        load(['D_',piece,'_',section,'.mat']); % This loads a cell array called 'D',
        % which contains a cell for each participant
    
        % How many downsampling rates are being checked?
        ds_targets = [8];
    % NOTE: This list needs to be the same as in the MASTER_preprocessing script
    % Set it here, or take the variable in from workspace
    % In ANALYSIS folder, outputs (D.mat and following_gc.csv) are both
    % appended with a number that corresponds to the LAST downsampling rate
    % used (e.g. following_gc_15.csv)
end




%% Parameters
bsize     = [];     % permutation test block size: empty for automatic (uses model order)

regmode   = 'OLS';  % VAR model estimation regression mode ('OLS', 'LWR' or empty for default)
icregmode = 'LWR';  % information criteria regression mode ('OLS', 'LWR' or empty for default)

morder    = 'AIC';  % model order to use ('actual', 'AIC', 'BIC' or supplied numerical value)
momax     = 20;     % maximum model order for model order estimation

acmaxlags = [];     % maximum autocovariance lags (empty for automatic calculation)

tstat     = '';     % statistical test for MVGC:  'F' for Granger's F-test (default) or 'chi2' for Geweke's chi2 test
alpha     = 0.05;   % significance level for significance test
mhtc      = 'FDR';  % multiple hypothesis test correction (see routine 'significance')

fs        = 44100;    % sample rate (Hz)
fres      = [];     % frequency resolution (empty for automatic calculation)

seed      = 0;      % random seed (0 for unseeded)


%% Loop through all participants
for participanti = 1:numel(D)
    for ds_target = ds_targets
        label = ['M_' + string(ds_target)];
        X = D{participanti}.(label);
        nvars     = size(X,1);      % number of variables (2)
        nobs      = size(X,2);      % number of observations per trial
        ntrials   = size(X,3);      % number of trials (8)
        
        %% Model order estimation
        % Preallocate some vectors
        
        AIC_matrix=zeros(momax,ntrials);
        moAIC_matrix=zeros(1,ntrials);
        
        % Loop through all trials
        for triali = 1:size(X,3)
            
            % Calculate information criteria up to specified maximum model
            % order
            [AIC,~,moAIC,~] = tsdata_to_infocrit(X(:,:,triali),momax,icregmode);
            AIC_matrix(:,triali) = AIC;
            moAIC_matrix(1,triali) = moAIC;

            % Plot information criteria.
            %figure(1); clf;
            %plot_tsdata([AIC]',{'AIC'},1/fs);
            %title('Model order estimation');
            %pause
        end
        
        morder = max(moAIC_matrix);
        label_morder = [label + '_morder'];
        D{participanti}.(label_morder) = morder;
        % Use this model order for every trial
        
        %% VAR model estimation (<mvgc_schema.html#3 |A2|>)
        % Preallocate some vectors
        GC_data = zeros(nvars,nvars,ntrials);
        pval_data = zeros(nvars,nvars,ntrials);
        sig_data = zeros(nvars,nvars,ntrials);
        cd_data = zeros(1,ntrials);
        
        
        % Loop through all trials
        for triali = 1:size(X,3)
            
            % Estimate VAR model of selected order from data
            [A,SIG] = tsdata_to_var(X(:,:,triali),morder,regmode);
            
            % Check for failed regresssion
            assert(~isbad(A),'VAR estimation failed');
            
            % NOTE: we are now done with all the data!
            % all subsequent calculations work from the estimated VAR
            % parameters A and SIG
            
            %% Autocovariance calculation (<mvgc_schema.html#3 |A5|>)
            % Calculate the autocovariance sequence G according to the VAR
            % model, to as many lags as it takes to decay to below the
            % numerical tolerance level, or to acmaxlags if specified (i.e.
            % if non-empty)
            
            [G,info] = var_to_autocov(A,SIG,acmaxlags);

            % Check for errors (e.g. non-stationarity, colinearity, etc.)            
            var_info(info,true); % report results (and bail out on error)
                        
            %% Granger causality calculation: time domain (<mvgc_schema.html#3 |A13|>)
            % Calculate time-domain pairwise-conditional causalities
            % NOTE: this just requires the autocovariance sequence G.
            
            F = autocov_to_pwcgc(G);
            GC_data(:,:,triali) = F;
            
            % Check for failed GC calculation
            assert(~isbad(F,false),'GC calculation failed');
            
            % Significance test using theoretical null distribution,
            % adjusting for multiple hypotheses.
            
            pval = mvgc_pval(F,morder,nobs,ntrials,1,1,nvars-2,tstat); % take note of arguments!
% NOTE: nvars - 2 = 2 - 2 = 0. Is this bad?
            
            pval_data(:,:,triali) = pval;
            label_pval = [label + '_pval'];
            D{participanti}.(label_pval) = pval_data;
            
            sig = significance(pval,alpha,mhtc);
            sig_data(:,:,triali) = sig;
            
% Plot time-domain causal graph, p-values and significance
            
            figure(2); clf;
            subplot(1,3,1);
            plot_pw(F);
            title('Pairwise-conditional GC');
            subplot(1,3,2);
            plot_pw(pval);
            title('p-values');
            subplot(1,3,3);
            plot_pw(sig);
            title(['Significant at p = ' num2str(alpha)])
            
            % For good measure, calculate Seth's causal density (CD)
            % measure, the mean pairwise-conditional causality. We don't
            % have a theoretical sampling distribution for this.
            
            % Save the cd data to a new field
            scd = mean(F(~isnan(F)));
            cd_data(1,triali) = scd;
            label_cd = [label + '_cd'];
            D{participanti}.(label_cd) = cd_data;
            
            % Save the GC data to a new field
            label_gc = [label + '_gc'];
            D{participanti}.(label_gc) = GC_data;
        end
            
    end
    
end
    


%% Save data
% Make a table of raw gc scores for Violin --> Recording and Recording -->
% Violin
% For each participant, loop through all 
if save_flag == 1
    
    save([data_folder,'D_',piece,'_',section,'_gc'],'D')

    % Make two vectors of GC values: one for rec --> perf, one for perf --> rec
    GC_r2p = [];
    GC_p2r = [];
    for parti = 1:numel(D)
        for ds_target = ds_targets % Loop through downsampling rates
            save_label = ['M_' + string(ds_target) + '_gc'];
            % We need this to save data for all downsampling rates
            for trial = 1:size(X,3)
                step_r2p = D{parti}.(save_label)(1,2,trial);
                step_p2r = D{parti}.(save_label)(2,1,trial);
                GC_r2p = [GC_r2p; step_r2p];
                GC_p2r = [GC_p2r; step_p2r];
            end
        end
    end
    % num of participants = numel(D)
    % num of trials = size(X,3)

    % Make vector for participant
    participant = repelem([1:numel(D)]',size(X,3)*length(ds_targets));
    
    % Make a vector for downsampling target
    %downsample = repmat(repelem(ds_targets,size(X,3))',numel(D),1);
    %downsample = repelem(8,64)';
    
    % Make vector for trial
    trial = repmat([1:ntrials]',numel(D)*length(ds_targets),1);
    
    % Run cc_following.m to calculate CC values
    wcc_following
    CC = corvals_reconfig;


    %% SAVE
    % Save an Excel sheet of the data
    %T = table(participant, downsample, trial, GC_r2p, GC_p2r);
    T = table(participant, trial, GC_r2p, GC_p2r, CC); % without downsample column
    %T.Properties.VariableNames = {'Participant','Downsample','Trial','GC_r2p','GC_p2r'};
    T.Properties.VariableNames = {'Participant','Trial','GC_r2p','GC_p2r','CC'}; % without downsample column
    xlsxname = ['~/Desktop/Following/ANALYSIS/Stats/following_',piece,'_',section,'.csv'];
    writetable(T,xlsxname);
end


% Find model orders
model_orders = zeros(size(numel(D)));
for mos = 1:numel(D)
    model_orders(mos) = D{mos}.M_8_morder;
end

mo_mean = mean(model_orders)
mo_stdev = std(model_orders)

