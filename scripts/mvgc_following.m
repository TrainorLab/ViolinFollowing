%% Musical following study - Granger Causality script
% Lucas Klein - December 2023

% This script runs the Granger causality analysis on the violin following
% data. Importantly, the data should already have been preprocessed using the
% MASTER_preprocess script

% REQUIREMENTS: piece, section, feature

data_folder = ['~/Desktop/Following/analysis/',piece,'/'];
load([data_folder,'Feats_',piece,'_',section,'.mat'], 'Feats');


%% SETTINGS
% Did you just run the MASTER_preprocess_following.m script?
plot_flag = 1; % Set to 1 to make plots of everything
save_flag = 1; % Set to 1 to save Excel spreadsheet

% Identify downsampling rates saved in variable
%ds_targets = Feats(1).ds_targets; % use first participant (but should all be the same)


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
fs        = 44100;  % sample rate (Hz)
fres      = [];     % frequency resolution (empty for automatic calculation)
seed      = 0;      % random seed (0 for unseeded)

CCmaxlag = 50;

%% Main GC loop 
for participanti = 1:numel(Feats)
    for ds_target = ds_targets
        disp("Calculating GC for "+feature+ ...
            ": participant "+num2str(participanti)+ ...
            ", downsampled to "+num2str(ds_target)+" Hz")
        X = Feats(participanti).(['ds_', num2str(ds_target)]).(feature).matrix;
        nvars     = size(X,1);      % number of variables (2)
        nobs      = size(X,2);      % number of observations per trial (many)
        ntrials   = size(X,3);      % number of trials (8)
        

        %% Model order estimation
        % Preallocate some vectors
        AIC_matrix = zeros(momax,ntrials);
        moAIC_matrix = zeros(1,ntrials);
        
        %% Model orders
        for triali = 1:ntrials % Loop through all trials to find AIC matrix
            % Calculate information criteria up to specified maximum model
            % order
            [AIC,~,moAIC,~] = tsdata_to_infocrit(X(:,:,triali),momax,icregmode);
            % (using AIC instead of BIC)
            % tsdata_to_infocrit(multi-trial TS data, max VAr model order,
            % regression mode (LWR or OLS),verbosity (reports progress))
            AIC_matrix(:,triali) = AIC;
            moAIC_matrix(1,triali) = moAIC;

            % Plot information criteria.
            % switch plot_flag
            %     case 1
            %         figure(1); clf;
            %         plot_tsdata([AIC]',{'AIC'},1/fs);
            %         title('Model order estimation');
            %         disp('Paused to plot')
            %         %pause
            % end
        end
        
        morder = max(moAIC_matrix); % max model order of all trials
        % Use this model order for every trial
        
        %% VAR model estimation (<mvgc_schema.html#3 |A2|>)
        % Preallocate some vectors
        GC_data = zeros(nvars,nvars,ntrials);
        pval_data = zeros(nvars,nvars,ntrials);
        sig_data = zeros(nvars,nvars,ntrials);
        cd_data = zeros(1,ntrials);
        CC_vals = zeros(1,ntrials);
        for triali = 1:ntrials % Loop through all trials
            
            % Estimate VAR model of selected order from data
            [A,SIG] = tsdata_to_var(X(:,:,triali),morder,regmode);
            % A = VAR coeffs
            % SIG = residuals covariance matrix of a stationary
            % multivariate process |X|
            
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
            
            [G,info] = var_to_autocov(A,SIG,acmaxlags); % acmaxlags=[0] by default
            

            % Check for errors (e.g. non-stationarity, colinearity, etc.)            
            var_info(info,true); % report results (and bail out on error)
                        
            %% Granger causality calculation: time domain (<mvgc_schema.html#3 |A13|>)
            % Calculate matrix of pairwise-conditional time-domain MVGCs
            % NOTE: this just requires the autocovariance sequence G.
            
            F = autocov_to_pwcgc(G); % GC matrix, nvars x nvars
            GC_data(:,:,triali) = F;
            
            % Check for failed GC calculation
            assert(~isbad(F,false),'GC calculation failed');
            
            % Significance test using theoretical null distribution,
            % adjusting for multiple hypotheses.
            pval = mvgc_pval(F,morder,nobs,ntrials,1,1,nvars-2,tstat); % take note of arguments!
% NOTE: nvars - 2 = 2 - 2 = 0. ???
            pval_data(:,:,triali) = pval;
            
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


            %% CROSS-CORRELATION CALCULATION
            % X(:,:,triali) - nvar x nobs
            %% CROSS-CORRELATION CALCULATION
            % X(:,:,triali) - nvar x nobs

            %[CCvals_full, lags] = cc_following_full(X, CCmaxlag);


        end
        
        %% Save all data
        Feats(participanti).(['ds_', num2str(ds_target)]).(feature).pval = pval_data;
        Feats(participanti).(['ds_', num2str(ds_target)]).(feature).cd_data = cd_data;
        Feats(participanti).(['ds_', num2str(ds_target)]).(feature).GC_data = GC_data;
        Feats(participanti).(['ds_', num2str(ds_target)]).(feature).morder = morder; % save model orders
        disp(morder)
        % New GC data is saved in the field that corresponds to each
        % feature
    end
end


%% Find model orders
% model_orders = zeros(size(numel(Feat)));
% for mos = 1:numel(Feats)
%     model_orders(mos) = D{mos}.M_8_morder;
% end

%mo_mean = mean(model_orders);
%mo_stdev = std(model_orders);


