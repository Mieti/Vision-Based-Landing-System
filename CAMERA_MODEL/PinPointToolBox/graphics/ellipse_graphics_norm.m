function [e] = ellipse_graphics_norm(data, count, num_points, w, h)
    e = zeros(num_points+1, 3);
    
    for i=1:count
        for j=1:num_points
            min = 1 + (j-1)*3;
            e(j,:) = data(min:min+2, i);
        end
        e(num_points+1,:) = data(1:3, i);

        plot3(2*e(:,1)/w, 2*e(:,2)/h, e(:,3));
    end
end

