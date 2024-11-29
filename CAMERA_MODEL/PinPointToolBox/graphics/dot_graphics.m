function [x,y, z] = dot(W)
%
    R = 10;
    [x,y,z] = sphere;
    x = x*R +W(1);
    y = y*R +W(2);
    z = z*R +W(3);
end