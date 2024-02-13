function [max_corval, corval0, lags, lags0] = cc_following_full(X, triali, ds_target, piece)

A = X(1,:,triali); % performance
B = X(2,:,triali); % recording
sr = ds_target;

%% INFO
% Danny Boy: 81 s long (in 4/4 time) @ 55 BPM = .917 BPS --> 2 bars = 8 beats = 8.73 s
% Maximum lag = 2 beats = 8.73 / 4 = 2.18 s

% In The Garden: 94 s long (in 6/8 time) @ 130 BPM = 2.167 BPS --> 2 bars = 12 beats = 5.54 s
% Maximum lag = 2 beats = 5.54 / 6 = 0.92 s

if strcmp(piece,'Danny Boy')
    maxlag = round(2.18*sr);
    % 
else
    maxlag = round(0.92*sr);
end


%% Run CC
[cc,lags] = xcorr(A,B,maxlag,'normalized'); % 1x21 [-10:1:10] of pos CC values between [0,1]
%[cc_xcov,lags_xcov] = xcov(A,B,maxlag,'normalized');
stem(lags,cc)

max_corval = max(abs(cc),[],'all');

[indexR,indexC] = find(abs(cc)==max(abs(cc),[],'all')); % find index of max CC value (pos or neg)
%maxlag_index(triali,1) = indexC-(maxlag+1); % re-center lag values about 0
% This is now a column of optimal lags for all 8 trials


%% ZERO LAG
% Stipulating zero lag
[corval0,lags0] = xcorr(A,B,0,'normalized'); % only one value, so no max needed

% should we use 'coeff' instead?










