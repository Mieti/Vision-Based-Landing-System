function [W, CC, C_pinhole, G] = pinhole1(w, h, f, a, B, q, r_CB, q_CB)
%PINHOLE function, able to retrieve the ground vertexes of the camera edges

    % Pinhole Point
    Matq=[q(1)^2-q(2)^2-q(3)^2+q(4)^2   2*(q(1)*q(2)+q(3)*q(4))          2*(q(1)*q(3)-q(2)*q(4));...
          2*(q(1)*q(2)-q(3)*q(4))      -q(1)^2+q(2)^2-q(3)^2+q(4)^2      2*(q(2)*q(3)+q(1)*q(4));...
          2*(q(1)*q(3)+q(2)*q(4))       2*(q(2)*q(3)-q(1)*q(4))      -q(1)^2-q(2)^2+q(3)^2+q(4)^2];
    Matq_CB=[q_CB(1)^2-q_CB(2)^2-q_CB(3)^2+q_CB(4)^2   2*(q_CB(1)*q_CB(2)+q_CB(3)*q_CB(4))          2*(q_CB(1)*q_CB(3)-q_CB(2)*q_CB(4));...
          2*(q_CB(1)*q_CB(2)-q_CB(3)*q_CB(4))      -q_CB(1)^2+q_CB(2)^2-q_CB(3)^2+q_CB(4)^2      2*(q_CB(2)*q_CB(3)+q_CB(1)*q_CB(4));...
          2*(q_CB(1)*q_CB(3)+q_CB(2)*q_CB(4))       2*(q_CB(2)*q_CB(3)-q_CB(1)*q_CB(4))      -q_CB(1)^2-q_CB(2)^2+q_CB(3)^2+q_CB(4)^2];
    
    % Distance from camera to body transformed in Mars axes
    Aux1=Matq'*r_CB;
    % In Mars axes camera to body distance is summed to the estimated
    % altitude of CoG
    W= Aux1' + B;
    % Lens coordinates are in camera frame.  They must be transformed in body
    % frane and then in ground frame before being summed
    Aux3=[0; 0; f];
    CC=(Matq'*Matq_CB'*Aux3)' + W;
    % Matrix from Ground Ref Frame to Camera Ref Frame
    qtot= q_multiplication(q,q_CB);
    % Square C = [c1, c2, c3, c4, c1] of camera lens
    C = shape_rectangle_vertex1(w, h, qtot);
    C_pinhole = C + CC;

    % Square on ground
    g1 = intersect(W', C_pinhole(1, :));
    g2 = intersect(W', C_pinhole(2, :));
    g3 = intersect(W', C_pinhole(3, :));
    g4 = intersect(W', C_pinhole(4, :));
    G = [g1'; g2'; g3'; g4'; g1']; 
    
    CC = CC';
end