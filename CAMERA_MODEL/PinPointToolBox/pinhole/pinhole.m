function [W, CC, C_pinhole, G] = pinhole(w, h, f, a, r_MB_M, q_MB, r_BC_B, q_BC)
    q_MB = [q_MB(4), q_MB(1), q_MB(2), q_MB(3)];
    q_BC = [q_BC(4), q_BC(1), q_BC(2), q_BC(3)];
%PINHOLE function
%   W : pinhole center
%   CC : camera sensor center
%   C_pinhole : camera sensor 4 edges
%   G : camera sensor 4 edges projected on the ground
%
%   Camera specifications:
%   w: camera sensor width
%   h: camera sensor height
%   f: camera focal distance (camera sensor to pinhole center point)
%   
%   r_MB_M : coordinate of Body ref.Frame wrt origin of Mars ref.Frame, expressed
%   in Mars ref.Frame coordinates
%   r_BC_B : coordinate of Camera Frame wrt origin of Body ref.Frame,
%   expressed in Body ref.Frame coordinates
%   q_MB, A_MB : orientation of Body ref.Frame wrt Mars ref.Frame
%   q_BC, A_BC : orientataion of Camera ref.Frame wrt Body ref.Frame
%
%   quaternions are expressed in the scalar last convention (quat2dcm,
%   q_multiplication and other functions are adapted to this convention)
%
%   Rotation matrices have direct cosine vectors in columns (not in rows)
%   to comply with the robotics convention for rotation matrices.
%
    A_MB = quat2dcm(q_MB)';
    A_BC = quat2dcm(q_BC)';
    A_MC = A_MB*A_BC;

    % Pinhole Point
    r_BC_M = A_MB*r_BC_B;
    W = r_BC_M + r_MB_M;
    
    % Camers lens center point (CC)
    CC = A_MC*[0; 0; f] + W;
    
    % Square C = [c1, c2, c3, c4, c1] of camera lens
    C = shape_rectangle_vertex(w, h, A_MC);
    C_pinhole = C + CC';
    
    % Square on ground
    g1 = intersect_point(W, C_pinhole(1, :));
    g2 = intersect_point(W, C_pinhole(2, :));
    g3 = intersect_point(W, C_pinhole(3, :));
    g4 = intersect_point(W, C_pinhole(4, :));
    G = [g1'; g2'; g3'; g4'; g1'];

    W = W';
    CC = CC';
end