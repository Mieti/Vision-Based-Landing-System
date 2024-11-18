function triangles = triangle_algorithm(fileName)
    % clc
    % clear all;
    % close all;
    
    cameraShot = readtable(fileName + ".csv");
    counter = 1;
    theta = linspace(0,2*pi);
    colors = lines(height(cameraShot)); % 'lines' colormap provides a set of visually distinct colors
    
    % figure(1);
    distances = zeros(height(cameraShot), height(cameraShot));
    
    for i=1:height(cameraShot)
        % x = cameraShot.Diameter(i)/2*cos(theta) + cameraShot.PosX(i);
        % y = cameraShot.Diameter(i)/2*sin(theta) + cameraShot.PosY(i);
        % plot(x,y);
        % hold on;
    end
    
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
        triangles(counter).A_diameter = cameraShot.Diameter(i);
        triangles(counter).B_x = cameraShot.PosX(sortedIndices(2,i));
        triangles(counter).B_y = cameraShot.PosY(sortedIndices(2,i));
        triangles(counter).B_diameter = cameraShot.Diameter(sortedIndices(2,i));
        triangles(counter).C_x = cameraShot.PosX(sortedIndices(3,i));
        triangles(counter).C_y = cameraShot.PosY(sortedIndices(3,i));
        triangles(counter).C_diameter = cameraShot.Diameter(sortedIndices(3,i));
        triangles(counter).a = sqrt((triangles(counter).B_x - triangles(counter).C_x)^2 + (triangles(counter).B_y - triangles(counter).C_y)^2);
        triangles(counter).b = sqrt((triangles(counter).A_x - triangles(counter).C_x)^2 + (triangles(counter).A_y - triangles(counter).C_y)^2);
        triangles(counter).c = sqrt((triangles(counter).B_x - triangles(counter).A_x)^2 + (triangles(counter).B_y - triangles(counter).A_y)^2);
    
        a_x = [triangles(counter).B_x, triangles(counter).C_x];
        a_y = [triangles(counter).B_y, triangles(counter).C_y];
        b_x = [triangles(counter).A_x, triangles(counter).C_x];
        b_y = [triangles(counter).A_y, triangles(counter).C_y];
        c_x = [triangles(counter).A_x, triangles(counter).B_x];
        c_y = [triangles(counter).A_y, triangles(counter).B_y];
    
        % plot(a_x, a_y, 'Color', colors(i,:));
        % plot(b_x, b_y, 'Color', colors(i,:));
        % plot(c_x, c_y, 'Color', colors(i,:));
    
        counter = counter+1;
    end
    % hold off;
end