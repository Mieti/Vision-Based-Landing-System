clear all
close all
clc

% Generate random data (1000 samples)
data = load('ETSM_DEFINITIVE_ADJ.mat').mc_results_def;  % Normally distributed data
data = data(data.EST_dist < 9000000, :);
data = data.EST_dist;

box = boxplot(data, 'Notch', 'on', 'Colors', 'b', 'Symbol', 'o');

% Fill the box with blue color
h = findobj(gca, 'Tag', 'Box');
for i = 1:length(h)
    patch(get(h(i), 'XData'), get(h(i), 'YData'), 'b', 'FaceAlpha', 0.5); % Adjust transparency if needed
end

% Change the median line color to red
medianLine = findobj(gca, 'Tag', 'Median');
set(medianLine, 'Color', 'r', 'LineWidth', 1);

% Add labels

ylabel('Distance Error [m]')
title('Box Plot of Distance Error (Inliers + Outliers)');

% Improve grid visibility
grid on