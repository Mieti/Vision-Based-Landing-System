function [C] = shape_rectangle_vertex1(w, h, q)

Matq = [q(1)^2-q(2)^2-q(3)^2+q(4)^2   2*(q(1)*q(2)+q(3)*q(4))          2*(q(1)*q(3)-q(2)*q(4));...
        2*(q(1)*q(2)-q(3)*q(4))      -q(1)^2+q(2)^2-q(3)^2+q(4)^2      2*(q(2)*q(3)+q(1)*q(4));...
        2*(q(1)*q(3)+q(2)*q(4))      2*(q(2)*q(3)-q(1)*q(4))      -q(1)^2-q(2)^2+q(3)^2+q(4)^2];
Aux1=[-w/2, -h/2, 0]';
Aux2=[ w/2, -h/2, 0]';
Aux3=[ w/2,  h/2, 0]';
Aux4=[-w/2,  h/2, 0]';
Aux5=[-w/2, -h/2, 0]';

C1=transpose(Matq)*Aux1;
C2=transpose(Matq)*Aux2;
C3=transpose(Matq)*Aux3;
C4=transpose(Matq)*Aux4;
C5=transpose(Matq)*Aux5;
%    C = quatrotate(q, [-w/2, -h/2, 0;
%        w/2, -h/2, 0;
%        w/2, h/2, 0;
%        -w/2, h/2, 0;
%        -w/2, -h/2, 0;
C=[C1'; C2'; C3'; C4'; C5'];
end