% Assuming 'crossCorrValues' is your (29 x 33) array of cross-correlation values



figure; % Creates a new figure
imagesc(wcc); % Plots the heatmap
colorbar; % Adds a colorbar to indicate the scale
xlabel('Windows'); % Label for the x-axis
ylabel('Lags'); % Label for the y-axis
title('Windowed cross-correlation values'); % Title for the heatmap



% Assuming 'crossCorrValues' is your (29 x 33) array of cross-correlation values
crossCorrValues = rand(29, 33); % Example data, replace with your actual data

% Generate labels for windows (columns) and lags (rows) if necessary
windowLabels = string(1:size(wcc,1)); % Adjust as needed
lagLabels = string(1:size(wcc,1)); % Adjust as needed

% Create the heatmap
h = heatmap(windowLabels, lagLabels, wcc);

% Customize the heatmap
h.Title = 'Cross-Correlation Heatmap';
h.XLabel = 'Windows';
h.YLabel = 'Lags';
h.Colormap = jet; % Change colormap to jet or any other
h.ColorScaling = 'scaledrows'; % Scales each row's color independently
