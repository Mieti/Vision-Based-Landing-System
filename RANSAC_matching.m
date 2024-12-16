function RANSAC_matching()

    % read full crater list map and triangles map
    craters = table2array(readtable("CraterMapRadius.csv"));

    % read camera shot crater list and triangle algorithm on shot image
    camera_craters = table2array(readtable("cameraShotSim.csv"));

    k = 10;
    m = 8;
    threshold = 0.7;

    % create histogram for each camera crater
    for i=1:height(camera_craters)
        center = camera_craters(i, 1:2);
        rc = camera_craters(i, 3);
       
        distances = vecnorm(camera_craters(:, 1:2) - center, 2, 2);
        is_neighbor = (distances < k*rc) & (distances > 0);
        neighbors = camera_craters(is_neighbor, :);

        % Compute the reference direction vector v1 to the largest neighbor
        [~, idx] = max(neighbors(:, 3));  % Index of largest neighbor by radius
        v1 = neighbors(idx, 1:2) - center;  % Reference vector (v1)

        % Loop through all neighbors to compute f1
        num_neighbors = size(neighbors, 1);
        f1 = zeros(num_neighbors, 1);
        
        for j = 1:num_neighbors
            % Vector to current neighbor
            vj = neighbors(j, 1:2) - center;
            
            % Anti-clockwise angle difference using atan2
            theta_j = atan2d(vj(2), vj(1)) - atan2d(v1(2), v1(1));
            
            % Wrap angle to [0, 360) (anti-clockwise orientation)
            theta_j = mod(theta_j + 360, 360);
            
            % Normalize to range [0, 1]
            f1(j) = theta_j / 360;
            % 
            f2(j) = rc/neighbors(3);
            f3(j) = norm(vj)/norm(v1);


        end



    end