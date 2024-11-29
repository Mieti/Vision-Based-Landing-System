function [res] = is_inside_camera_lens(P, V)
    res = false;
    
    P = P';
    V1 = V(1,:);
    V2 = V(2,:);
    V3 = V(3,:);
    V4 = V(4,:);
    
    % Compare angles of P with camera lens vertices
    theta_tot = 0.0;
    
    X = V1 - P;
    X = X / norm(X, 2);
    Y = V2 - P;
    Y = Y / norm(Y, 2);
    d = dot(X, Y);
    theta = acos(d);
    theta_tot = theta_tot + theta;
    
    X = V2 - P;
    X = X / norm(X, 2);
    Y = V3 - P;
    Y = Y / norm(Y, 2);
    d = dot(X, Y);
    theta = acos(d);
    theta_tot = theta_tot + theta;
    
    X = V3 - P;
    X = X / norm(X, 2);
    Y = V4 - P;
    Y = Y / norm(Y, 2);
    d = dot(X, Y);
    theta = acos(d);
    theta_tot = theta_tot + theta;
    
    X = V4 - P;
    X = X / norm(X, 2);
    Y = V1 - P;
    Y = Y / norm(Y, 2);
    d = dot(X, Y);
    theta = acos(d);
    theta_tot = theta_tot + theta;
    
    eta = 0.1;
    if abs(theta_tot - 2*pi) < eta 
        res = true;
    end

end

