function [e] = ellipse_graphics(data, count, num_points, w, h)
    e = zeros(num_points+1, 3);
    
    for i=1:count
        for j=1:num_points
            min = 1 + (j-1)*3;
            e(j,:) = data(min:min+2, i);
        end
        e(num_points+1,:) = data(1:3, i);

        plot3(e(:,1), e(:,2), e(:,3));
    end

end

