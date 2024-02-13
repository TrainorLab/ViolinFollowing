function [wcc, wcc0, l, l0] = cc_following_win(X, triali, ds_target, piece)

%% Violin following study - Cross-correlation script
% Lucas Klein
% Updated: February 2024

A = X(1,:,triali); % performance
B = X(2,:,triali); % recording
sr = ds_target;

%% INFO
% Danny Boy: 81 s long (in 4/4 time) @ 55 BPM = .917 BPS --> 2 bars = 8 beats = 8.73 s
% Maximum lag = 2 beats = 8.73 / 4 = 2.18 s

% In The Garden: 94 s long (in 6/8 time) @ 130 BPM = 2.167 BPS --> 2 bars = 12 beats = 5.54 s
% Maximum lag = 2 beats = 5.54 / 6 = 0.92 s

if strcmp(piece,'Danny Boy')
    maxlag = round(2.18*sr); % 2 beats
    win_len = round(8.73*sr); % 2 bars
    % 
else
    maxlag = round(0.92*sr); % 2 beats
    win_len = round(5.54*sr); % 2 bars
end
overlap = round(win_len/2); % half a window overlap


%% Run cross-correlations
[wcc,l,t] = corrgram(A,B,maxlag,win_len,overlap);

% Max lag
wcc_max = max(abs(wcc),[],'all');
[indexR,indexC] = find(abs(wcc)==max(abs(wcc),[],'all')); % find index of max CC value


%% Zero lag
[wcc0,l0,t0] = corrgram(A,B,0,win_len,overlap);
%cor_vals0(triali,1) = max(abs(wcc0),[],'all');




% % Plot the cross-correlation
% figure;
% stem(lags, wcc);
% title('Cross-Correlation between Time Series');
% xlabel('Lags');
% ylabel('Correlation Coefficient');









