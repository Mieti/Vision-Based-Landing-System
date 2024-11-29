clear all
close all
clc

%% Map, Lander, Camera and Landmarks settings
scenario_settings;


%% Generate Landmarks
% Element features (for each element crater or rock)
% c_landmark[3], center of the landmark in the Planer Ref Frame
% n_landmark[3], normal to the landmark in the Planer Ref Frame
% r_landmark, radius of the landmark

% Catalogue 1
landmarks = generate_landmarks( ...
    DistXMax, DistYMax, DistZMax, NormXMax, NormYMax, num_landmarks, ...
    RadLMMin, RadLMMax);
% Catalogue 2
landmarks2 = generate_landmarks( ...
    DistXMax2, DistYMax2, DistZMax2, NormXMax, NormYMax, num_landmarks, ...
    RadLMMin2, RadLMMax2);

% Combined landmarks for camera model
landmarks_real.num_landmarks = landmarks.num_landmarks + landmarks2.num_landmarks;
for k = 1:landmarks_real.num_landmarks
   if k <= landmarks.num_landmarks
       landmarks_real.ilandmark(k) = landmarks.ilandmark(k);
       landmarks_real.clandmarkX(k) = landmarks.clandmarkX(k);
       landmarks_real.clandmarkY(k) = landmarks.clandmarkY(k);
       landmarks_real.clandmarkZ(k) = landmarks.clandmarkZ(k);
       landmarks_real.rlandmark(k) = landmarks.rlandmark(k);
       landmarks_real.nlandmarkX(k) = landmarks.nlandmarkX(k);
       landmarks_real.nlandmarkY(k) = landmarks.nlandmarkY(k);
       landmarks_real.nlandmarkZ(k) = landmarks.nlandmarkZ(k);
   else
       landmarks_real.ilandmark(k) = landmarks2.ilandmark(k - landmarks.num_landmarks);
       landmarks_real.clandmarkX(k) = landmarks2.clandmarkX(k - landmarks.num_landmarks);
       landmarks_real.clandmarkY(k) = landmarks2.clandmarkY(k - landmarks.num_landmarks);
       landmarks_real.clandmarkZ(k) = landmarks2.clandmarkZ(k - landmarks.num_landmarks);
       landmarks_real.rlandmark(k) = landmarks2.rlandmark(k - landmarks.num_landmarks);
       landmarks_real.nlandmarkX(k) = landmarks2.nlandmarkX(k - landmarks.num_landmarks);
       landmarks_real.nlandmarkY(k) = landmarks2.nlandmarkY(k - landmarks.num_landmarks);
       landmarks_real.nlandmarkZ(k) = landmarks2.nlandmarkZ(k - landmarks.num_landmarks);
   end
end

%% Save landmarks
save 'Cat_5000_600elements.mat' landmarks -mat
save 'Cat_3000_600elements.mat' landmarks2 -mat
save 'Cat_real_1200elements.mat' landmarks_real -mat

%% Filter Catalogues

% Catalogue 1
landmarks_filtered = filter_landmarks(landmarks, 200);

% Catalogue 2
landmarks2_filtered = filter_landmarks(landmarks2, 100);

%% Save filtered landmarks
save 'Cat_5000_600elements_filtered.mat' landmarks_filtered -mat
save 'Cat_3000_600elements_filtered.mat' landmarks2_filtered -mat


%% Plot
set(gcf, 'renderer', 'zbuffer');
figure(1);
hold on;
grid on;
% Plot landmarks
plot_landmarks(landmarks, num_points);
% Plot Lander
plot3(P(:, 1), P(:, 2), P(:, 3));
% Plot pinhole origin
[w1, w2, w3] = dot_graphics(W);
surf(w1, w2, w3);
% Plot camera lens center
[cc1, cc2, cc3] = dot_graphics(CC);
surf(cc1, cc2, cc3);
% Plot camera lens (rectangle)
plot3(C_pinhole(:, 1), C_pinhole(:, 2), C_pinhole(:, 3));
% Plot image on terrain map
p = fill(G(:, 1), G(:, 2), 'b', 'FaceAlpha', 0.25);
%plot3(G(:, 1), G(:, 2), G(:, 3));
%p(1).FaceAlpha = 0.23;
% axis and view
axis equal;
xlim([-DistXMax DistXMax])
ylim([-DistYMax DistYMax])
zlim([0 5000])
view(38, 40);

%% Plot Landmarks unfiltered and filtered

plot_landmark_map(landmarks, 2, p, G, num_points, DistXMax, DistYMax, false);
grid on
title('Generated Catalogue');
xlabel('$x$', 'Interpreter', 'latex');
ylabel('$y$', 'Interpreter', 'latex');
% Adjust the linewidth of the axes and labels
set(gca, 'LineWidth', 0.5); % Set the linewidth of the axes
set(gca, 'FontWeight', 'normal'); % Set the font weight of the axes labels
print('landmarks_map.eps', '-depsc');

plot_landmark_map(landmarks_filtered, 3, p, G, num_points, DistXMax, DistYMax, false);
grid on
title('Filtered Catalogue');
xlabel('$x$', 'Interpreter', 'latex');
ylabel('$y$', 'Interpreter', 'latex');
% Adjust the linewidth of the axes and labels
set(gca, 'LineWidth', 0.5); % Set the linewidth of the axes
set(gca, 'FontWeight', 'normal'); % Set the font weight of the axes labels
print('landmarks_filtered_map.eps', '-depsc');

plot_landmark_map(landmarks_real, 4, p, G, num_points, DistXMax, DistYMax, false);
grid on
title('Generated Catalogue');
xlabel('$x$', 'Interpreter', 'latex');
ylabel('$y$', 'Interpreter', 'latex');
% Adjust the linewidth of the axes and labels
set(gca, 'LineWidth', 0.5); % Set the linewidth of the axes
set(gca, 'FontWeight', 'normal'); % Set the font weight of the axes labels
print('landmarks_map_real.eps', '-depsc');