function [] = plot_landmarks(landmarks, num_points)
%PLOT_LANDMARKS function

    % Plot landmarks
    for i_landmark = 1:landmarks.num_landmarks
        c_landmark = [landmarks.clandmarkX(i_landmark) landmarks.clandmarkY(i_landmark) landmarks.clandmarkZ(i_landmark)];
        r_landmark = landmarks.rlandmark(i_landmark);
        n_landmark = [landmarks.nlandmarkX(i_landmark) landmarks.nlandmarkY(i_landmark) landmarks.nlandmarkZ(i_landmark)];
        
        points = points_on_rim(c_landmark, n_landmark, r_landmark, num_points);
        
        px = points(1,:);
        py = points(2,:);
        pz = points(3,:);
        
        plot3(px, py, pz);
    end
    
end