clear all
close all
clc

% % Generate random data (1000 samples)
% data = load('ETSM_FINAL_ORIGIN.mat').mc_results;  % Normally distributed data
% rel_diff = data.Rel_diff(data.Reliability == 1);
% origin3s = data.Origin3s(data.Reliability == 1);
% origin2s = data.Origin2s(data.Reliability == 1);
% inliers = data.Inliers(data.Reliability == 1);
% 
% figure;
% hold on;
% % plot(origin3s, 'LineWidth', 1.5); % Blue line with circles
% % plot(origin2s, 'LineWidth', 1.5); % Blue line with circles
% plot(inliers.*rel_diff, 'LineWidth', 1.5);
% % xline(threshold, 'r--', 'LineWidth', 1.5); % Red dashed line for the threshold
% % yline(threshold2, 'g--', 'LineWidth', 1.5);
% hold off;
% 
% % Labels and Title
% ylabel('Estimated Position Difference');
% xlabel('Cost');
% title('Cost vs. Estimated Position Difference');
% % legend('Cost', 'T_{Cost} = 1\cdot10^3', 'T_{Pos} = 1\cdot10^2','Location', 'best');
% grid on;


