function [] = plot_landmark_map(data, c, p, G, num_points, DistXMax, DistYMax, camera_view)
    %% Plot
    figure(c);
    hold on;
    % Plot landmarks
    plot_landmarks(data, num_points);
    % Plot image on terrain map
    if camera_view
        fill(G(:, 1), G(:, 2), 'b', 'FaceAlpha', 0.25);
    end
    % axis and view
    axis equal;
    xlim([-DistXMax DistXMax])
    ylim([-DistYMax DistYMax])
end

