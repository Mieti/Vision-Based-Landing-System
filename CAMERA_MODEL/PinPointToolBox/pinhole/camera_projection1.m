function [k1, k] = camera_projection1(A, W, C_pinhole, CC, B, q, q_BC)
    k1 = zeros(length(A(:,1)), 3);
    k = zeros(length(A(:,1)), 3);
    
    for i = 1:length(A(:,1))
        k1(i,:) = camera_intersect1(A(i,:), W, C_pinhole);
        k2 = k1(i, :)' - CC;
        %k3 = quatrotate(quatinv(q_multiplication(q, q_BC)'), k2');
      
        qpi=q_multiplication(q, q_BC)';

Matqpi = [qpi(1)^2-qpi(2)^2-qpi(3)^2+qpi(4)^2   2*(qpi(1)*qpi(2)+qpi(3)*qpi(4))          2*(qpi(1)*qpi(3)-qpi(2)*qpi(4));...
        2*(qpi(1)*qpi(2)-qpi(3)*qpi(4))      -qpi(1)^2+qpi(2)^2-qpi(3)^2+qpi(4)^2      2*(qpi(2)*qpi(3)+qpi(1)*qpi(4));...
        2*(qpi(1)*qpi(3)+qpi(2)*qpi(4))      2*(qpi(2)*qpi(3)-qpi(1)*qpi(4))      -qpi(1)^2-qpi(2)^2+qpi(3)^2+qpi(4)^2];         
        k3=Matqpi*k2;
%        k = k3';
        k = k3;
        
%         k2 = k1(i,:)' - (CC - B);
%         k3 = quatrotate(quatinv(q_BC), (k2 - B)')' + B;
%         k(i,:) = quatrotate(q, (k3 - B)');
        %k = quatrotate(quatinv(q), quatrotate(quatinv(q_BC), (k-CC)')); 
    end
end

