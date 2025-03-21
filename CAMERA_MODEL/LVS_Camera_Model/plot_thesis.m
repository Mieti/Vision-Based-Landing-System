% MATLAB code to create Rel vs EST_dist visualization with highlighted elements
close all
clear all
clc
% This script recreates the Python visualization showing the relationship between
% Rel value and EST_dist with meaningful elements highlighted

%% Load the data
% Assuming the CSV file is in the current directory
% If not, provide the full path to the file
data = load('ETSM_FINAL_REL.mat').mc_results;
data = data(data.EST_dist < 1000,:);
%% Set up the figure
figure('Position', [100, 100, 1000, 800]);
hold on;

%% Define thresholds
rel_threshold = 3;
est_dist_threshold = 100;

%% Create scatter plot
% Get reliable and unreliable points
reliable_idx = data.Reliability == 1;
unreliable_idx = data.Reliability == 0;

% Scale the point sizes based on Inliers_ratio
min_size = 30;
max_size = 300;
normalized_sizes = (data.Inliers_ratio - min(data.Inliers_ratio)) / ...
                  (max(data.Inliers_ratio) - min(data.Inliers_ratio));
point_sizes = min_size + normalized_sizes * (max_size - min_size);

% Plot reliable points (green)
scatter(data.EST_dist(reliable_idx), data.Rel(reliable_idx), ...
        point_sizes(reliable_idx),  'filled', 'MarkerEdgeColor', 'k', ...
        'LineWidth', 1, 'DisplayName', 'Reliable (1)');
    
% % Plot unreliable points (red)
% scatter(data.EST_dist(unreliable_idx), data.Rel(unreliable_idx), ...
%         point_sizes(unreliable_idx), 'r', 'filled', 'MarkerEdgeColor', 'k', ...
%         'LineWidth', 1, 'DisplayName', 'Unreliable (0)');

%% Add threshold lines
% Rel threshold line
plot([0, 120], [rel_threshold, rel_threshold], ...
     '--b', 'Color', 'g','LineWidth', 2, 'DisplayName', ['Rel Threshold: ' num2str(rel_threshold, '%.4f')]);

% EST_dist threshold line
plot([est_dist_threshold, est_dist_threshold], [0, 5], ...
     '--m', 'Color', 'r','LineWidth', 2, 'DisplayName', ['EST\_dist Threshold: ' num2str(est_dist_threshold, '%.1f')]);

% %% Highlight regions
% % Reliable region (green)
% x_fill = [0, est_dist_threshold];
% y_fill_top = [max(data.Rel)*1.1, max(data.Rel)*1.1];
% y_fill_bottom = [rel_threshold, rel_threshold];
% fill([x_fill, fliplr(x_fill)], [y_fill_top, fliplr(y_fill_bottom)], 'g', ...
%      'FaceAlpha', 0.1, 'EdgeColor', 'none', 'DisplayName', 'Reliable Region');
% 
% % Unreliable region (red)
% x_fill = [est_dist_threshold, max(data.EST_dist)*1.1];
% y_fill_top = [rel_threshold, rel_threshold];
% y_fill_bottom = [0, 0];
% fill([x_fill, fliplr(x_fill)], [y_fill_top, fliplr(y_fill_bottom)], 'r', ...
%      'FaceAlpha', 0.1, 'EdgeColor', 'none', 'DisplayName', 'Unreliable Region');

