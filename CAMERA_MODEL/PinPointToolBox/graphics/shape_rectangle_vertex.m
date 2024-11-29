function [C] = shape_rectangle_vertex(w, h, M)
%     C = quatrotate(q, [-w/2, -h/2, 0;
%         w/2, -h/2, 0;
%         w/2, h/2, 0;
%         -w/2, h/2, 0;
%         -w/2, -h/2, 0;
%     ]);
    
    C(1, :) = M*[-w/2, -h/2, 0]';
    C(2, :) = M*[w/2, -h/2, 0]';
    C(3, :) = M*[w/2, h/2, 0]';
    C(4, :) = M*[-w/2, h/2, 0]';
    C(5, :) = M*[-w/2, -h/2, 0]';
end