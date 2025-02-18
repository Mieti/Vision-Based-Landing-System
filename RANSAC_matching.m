function [mean_translation, distance, direction] = RANSAC_matching(run)

    % read full crater list map and triangles map
    craters = table2array(readtable("CraterMapRadius.csv"));
    Ht = load("RANSAC_FullMap.mat").Ht;
    craters_v1 = load("Craters_v1.mat").craters_v1;
    % read camera shot crater list and triangle algorithm on shot image
    camera_craters = table2array(readtable("CameraShotSim.csv"));

    k = 7;
    m = 5;
    threshold = 0.7;
    nbins = 4;
    threshold_cost = 1e6;
    mean_translation = [0,0];
    distance = 0;
    direction = 0;
    % create histogram for each camera crater
    for i=1:height(camera_craters)
        center = camera_craters(i, 1:2);
        rc = camera_craters(i, 3);
       
        distances = vecnorm(camera_craters(:, 1:2) - center, 2, 2);
        is_neighbor = (distances < k*rc) & (distances > 0);
        neighbors = camera_craters(is_neighbor, :);

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
        v1_list(i,1) = v1(1);
        v1_list(i,2) = v1(2);
        % figure(4);
        % theta = linspace(0,2*pi);
        % x = (rc*k)*cos(theta) + center(1);
        % y = (rc*k)*sin(theta) + center(2); 
        % plot(x,y,'g', "LineWidth", 1);
        % 
        % hold on;
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
        Hs{i} = H;
    end

    % Euclidean distance between Hs - Ht

    diff_counter = 0;
    for i=1:size(Hs,2)
        if size(Hs{i},1) == 0
            continue
        end
        for j=1:size(Ht,2)
            if size(Ht{j},1) == 0
                continue
            end
            sum = 0;
            for o=1:4
                for p=1:4
                    for q=1:4
                        sum = sum + (Hs{i}(o,p,q) - Ht{j}(o,p,q))^2;
                    end
                end
            end
            diff = sqrt(sum);
            if diff < threshold
                result(diff_counter+1,1) = camera_craters(i,1);
                result(diff_counter+1,2) = camera_craters(i,2);
                result(diff_counter+1,3) = camera_craters(i,3);
                result(diff_counter+1,4) = craters(j,1);
                result(diff_counter+1,5) = craters(j,2);
                result(diff_counter+1,6) = craters(j,3);
                result(diff_counter+1,7) = v1_list(i,1);
                result(diff_counter+1,8) = v1_list(i,2);
                result(diff_counter+1,9) = craters_v1(j,1);
                result(diff_counter+1,10) = craters_v1(j,2);
                diff_counter = diff_counter+1;
                break
            end
        end
    end
    
    total_cost = intmax;
    if height(result) >= 4
        for i=1:height(result)
            ct = [result(i, 4) result(i,5)]';
            cs = [result(i, 1) result(i,2)]';
            s = result(i,6)/result(i,3);
            v1 = [result(i,7), result(i,8)];
            v1_crater = [result(i,9) result(i,10)];
            phi = acos(dot(v1,v1_crater)/(norm(v1)*norm(v1_crater)));
            R = [cos(phi) sin(phi); -sin(phi) cos(phi)];
            
            t = ct - s*R*cs;
            disp(R);
            cs_prime = zeros(height(result),2);
    
            for j=1:height(result)
                cs_prime(j,:) = [result(j, 1) result(j,2)] + t';
            end
    
            numCraters = height(result);
            for rand_i=1:4
                idxs = randperm(numCraters, 4);
                cs_selected = cs_prime(idxs, :);
                ct_selected = result(idxs, [4,5]);
                
                for j=1:4
                    x_t = ct_selected(j,1);
                    y_t = ct_selected(j,2);
                    x_s = cs_selected(j,1);
                    y_s = cs_selected(j,2);
                    
                    A(2*j-1, :) = [-x_s, -y_s, -1, 0, 0, 0, x_t*x_s, x_t*y_s, x_t];
                    A(2*j,:) = [0, 0, 0, -x_s, -y_s, -1, y_t*x_s, y_t*y_s, y_t];
                    C(2*j-1, :) = [-x_s, -y_s, -1, 0, 0, 0, x_t*x_s, x_t*y_s];
                    C(2*j,:) = [0, 0, 0, -x_s, -y_s, -1, y_t*x_s, y_t*y_s];
                    Z(2*j-1,:) = x_t;
                    Z(2*j,:) = y_t;
                    B(3*j-2, :) = [x_s, y_s, 1, 0, 0, 0, 0, 0];
                    B(3*j-1,:) = [0, 0, 0, x_s, y_s, 1, 0, 0];
                    B(3*j,:) = [0, 0, 0, 0, 0, 0, x_s, y_s];
                    Y(3*j-2,:) = x_t;
                    Y(3*j-1,:) = y_t;
                    Y(3*j,:) = 0;
                end
    
                % [~, ~, V] = svd(A);
                % h = V(:, end);
                % h = h / h(end);
    
                SOL = inv(B'*B)*B'*Y;
                h = B\Y;
                h2 = C\Z;
                SOL3 = pinv(B) * Y;
                residual = norm(B * h - Y);
                cost = 0;
                inlier_index = 1;
                inliers = [];
                for j=1:height(cs_prime)
                    x_prime = cs_prime(j,1);
                    y_prime = cs_prime(j,2);
                    x_t = result(j,4);
                    y_t = result(j,5);
                    xs_second = (h(1)*x_prime + h(2)*y_prime + h(3))/(h(7)*x_prime + h(8)*y_prime + 1);
                    ys_second = (h(4)*x_prime + h(5)*y_prime + h(6))/(h(7)*x_prime + h(8)*y_prime + 1);
                    xs_second_1 = (h2(1)*x_prime + h2(2)*y_prime + h2(3))/(h2(7)*x_prime + h2(8)*y_prime + 1);
                    ys_second_1 = (h2(4)*x_prime + h2(5)*y_prime + h2(6))/(h2(7)*x_prime + h2(8)*y_prime + 1);
                    singular_cost = ((x_t - xs_second)^2 + (y_t - ys_second)^2);
                    cost = cost + singular_cost;
                    if singular_cost < threshold_cost
                        inliers(inlier_index, 1) = xs_second;
                        inliers(inlier_index, 2) = ys_second;
                        inliers(inlier_index, 3) = result(j,3);
                        inliers(inlier_index, 4) = j;
                        inliers(inlier_index, 5) = cost;
                        inlier_index = inlier_index+1;
                    end
                end
                % disp(cost/height(cs_prime));
                if cost < total_cost
                    t_final = t;
                    R_final = R;
                    phi_final = phi;
                    s_final = s;
                    total_cost = cost;
                    cs_final = result;
                    cs_prime_final = cs_prime;
                    h_final = h;
                    h2_final = h2;
                    inliers_final = inliers;
                end
            end
        end

        if size(inliers_final) > 0
            inliers_target = result(inliers_final(:,4), [4,5,6]);
            cs_final_t = [result(inliers_final(:,4), [1,2,3])];
            if height(inliers_final) > 1
                mean_translation = mean([inliers_final(:,1)-inliers_target(:,1), inliers_final(:,2)-inliers_target(:,2)]);
            else
                mean_translation = [inliers_final(:,1)-inliers_target(:,1), inliers_final(:,2)-inliers_target(:,2)];
            end
            distance = norm(mean_translation);
            direction = phi_final;%atan2d(mean_translation(2), mean_translation(1));

            % figure(3*run-1);
            % title('Fine Matches');
            % xlabel('X'); ylabel('Y');
            % hold on;
            % theta = linspace(0,2*pi);
            % colors = lines(height(result));
            % inliers_colors = lines(height(inliers_final));
            
            % for i=1:height(inliers_final)
            %     % x = result(i,3)*cos(theta) + cs_prime_final(i,1);
            %     % y = result(i,3)*sin(theta) + cs_prime_final(i,2);
            %     x = inliers_final(i,3)*cos(theta) + inliers_final(i,1);
            %     y = inliers_final(i,3)*sin(theta) + inliers_final(i,2);
            %     plot(x,y,'Color', 'r');
            %     x2 = inliers_target(i,3)*cos(theta) + inliers_target(i,1);
            %     y2 = inliers_target(i,3)*sin(theta) + inliers_target(i,2);
            %     plot(x2,y2,'Color', 'b');
            % end
            % hold off
        
            % figure(3*run);
            % title('Histogram Matches');
            % xlabel('X'); ylabel('Y');
            % hold on
            % for i=1:height(result)
            %     x = result(i,3)*cos(theta) + result(i,1);
            %     y = result(i,3)*sin(theta) + result(i,2);
            %     % x = result(i,3)*cos(theta) + cs_prime_final(i,1);
            %     % y = result(i,3)*sin(theta) + cs_prime_final(i,2);
            %     plot(x,y,'Color', 'r');
            %     x2 = result(i,6)*cos(theta) + result(i,4);
            %     y2 = result(i,6)*sin(theta) + result(i,5);
            %     plot(x2,y2,'Color', 'b');
            % end
        end
    else
        disp("Not enough correspondences to resolve fine matching")
    end
end