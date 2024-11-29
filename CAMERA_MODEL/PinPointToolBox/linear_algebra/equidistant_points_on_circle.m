function p = equidistant_points_on_circle(center, radius, number_points)
    p = zeros(number_points, 3);

    delta_angle = 2*pi/number_points;
    angle = 0;
    
    for i=1:number_points
       p(i,:) = (center + radius*[cos(angle); sin(angle); 0])';
       angle = angle + delta_angle;
    end
end

