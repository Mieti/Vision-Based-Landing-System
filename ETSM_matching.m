function ETSM_matching()
    camera_triangles = struct2table(triangle_algorithm("CameraShot"));
    map = readtable("Triangles_with_angles.csv");
    
    diff = 0;
    mind = 0;

    for i=1:height(camera_triangles)
        
        for j=1:height(map)
            sides = map(j, [10, 12]);
            sides_shot = camera_triangles(i, [10, 12]);
            angles = mink(map(j, [13, 15]), 2);
            angles_shot = mink(camera_triangles(i, [13, 15]), 2);
            d1 = max(sides);
            d1_shot = max(sides_shot);
            gamma = abs(d1/d1_shot);
            I = abs(dot(d1, dcenter) - (dot(d1_shot, dcenter_shot)/gamma^2));
            C = abs(cross(d1, dcenter) - (cross(d1_shot, dcenter_shot)/gamma^2));
            if I^2 + C^2 < abs(mind*dcenter)
                %controllare tutto
            end
        end
    end

end