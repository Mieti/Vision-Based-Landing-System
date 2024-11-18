function index = simple_matching()
 
    camera_triangles = triangle_algorithm("CameraShot");
    tolerance = 1e-6;
    map = readtable("Triangles.csv");
    found = 0;
    index = 0;
    tp = 0;
    for i=1:height(map)
        if found
            break
        end
        for j=1:numel(camera_triangles)
            if abs(map.a(i) - camera_triangles(j).a) < tolerance && abs(map.b(i) - camera_triangles(j).b) < tolerance && abs(map.c(i) - camera_triangles(j).c) < tolerance
                tp = tp+1;
                found = 1;
                index = i;
                break
            end
        end
    end
    % disp(tp);

end