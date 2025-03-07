function [distance, direction, inliers, PosX, PosY, pos_diff, reliability] = ETSM_matching(run, Rand_x, Rand_y)

    % read full crater list map and triangles map
    craters = readtable("CraterMapRadius.csv");
    map = readtable("Triangles_with_angles.csv");

    % read camera shot crater list and triangle algorithm on shot image
    camera_craters = readtable("cameraShotSim.csv");
    camera_triangles = struct2table(triangle_algorithm("CameraShotSim"));
    

    craters_coordinates = craters{:, [1,2]};
    camera_craters_coordinates = camera_craters{:, [1,2]};
    diff = 4e3;
    mind = 3;
    gamma = 1;
    match = 0;
    tol = 1e-4;
    res_counter = 1;
    reliability = 0;
    rel_threshold = 100;

    distance = 9e6; direction = 9e6; inliers = 0; pos_diff = 9e6; PosX = 9e6; PosY = 9e6;
    % 2 nested loops to compare 2 triangles
    for i=1:height(camera_triangles)
        % if match
        %     break
        % end
        angles_shot = mink(camera_triangles{i, 13:15}, 2);
        for j=1:height(map)
            angles = mink(map{j, 13:15}, 2);
            difference = sum(abs(angles - angles_shot)); % difference between two minor angles of each triangle
            if difference < mind
                
                % full map triangle data
                sides = map{j, 10:12};
                [~, d1_index] = max(sides);
                A = [map.A_x(j), map.A_y(j)];
                B = [map.B_x(j), map.B_y(j)];
                C = [map.C_x(j), map.C_y(j)];
                AB = B-A;
                BC = C-B;
                CA = A-C;
                %determine longest side of the triangle
                if d1_index == 1
                    d1 = BC;
                elseif d1_index == 2
                    d1 = CA;
                else
                    d1 = AB;
                end
                centroid = [mean([A(1), B(1), C(1)]), mean([A(2), B(2), C(2)])]; % determine the centroid of the triangle
                
                % search for nearest crater excluding considered triangle vertexes from the full crater list 
                isVertex = ismember(craters_coordinates, [A;B;C], 'rows');
                filtered_coordinates = craters_coordinates(~isVertex,:);
                distances = sqrt((filtered_coordinates(:,1) - centroid(1)).^2 + (filtered_coordinates(:,2) - centroid(2)).^2);
                [~, minIndex] = mink(distances, 5);
                nearest_crater = filtered_coordinates(minIndex(1), :);
                dcenter = nearest_crater - centroid; % determine the distance between centroid and nearest crater

                % shot image triangle data
                x = camera_triangles{i, [1,4,7]};
                y = camera_triangles{i, [2,5,8]};
                sides_shot = camera_triangles{i, 10:12};
                AB_shot = [x(2) - x(1), y(2) - y(1)];
                BC_shot = [x(3) - x(2), y(3) - y(2)];
                CA_shot = [x(1) - x(3), y(1) - y(3)];
                centroid_shot = [mean(x), mean(y)];
                shot_sides = [sides_shot(3), sides_shot(1), sides_shot(2)];
                [~, idx] = max(shot_sides);
                if idx == 1
                    d1_shot = AB_shot;
                elseif idx == 2
                    d1_shot = BC_shot;
                else
                    d1_shot = CA_shot;
                end
                angle_rotation = d1_shot-d1;
                angles_rotation(i) = rad2deg(atan2(angle_rotation(2), angle_rotation(1)));
                % if ((abs(A(1) - (-1163.91)) < tol || abs(B(1) - (-1163.91)) < tol || abs(C(1) - (-1163.91)) < tol)  && (abs(x(1) - (-1156.92)) < tol || abs(x(2) - (-1156.92)) < tol || abs(x(3) - (-1156.92)) < tol)) 
                %     disp("TROVATO IL PUNTO");
                % end

                isVertex_shot = ismember(camera_craters_coordinates, [x',y'], 'rows');
                filtered_coordinates_camera = camera_craters_coordinates(~isVertex_shot,:);
                distances_shot = sqrt((filtered_coordinates_camera(:,1) - centroid_shot(1)).^2 + (filtered_coordinates_camera(:,2) - centroid_shot(2)).^2);
                [~, minIndex_shot] = mink(distances_shot, 5);
                nearest_crater_shot = filtered_coordinates_camera(minIndex_shot(1), :);
                dcenter_shot = nearest_crater_shot - centroid_shot;

                % calculate inner and cross products in order to obtain
                % discrepancy values between triangle and triangle'
                Inner = abs(dot(d1, dcenter) - (dot(d1_shot, dcenter_shot)/gamma^2));
                Cross = abs((d1(1)*dcenter(2) - d1(2)*dcenter(1)) - ((d1_shot(1)*dcenter_shot(2) - d1_shot(2)*dcenter_shot(1))/gamma^2));
                if Inner^2+Cross^2 < diff*norm(dcenter)
                    %disp("MATCH FOUND!");
                    %match = 1;
                    result_final(res_counter, 1) = x(1);
                    result_final(res_counter, 2) = y(1);
                    result_final(res_counter, 3) = i;
                    result_final(res_counter, 4) = x(2);
                    result_final(res_counter, 5) = y(2);
                    result_final(res_counter, 6) = j;
                    result_final(res_counter, 7) = x(3);
                    result_final(res_counter, 8) = y(3);
                    result_final(res_counter, 9) = centroid(1);
                    result_final(res_counter, 10) = centroid(2);
                    result_final(res_counter, 11) = centroid_shot(1);
                    result_final(res_counter, 12) = centroid_shot(2);
                    result_final(res_counter, 13) = d1(1);
                    result_final(res_counter, 14) = d1(2);
                    result_final(res_counter, 15) = dcenter(1);
                    result_final(res_counter, 16) = dcenter(2);
                    result_final(res_counter, 17) = d1_shot(1);
                    result_final(res_counter, 18) = d1_shot(2);
                    result_final(res_counter, 19) = dcenter_shot(1);
                    result_final(res_counter, 20) = dcenter_shot(2);
                    res_counter = res_counter + 1;
                    break
                end
            end
        end
    end
    if res_counter > 1
        cs = [result_final(:,11), result_final(:,12)];
        ct = [result_final(:,9), result_final(:,10)];
        cs_d1 = [result_final(:,17), result_final(:,18)];
        cs_dcenter = [result_final(:,19), result_final(:,20)];
        ct_d1 = [result_final(:,13), result_final(:,14)];
        ct_dcenter = [result_final(:,15), result_final(:,16)];
        for i=1:height(cs_d1)
        theta(i,:) = acos(dot(cs_d1(i,:),ct_d1(i,:))./(norm(cs_d1(i,:))*norm(ct_d1(i,:))));
        delta(i,:) = acos(dot(cs_dcenter(i,:),ct_dcenter(i,:))./(norm(cs_dcenter(i,:))*norm(ct_dcenter(i,:))));
        
        
        cross_product = cs_dcenter(i,1) * ct_dcenter(i,2) - cs_dcenter(i,2) * ct_dcenter(i,1);
        
        % Compute the dot product
        dot_product = dot(cs_dcenter(i,:), ct_dcenter(i,:));
        
        % Calculate the signed angle (in radians)
        angle_rad(i,:) = atan2(cross_product, dot_product);



        end
        % rotation_angle(:,1) = atan2(cs(:,1).*ct(:,2) - cs(:,2).*ct(:,1), cs(:,1).*ct(:,1) + cs(:,2).*ct(:,2));
        rotation_angle = -angle_rad;
        rotation_mean = mean(rotation_angle);
        rotation_std = std(rotation_angle);
        rotation_filtered = rotation_angle(abs(rotation_angle(:,1)-rotation_mean) <= 3*rotation_std, :);
        phi = mean(rotation_filtered);
        %disp(rad2deg(phi));
        R_mat = [cos(phi), sin(phi); -sin(phi), cos(phi)];
        cs = (R_mat*cs')';
        result_final(:,11) = cs(:,1);
        result_final(:,12) = cs(:,2);
        distance = mean(ct-cs);
        direction = rad2deg(-phi);
        inliers = res_counter;
        origin = (R_mat*[0 0]'+distance')';
        origin_diff = vecnorm([Rand_x Rand_y]-(R_mat*[0 0]'+distance')');
        PosX = origin(1);
        PosY = origin(2);
        pos_diff = origin_diff;
        result_filtered = result_final;
        if res_counter >= 5
            centroid_dist = [result_final(:,9)-result_final(:,11), result_final(:,10)-result_final(:,12)];
            centroid_mean = mean(centroid_dist);
            centroid_std = std(centroid_dist);
            
            result_filtered = result_final(abs(centroid_dist(:,1)-centroid_mean(1)) <= 3*centroid_std(1) & abs(centroid_dist(:,2)-centroid_mean(2)) <= 3*centroid_std(2), :);
            centroid_dist = [result_filtered(:,9)-result_filtered(:,11), result_filtered(:,10)-result_filtered(:,12)];
            centroid_mean = mean(centroid_dist);
            centroid_std = std(centroid_dist);
            result_restricted = result_filtered(abs(centroid_dist(:,1)-centroid_mean(1)) <= 2*centroid_std(1) & abs(centroid_dist(:,2)-centroid_mean(2)) <= 2*centroid_std(2), :);
            result_filtered = result_filtered(abs(centroid_dist(:,1)-centroid_mean(1)) <= 3*centroid_std(1) & abs(centroid_dist(:,2)-centroid_mean(2)) <= 3*centroid_std(2), :);
            cs = [result_filtered(:,11), result_filtered(:, 12)];
            ct = [result_filtered(:,9), result_filtered(:, 10)];
            
            centroid_dist_filtered = [result_filtered(:,9)-result_filtered(:,11), result_filtered(:,10)-result_filtered(:,12)];
            centroid_dist_restricted = [result_restricted(:,9)-result_restricted(:,11), result_restricted(:,10)-result_restricted(:,12)];
            % figure(3*run-1);
            % hold on;
            % plot(global_centroid(1), global_centroid(2), '-o', 'LineWidth', 1, 'Color', 'g');
            % plot(local_centroid(1), local_centroid(2), '-o', 'LineWidth', 1, 'Color', 'cyan');
            % plot(0, 0, '-o', 'LineWidth', 1, 'Color', 'black');
            centroid_mean_filtered = mean(centroid_dist_filtered);
            centroid_mean_restricted = mean(centroid_dist_restricted);
            % distance = norm(mean([result_filtered(:,9),result_filtered(:,10)]-([result_filtered(:,11), result_filtered(:,12)]+centroid_mean_filtered)));
            distance = mean(vecnorm(ct(:,:)-(cs(:,:)+centroid_mean_filtered),2,2));
            direction = rad2deg(-phi);
            inliers = height(centroid_dist_filtered);
            %origin_diff = vecnorm([Rand_x, Rand_y]-([0 0]+centroid_mean_filtered));
            % origin_diff = T;
            origin = (R_mat*[0 0]'+centroid_mean_filtered')';
            origin_diff = vecnorm([Rand_x Rand_y]-(R_mat*[0 0]'+centroid_mean_filtered')');
            origin_restricted = vecnorm([Rand_x Rand_y]-(R_mat*[0 0]'+centroid_mean_restricted')');
            if abs(origin_restricted - origin_diff) < rel_threshold
                reliability = 1;
            end
            PosX = origin(1);
            PosY = origin(2);
            pos_diff = origin_diff;
            % plot(point(1), point(2), '-o', 'LineWidth', 1, 'Color', 'black');
        end
        %fare media e comporre il vettore traslazione
        % data = result_final;
        % map = readmatrix("Triangles_with_angles.csv");
        % 
        % xA = data(:, 1); yA = data(:, 2);
        % xB = data(:, 4); yB = data(:, 5);
        % xC = data(:, 7); yC = data(:, 8);
        % 
        % xA2 = map(:, 1); yA2 = map(:, 2);
        % xB2 = map(:, 4); yB2 = map(:, 5);
        % xC2 = map(:, 7); yC2 = map(:, 8);

        % Number of triangles
        % numTriangles = size(data, 1);
        % numTriangles2 = size(map, 1);
        % Plot triangles
        % cmap = lines(numTriangles);
        % figure(3*run-1);
        % hold on; % Retain plots for multiple triangles
        % axis equal; % Equal scaling for x and y axes
        % title('Coarse Matches');
        % xlabel('X'); ylabel('Y');
        % 
        % for i = 1:numTriangles
        %     % Get vertices of the current triangle
        %     xCoords = [xA(i), xB(i), xC(i), xA(i)]; % Close the triangle
        %     yCoords = [yA(i), yB(i), yC(i), yA(i)];
        % 
        %     % Plot the triangle
        %     plot(xCoords, yCoords, '-o', 'LineWidth', 1, 'Color', 'r');
        % end
        % 
        % for i = 1:numTriangles
        %     map_index = data(i, 6);
        %     % Get vertices of the current triangle
        %     xCoords2 = [xA2(map_index), xB2(map_index), xC2(map_index), xA2(map_index)]; % Close the triangle
        %     yCoords2 = [yA2(map_index), yB2(map_index), yC2(map_index), yA2(map_index)];
        % 
        %     % Plot the triangle
        %     plot(xCoords2, yCoords2, '-o', 'LineWidth', 1, 'Color', 'b');
        %     % plot(Rand_x, Rand_y, '-o', 'LineWidth', 1, 'Color', 'g');
        %     % plot(0, 0, '-o', 'LineWidth', 1, 'Color', 'g');
        %     % plot(0+centroid_mean_filtered(1), 0+centroid_mean_filtered(2), '-o', 'LineWidth', 1, 'Color', 'y');
        % end
        % 
        % hold off;
        % 
        % figure(3*run);
        % hold on; % Retain plots for multiple triangles
        % axis equal; % Equal scaling for x and y axes
        % title('Matches After outliers filter');
        % xlabel('X'); ylabel('Y');

        % data = result_filtered;
        % for i = 1:height(result_filtered)
        %     map_index = data(i, 6);
        %     vA = R_mat*[data(i, 1),data(i, 2)]'+centroid_mean_filtered';
        %     vB = R_mat*[data(i, 4),data(i, 5)]'+centroid_mean_filtered';
        %     vC = R_mat*[data(i, 7),data(i, 8)]'+centroid_mean_filtered';
            % xA = data(i, 1)+centroid_mean_filtered(1); yA = data(i, 2)+centroid_mean_filtered(2);
            % xB = data(i, 4)+centroid_mean_filtered(1); yB = data(i, 5)+centroid_mean_filtered(2);
            % xC = data(i, 7)+centroid_mean_filtered(1); yC = data(i, 8)+centroid_mean_filtered(2);
            % Get vertices of the current triangle
            % xCoords = [xA, xB, xC, xA]; % Close the triangle
            % yCoords = [yA, yB, yC, yA];
            % prova(i,[3 4]) = [xB2(map_index) yB2(map_index)] - vB';
            % prova(i,[5 6]) = [xC2(map_index) yC2(map_index)] - vC';
            % xCoords = [vA(1), vB(1), vC(1), vA(1)]; % Close the triangle
            % yCoords = [vA(2), vB(2), vC(2), vA(2)];
            % xCoords2 = [xA2(map_index), xB2(map_index), xC2(map_index), xA2(map_index)]; % Close the triangle
            % yCoords2 = [yA2(map_index), yB2(map_index), yC2(map_index), yA2(map_index)];
            % Plot the triangle
            % plot(xCoords, yCoords, '-o', 'LineWidth', 1, 'Color', 'r');
            % plot(xCoords2, yCoords2, '-o', 'LineWidth', 1, 'Color', 'b');        
        % end
    % end
end