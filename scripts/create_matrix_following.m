function M = create_matrix_following(DATA, plotting_flag)
%% Create a matrix for the MVGC toolbox
% This function takes data from the amplitude envelope and spectral flux time series 
% and puts it in the correct form for the MVGC toolbox.
% This data is comprised of two variables: a musician's performance and the
% recording they followed along with. The recording is the same for each trial.

% DATA is a cell array of length num_trials, with a 

% For each trial,
% var #1 is the performance and var #2 is the recording (stim).
% nobs is the length of that trial. 


%% Find minimum trial length
trialLengths = zeros(1,length(DATA)); % How long (in samples) is each trial?
for triali = 1:length(DATA) % number of trials
    trialLengths(1,triali) = length(DATA{triali});
end
minVal = min(trialLengths); % Find the shortest trial

nvars = size(DATA{1},3); % use first trial, should all be equal to 2
nobs = minVal;
ntrials = length(DATA);

M = zeros(nvars,nobs,ntrials);
for tri = 1:ntrials
    data = permute(DATA{tri},[3,1,2]);
    M(:,:,tri) = data(:,1:minVal); % nvars x nobs x ntrials
end


%% Optional - plot the matrix to make sure it looks ok 
if plotting_flag == 1
    for vari = 1:size(M,1) %loop through all trials
        for triali = 1:size(M,3) % loop through both vars (recording and performance)
            plot(M(vari,:,triali))
            disp([triali, vari])
            pause
        end
    end
end
