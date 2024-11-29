function [k1, k] = camera_projection(A, W, C_pinhole, CC, r_MB_M, q_MB, q_BC)
    q_MB = [q_MB(4), q_MB(1), q_MB(2), q_MB(3)];
    q_BC = [q_BC(4), q_BC(1), q_BC(2), q_BC(3)];
%CAMERA PROJECTION function
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
%   With this convention r_0 = M_01 * r_1 (IT'S NOT r_0 = M_01' * r_1)
%
    A_MB = quat2dcm(q_MB)';
    A_BC = quat2dcm(q_BC)';
    A_MC = A_MB*A_BC;

    k1 = zeros(length(A(:,1)), 3);
    k = zeros(length(A(:,1)), 3);
    
    for i = 1:length(A(:,1))
        % landmark projection in the camera sensor wrt origin of Mars ref.Frame (expressed in Mars ref.Frame)
        k1(i,:) = camera_intersect(A(i,:), W, C_pinhole);
        % landmark projection in the camera sensor wrt center of Camera sensor (expressed in Mars ref.Frame)
        k2 = k1(i, :)' - CC';
        % landmark projection in the camera sensor wrt center of Camera sensor (expressed in Camera ref.Frame)
        k3 = A_MC'*k2;
        k(i,:) = k3'; 
    end
    
end

