function [p] = ground_intersect(A, B)
    p = zeros(length(A(:,1)), 3);
    
    for i=1:length(A(:,1))
        % Line passing through two points 
        x1 = A(i, 1);
        y1 = A(i, 2);
        z1 = A(i, 3);
        
        x2 = B(i, 1);
        y2 = B(i, 2);
        z2 = B(i, 3);

        % t calculation
        t = -z1/(z2-z1);

        x = x1 + t*(x2-x1);
        y = y1 + t*(y2-y1);
        z = 0;

        p(i,:) = [x y z]; 
    end
end

