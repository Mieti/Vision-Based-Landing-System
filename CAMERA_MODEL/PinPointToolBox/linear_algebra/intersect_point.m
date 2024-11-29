function [p] = intersect_point(A, B)
    % direction ratios
    l = A(1) - B(1);
    m = A(2) - B(2);
    n = A(3) - B(3);

    y = -B(3)*m/n + B(2);
    x = l*(y-B(2))/m + B(1);

    p = [x; y; 0];
end