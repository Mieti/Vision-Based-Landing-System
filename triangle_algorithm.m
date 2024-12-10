function triangles = triangle_algorithm(fileName)
    % clc
    % clear all;
    % close all;
    
    cameraShot = readtable(fileName + ".csv");
    %cameraShot = load(fileName + ".mat").cameraShot;
    counter = 1;
    theta = linspace(0,2*pi);
    colors = lines(height(cameraShot)); % 'lines' colormap provides a set of visually distinct colors
    
    % figure(1);
    distances = zeros(height(cameraShot), height(cameraShot));
    
    % for i=1:height(cameraShot)
    %     x = cameraShot.Radius(i)*cos(theta) + cameraShot.PosX(i);
    %     y = cameraShot.Radius(i)*sin(theta) + cameraShot.PosY(i);
    %     plot(x,y);
    %     hold on;
    % end
    
    for i=1:height(cameraShot)
        for j=1:height(cameraShot)
            distances(i,j) = sqrt((cameraShot.PosX(i)-cameraShot.PosX(j))^2 + (cameraShot.PosY(i) - cameraShot.PosY(j))^2);
        end
    end
    
    [~, sortedIndices] = sort(distances);
    
    for i=1:height(cameraShot)
        % x = cameraShot.Diameter(i)/2*cos(theta) + cameraShot.PosX(i);
        % y = cameraShot.Diameter(i)/2*sin(theta) + cameraShot.PosY(i);
        % h1 = plot(x,y, 'LineWidth', 4, 'MarkerSize', 8, 'Color', 'r');
    
        triangles(counter).A_x = cameraShot.PosX(i);
        triangles(counter).A_y = cameraShot.PosY(i);
        triangles(counter).A_radius = cameraShot.Radius(i);
        triangles(counter).B_x = cameraShot.PosX(sortedIndices(2,i));
        triangles(counter).B_y = cameraShot.PosY(sortedIndices(2,i));
        triangles(counter).B_radius = cameraShot.Radius(sortedIndices(2,i));
        triangles(counter).C_x = cameraShot.PosX(sortedIndices(3,i));
        triangles(counter).C_y = cameraShot.PosY(sortedIndices(3,i));
        triangles(counter).C_radius = cameraShot.Radius(sortedIndices(3,i));
        triangles(counter).a = sqrt((triangles(counter).B_x - triangles(counter).C_x)^2 + (triangles(counter).B_y - triangles(counter).C_y)^2);
        triangles(counter).b = sqrt((triangles(counter).A_x - triangles(counter).C_x)^2 + (triangles(counter).A_y - triangles(counter).C_y)^2);
        triangles(counter).c = sqrt((triangles(counter).B_x - triangles(counter).A_x)^2 + (triangles(counter).B_y - triangles(counter).A_y)^2);

        A = [triangles(counter).A_x, triangles(counter).A_y];
        B = [triangles(counter).B_x, triangles(counter).B_y];
        C = [triangles(counter).C_x, triangles(counter).C_y];

        AB = B - A;
        BC = C - B;
        CA = A - C;

        dotProductAlpha = dot(AB, -CA);
        dotProductBeta = dot(-AB, BC);
        dotProductGamma = dot(-BC, CA);
        magAB = norm(AB);
        magBC = norm(BC);
        magCA = norm(CA);

        triangles(counter).alpha = rad2deg(acos(dotProductAlpha/(magAB*magCA)));
        triangles(counter).beta = rad2deg(acos(dotProductBeta/(magAB*magBC)));
        triangles(counter).gamma = rad2deg(acos(dotProductGamma/(magBC*magCA)));

        counter = counter+1;
    end
    % hold off;
    writetable(struct2table(triangles), "Triangles_CameraShot.csv");
end