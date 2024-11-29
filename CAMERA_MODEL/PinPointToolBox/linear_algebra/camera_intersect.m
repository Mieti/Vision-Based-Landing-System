function [p] = camera_intersect(A, B, Camera)
    p = zeros(length(A(:,1)), 3);
    
    for i=1:length(A(:,1))
       % Intersection with the camera lens plane
        P = Camera(1,:);
        Q = Camera(2,:);
        R = Camera(3,:);
        a = Q-P;
        b = R-P;
        cr = cross(a, b);
        % Plane parameters
        a = cr(1);
        b = cr(2);
        c = cr(3);
        d = -a*P(1)-b*P(2)-c*P(3);
        % Line passing through two points (direct ratios)
        l = B(1) - A(i,1); 
        m = B(2) - A(i,2);
        n = B(3) - A(i,3);
        r1 = A(i,1);
        r2 = A(i,2);
        r3 = A(i,3);

        % t calculation
        t = (-d-a*r1-b*r2-c*r3) / (a*l+b*m+c*n);

        x = r1 + t*l;
        y = r2 + t*m;
        z = r3 + t*n;

        p(i,:) = [x y z]; 
    end
end

