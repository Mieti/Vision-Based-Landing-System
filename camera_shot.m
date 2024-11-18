function camera_shot(x, y)
    % figure(1)
    craterList = readtable("CraterMap" + ".csv");
    upper_right_x = x+4000;
    upper_right_y = y+4000; 
    lower_left_x = x;
    lower_left_y = y;
    CraterCounter=0;
    Headers = {'PosX', 'PosY', 'Diameter', 'Age'};
    rowCounter = 1;
    t = table('Size', [0, length(Headers)], 'VariableTypes', {'double', 'double', 'double', 'double'}, 'VariableNames', Headers);
    
    for i=1:length(craterList.PosX)
           xc(i) = craterList.PosX(i);
           yc(i) = craterList.PosY(i);
           r(i) = craterList.Diameter(i);
           theta = linspace(0,2*pi);
           if xc(i) > lower_left_x && xc(i) < upper_right_x && yc(i) > lower_left_y && yc(i) < upper_right_y
               CraterCounter=CraterCounter+1;
               newRow = table(xc(i), yc(i), r(i), craterList.Age(i), 'VariableNames', Headers);
               t = [t; newRow];
               %t.PosX(rowCounter) = craterList.PosX(i);
               %t.PosX(rowCounter) = craterList.PosY(i);
               %t.Diameter(rowCounter) = craterList.Diameter(i);
               %t.Age(rowCounter) = craterList.Age(i);
               % x = r(i)*cos(theta) + xc(i);
               % y = r(i)*sin(theta) + yc(i);
               % plot(x,y);
               % hold on;  
               rowCounter = rowCounter + 1;
           end
    end
    % disp(CraterCounter);
    % title('Camera Shot craters');
    % xlabel('x[m]');
    % ylabel('y[m]');
    
    writetable(t, 'CameraShot.csv');
end