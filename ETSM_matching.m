function ETSM_matching()

    % read full crater list map and triangles map
    craters = readtable("CraterMapRadius.csv");
    map = readtable("Triangles_with_angles.csv");

    % read camera shot crater list and triangle algorithm on shot image
    camera_craters = readtable("cameraShotSim.csv");
    camera_triangles = struct2table(triangle_algorithm("CameraShotSim"));
    

    craters_coordinates = craters{:, [1,2]};
    camera_craters_coordinates = camera_craters{:, [1,2]};
    diff = 10;
    mind = 10;
    gamma = 1;
    match = 0;

    % 2 nested loops to compare 2 triangles
    for i=1:height(camera_triangles)
        if match
            break
        end
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
                    disp("MATCH FOUND!");
                    match = 1;
                    break
                end
            end
        end
    end
end