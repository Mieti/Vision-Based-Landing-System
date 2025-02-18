clear all
close all
clc

craters = table2array(readtable("CraterMapRadius.csv"));

    % read camera shot crater list and triangle algorithm on shot image
    % craters = table2array(readtable("cameraShotSim.csv"));

    k = 7;
    m = 5;
    % threshold = 0.7;
    nbins = 4;
    craters_v1 = zeros(height(craters),2);

    % create histogram for each camera crater
    for i=1:height(craters)
        center = craters(i, 1:2);
        rc = craters(i, 3);
       
        if vecnorm(center - [1195.7, -1563.9], 2, 2) < 20
            % disp("YOURE HERE")
        end
        distances = vecnorm(craters(:, 1:2) - center, 2, 2);
        is_neighbor = (distances < k*rc) & (distances > 0);
        neighbors = craters(is_neighbor, :);

        % Compute the reference direction vector v1 to the largest neighbor
        % [~, idx] = max(neighbors(:, 3));  % Index of largest neighbor by radius
        % v1 = neighbors(idx, 1:2) - center;  % Reference vector (v1)

        neighbors = sortrows(neighbors, 3, 'descend');

        % Loop through all neighbors to compute f1
        num_neighbors = size(neighbors, 1);
        if num_neighbors < m 
            continue
        end
        v1 = neighbors(1, 1:2) - center;
        features = [];
        for j = 2:num_neighbors
            % Vector to current neighbor
            vj = neighbors(j, 1:2) - center;
            
            % Anti-clockwise angle difference using atan2
            theta_j = atan2d(vj(2), vj(1)) - atan2d(v1(2), v1(1));
            
            % Wrap angle to [0, 360) (anti-clockwise orientation)
            theta_j = mod(theta_j + 360, 360);
            
            % Normalize to range [0, 1]
            f1 = theta_j / 360;
            % 
            f2 = rc/neighbors(j,3);
            f3 = norm(vj)/norm(v1);

            features(j-1,1) = f1;
            features(j-1,2) = f2;
            features(j-1,3) = f3;
        end
        max_f2 = max(features(:,2));
        min_f2 = min(features(:,2));
        max_f3 = max(features(:,3));
        min_f3 = min(features(:,3));
        
        % normalise feature2 and feature3
        for j=1:height(features)
            features(j,2) = (features(j,2) - min_f2)/(max_f2 - min_f2);
            features(j,3) = (features(j,3) - min_f3)/(max_f3 - min_f3);
        end

        edges_f1 = linspace(0, 1, nbins + 1);
        edges_f2 = linspace(0, 1, nbins + 1);
        edges_f3 = linspace(0, 1, nbins + 1);
        % Hs(i) = histogram(features, nbins);

        H = zeros(nbins, nbins, nbins);

        for idx = 1:size(features, 1)
            % Extract current feature tuple (f1, f2, f3)
            f1 = features(idx, 1);
            f2 = features(idx, 2);
            f3 = features(idx, 3);
            
            % Find the bin indices for each feature
            bin_f1 = find(edges_f1 <= f1, 1, 'last') - 1;
            bin_f2 = find(edges_f2 <= f2, 1, 'last') - 1;
            bin_f3 = find(edges_f3 <= f3, 1, 'last') - 1;
            
            if  bin_f1 == 0
                bin_f1 = 1;
            end
            if  bin_f2 == 0
                bin_f2 = 1;
            end
            if  bin_f3 == 0
                bin_f3 = 1;
            end
            % Ensure indices are within valid bin range
            if bin_f1 >= 1 && bin_f2 >= 1 && bin_f3 >= 1
                H(bin_f1, bin_f2, bin_f3) = H(bin_f1, bin_f2, bin_f3) + 1;
            end
        end
    
        % Normalize the histogram (optional)
        % H_normalized = H / sum(H(:));
        
        % Store or process the histogram for this crater
        Ht{i} = H;
        craters_v1(i,:) = v1;
    end
    % Ht = cell2table(Ht);
    % writetable(Ht, './RANSAC.csv');
    save('./RANSAC_FullMap', 'Ht');
    save('./Craters_v1', "craters_v1");