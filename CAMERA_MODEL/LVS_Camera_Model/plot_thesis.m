clear all
close all
clc

% Generate random data (1000 samples)
data = load('ETSM_DEFINITIVE_ADJ.mat').mc_results_def;  % Normally distributed data

% Define x-axis range
x = linspace(-10, 20, 500);

% Define two normal distributions (mean and standard deviation)
mu1 = 0;  sigma1 = 2;
mu2 = 8;  sigma2 = 3;

% Compute the probability density functions (PDFs)
pdf1 = normpdf(x, mu1, sigma1);
pdf2 = normpdf(x, mu2, sigma2);

% Plot both distributions
figure;
plot(x, pdf1,'LineWidth', 1.5); hold on;  % Blue solid line for first
plot(x, pdf2, 'r--', 'LineWidth', 1.5);          % Red dashed line for second
hold off;

% Add labels, title, and legend
xlabel('Value');
ylabel('Probability Density');
title('Comparison of Two Normal Distributions');
legend('Distribution 1 (Blue, \mu=0, \sigma=2)', 'Distribution 2 (Red, \mu=8, \sigma=3)', 'Location', 'northeast');
grid on;