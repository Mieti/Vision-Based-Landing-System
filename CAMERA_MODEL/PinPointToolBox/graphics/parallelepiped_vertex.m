function [P] = parallelepiped_vertex(S, Or)
    A = [-S(1)/2, -S(2)/2, -S(3)/2];
    B = [S(1)/2, -S(2)/2, -S(3)/2];
    C = [-S(1)/2, S(2)/2, -S(3)/2];
    D = [-S(1)/2, -S(2)/2, S(3)/2];
    E = [-S(1)/2, S(2)/2, S(3)/2];
    F = [S(1)/2, -S(2)/2, S(3)/2];
    G = [S(1)/2, S(2)/2, -S(3)/2];
    H = [S(1)/2, S(2)/2, S(3)/2];
    P_init = [A;B;F;H;G;C;A;D;E;H;F;D;E;C;G;B];
    P = quatrotate(Or, P_init);
end