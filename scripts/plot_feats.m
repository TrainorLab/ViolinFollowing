function plot_feats(plot_data, fs, title)

figure;
time_secs = (0:length(plot_data)-1) / fs; % Time in seconds
plot(time_secs, plot_data)

title(title)