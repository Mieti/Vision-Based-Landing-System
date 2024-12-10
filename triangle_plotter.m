% Load the CSV file
data = readmatrix('Triangles_CameraShot.csv'); 
data2 = readmatrix('Triangles_with_angles.csv');
% Extract coordinates
xA = data(:, 1); yA = data(:, 2);
xB = data(:, 4); yB = data(:, 5);
xC = data(:, 7); yC = data(:, 8);

xA2 = data2(:, 1); yA2 = data2(:, 2);
xB2 = data2(:, 4); yB2 = data2(:, 5);
xC2 = data2(:, 7); yC2 = data2(:, 8);

% Number of triangles
numTriangles = size(data, 1);
numTriangles2 = size(data2, 1);

% Plot triangles
figure(1);
hold on; % Retain plots for multiple triangles
axis equal; % Equal scaling for x and y axes
title('Triangles from Camera Shot');
xlabel('X'); ylabel('Y');

for i = 1:numTriangles
    % Get vertices of the current triangle
    xCoords = [xA(i), xB(i), xC(i), xA(i)]; % Close the triangle
    yCoords = [yA(i), yB(i), yC(i), yA(i)];
    
    % Plot the triangle
    plot(xCoords, yCoords, '-o', 'LineWidth', 1);
end
hold off;


figure(2);
hold on; % Retain plots for multiple triangles
axis equal; % Equal scaling for x and y axes
title('Triangles from Complete Crater Map');
xlabel('X'); ylabel('Y');

for i = 1:numTriangles2
    % Get vertices of the current triangle
    xCoords2 = [xA2(i), xB2(i), xC2(i), xA2(i)]; % Close the triangle
    yCoords2 = [yA2(i), yB2(i), yC2(i), yA2(i)];
    
    % Plot the triangle
    plot(xCoords2, yCoords2, '-o', 'LineWidth', 1);
end
hold off;