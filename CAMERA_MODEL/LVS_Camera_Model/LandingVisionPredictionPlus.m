function [sys,x0,str,ts] = LandingVisionPredictionPlus(t, x, u, flag, Tl, r_CB, q_CB, w, h, actualf, n_points)
    % Dispatch the flag. The switch function controls the calls to
    % S-function routines at each simulation stage.
    switch flag

        %%%%%%%%%%%%%%%%%%
        % Initialization %
        %%%%%%%%%%%%%%%%%%
    case 0
        [sys,x0,str,ts]=mdlInitializeSizes(Tl);

        %%%%%%%%%%%
        % Outputs %
        %%%%%%%%%%%
    case 3
        sys=mdlOutputs(t, x, u, Tl, r_CB, q_CB, w, h, actualf, n_points);   


        %%%%%%%%%%%%
        % Not used %
        %%%%%%%%%%%%
    case { 1, 2, 4, 9 }
        sys=[];

        %%%%%%%%%%%%%%%%%%%%
        % Unexpected flags %
        %%%%%%%%%%%%%%%%%%%%
    otherwise
        error(['Unhandled flag = ',num2str(flag)]);

    end
end

%=============================================================================
% mdlInitializeSizes
% Return the sizes, initial conditions, and sample times for the S-function.
%=============================================================================
function [sys,x0,str,ts]=mdlInitializeSizes(Tl)

    sizes = simsizes;

    sizes.NumContStates  = 0;
    sizes.NumDiscStates  = 0;
    sizes.NumOutputs     = 501;
    sizes.NumInputs      = 1009;
    sizes.DirFeedthrough = 1;
    sizes.NumSampleTimes = 1;   % at least one sample time is needed

    sys = simsizes(sizes);

    % initialize the initial conditions
    x0  = [];

    % str is always an empty matrix
    str = [];

    % initialize the array of sample times
    ts  = [Tl 0];

end

%=============================================================================
% mdlOutputs
% Return the block outputs.
%=============================================================================
function sys=mdlOutputs(t, x, u, Tl, r_CB, q_CB, w, h, actualf, n_points)

    % Input and output are in the inertial reference frame
    time = t;
    max_landmark=100;

    for i=1:max_landmark*5+1
       sys(i) = 0; 
    end

    %%INPUT
    %q_BM_est = reshape(u(1:4), [1, 4]);
    q_BM_est = u(1:4);
    r_BM_est = u(5:7);
    landmarks_cam = u(8:1008);
    num_landmarks = u(1009);
    
    q_CB = reshape(q_CB, [1, 4]);
    a = 34.5; %aperture view angle of the camera
    
    
    %%fprintf("-------CAMERA MODEL-----------\n");
    %LVS (pinhole model)
    [W, CC, C_pinhole, ~] = pinhole1(w, h, actualf, a, r_BM_est', q_BM_est, r_CB, q_CB);
    
    for i=1:num_landmarks
        cam_point1 =[landmarks_cam((i-1)*2+1), landmarks_cam((i-1)*2+2), 0];
        cam_point2 =[landmarks_cam((i-1)*8+202),landmarks_cam((i-1)*8+203), 0];
        cam_point3= [landmarks_cam((i-1)*8+204),landmarks_cam((i-1)*8+205), 0];  
        cam_point4= [landmarks_cam((i-1)*8+206),landmarks_cam((i-1)*8+207), 0];    
        cam_point5= [landmarks_cam((i-1)*8+208),landmarks_cam((i-1)*8+209), 0];   
       
 %       k = quatrotate(q_multiplication(q_BM_est, q_CB)', cam_point)' + CC;
        qp=q_multiplication(q_BM_est, q_CB)';
        Matqp = [qp(1)^2-qp(2)^2-qp(3)^2+qp(4)^2   2*(qp(1)*qp(2)+qp(3)*qp(4))          2*(qp(1)*qp(3)-qp(2)*qp(4));...
        2*(qp(1)*qp(2)-qp(3)*qp(4))      -qp(1)^2+qp(2)^2-qp(3)^2+qp(4)^2      2*(qp(2)*qp(3)+qp(1)*qp(4));...
        2*(qp(1)*qp(3)+qp(2)*qp(4))      2*(qp(2)*qp(3)-qp(1)*qp(4))      -qp(1)^2-qp(2)^2+qp(3)^2+qp(4)^2];  
    
        k1=transpose(Matqp)*cam_point1'+CC;
        k2=transpose(Matqp)*cam_point2'+CC;
        k3=transpose(Matqp)*cam_point3'+CC;
        k4=transpose(Matqp)*cam_point4'+CC;
        k5=transpose(Matqp)*cam_point5'+CC;
                
        k1 = ground_intersect(k1', W); 
        k2 = ground_intersect(k2', W); 
        k3 = ground_intersect(k3', W);
        k4 = ground_intersect(k4', W);
        k5 = ground_intersect(k5', W);
        
        % Create matrix for solution of homogeneous system
        BB(1,1) = k1(1)^2;
        BB(1,2) = 2 * k1(1) * k1(2);
        BB(1,3) = k1(2)^2;
        BB(1,4) = 2 * k1(1);
        BB(1,5) = 2 * k1(2);
        BB(1,6) = 1;
        
        BB(2,1) = k2(1)^2;
        BB(2,2) = 2 * k2(1) * k2(2);
        BB(2,3) = k2(2)^2;
        BB(2,4) = 2 * k2(1);
        BB(2,5) = 2 * k2(2);
        BB(2,6) = 1;
        
        BB(3,1) = k3(1)^2;
        BB(3,2) = 2 * k3(1) * k3(2);
        BB(3,3) = k3(2)^2;
        BB(3,4) = 2 * k3(1);
        BB(3,5) = 2 * k3(2);
        BB(3,6) = 1;
        
        BB(4,1) = k4(1)^2;
        BB(4,2) = 2 * k4(1) * k4(2);
        BB(4,3) = k4(2)^2;
        BB(4,4) = 2 * k4(1);
        BB(4,5) = 2 * k4(2);
        BB(4,6) = 1;
        
        BB(5,1) = k5(1)^2;
        BB(5,2) = 2 * k5(1) * k5(2);
        BB(5,3) = k5(2)^2;
        BB(5,4) = 2 * k5(1);
        BB(5,5) = 2 * k5(2);
        BB(5,6) = 1;
                        
        BB(6,6) = 1;
        
        % Obtained non-null solution k values from system BB k = 0
        %k = null(BB);
        
        Sol2 = (BB)\[zeros(5,1); 1];
        
        
        % Compute parameters of the ellipse
        %            A = k2(1);
        %            B = k2(2);
        %            C = k2(3);
        %            D = k2(4);
        %            F = k2(5);
        %            G = k2(6);
        A = Sol2(1);
        B = 2*Sol2(2);
        C = Sol2(3);
        D = 2*Sol2(4);
        E = 2*Sol2(5);
        F = Sol2(6);
           
%            % Center of the ellipse
%             ellipse_center(1,found_landmark) = (C * D - B * F) / (B^2 - A * C);
%             ellipse_center(2,found_landmark) = (A * F - B * D) / (B^2 - A * C);
           ellipse_center((i-1)*2+1) = (2 * C * D - B * E) / (B^2 - 4 * A * C);
           ellipse_center((i-1)*2+2) = (2 * A * E - B * D) / (B^2 - 4 * A * C);  
%            ellipse_center(1,found_landmark) = -ellipse_center(1,found_landmark)+w/2;
%            ellipse_center(2,found_landmark) = -ellipse_center(2,found_landmark)+h/2;
           
           % Semi-minor and major axis
%            arg=2*(A*F^2 + C*D^2 + G*B^2 - 2*B*D*F - A*C*G) / ...
%                (B^2-A*C)*(sqrt((A-C)^2+4*B^2)-(A+C));
%            if (arg>=0)
%                halfaxisa(found_landmark) = sqrt(arg);
%            else
%                halfaxisa(found_landmark) = 0;
%            end
%            
%            arg=2*(A*F^2 + C*D^2 + G*B^2 - 2*B*D*F - A*C*G) / ...
%                (B^2-A*C)*(-sqrt((A-C)^2+4*B^2)-(A+C));
%            if (arg>=0)
%                halfaxisb(found_landmark) = sqrt(arg);
%            else
%                halfaxisb(found_landmark) = 0;
%            end
            halfaxisa = - sqrt(2 * (A * E^2 + C * D^2 - B * D * E + (B^2 - 4 * A * C)*F ) * ...
    ((A + C) + sqrt( (A -C)^2 + B^2) )) / (B^2 - 4 * A * C);
            halfaxisb = - sqrt(2 * (A * E^2 + C * D^2 - B * D * E + (B^2 - 4 * A * C)*F ) * ...
    ((A + C) - sqrt( (A -C)^2 + B^2) )) / (B^2 - 4 * A * C);

            landmarks_ground_radius((i-1)*3+202) = sqrt(halfaxisa*halfaxisb); 
            landmarks_ground_radius((i-1)*3+203) = -1; 
            landmarks_ground_radius((i-1)*3+204) = -1; 
            
            % Rotation angle          
%            if (A<C)
%                if (B==0)
%                   theta(found_landmark) = 0;
%                else
%                   theta(found_landmark) = (1/2)*acot((A-C)/(2*B));
%                end
%            else
%                if (B==0)
%                   theta(found_landmark) = pi/2;
%                else
%                   theta(found_landmark) = pi/2+(1/2)*acot((A-C)/(2*B));
%                end
%            end
%            if abs(B) > 1e-6
%              theta(found_landmark) = atan(1 / B * (C - A - sqrt((A - C )^2 + B^2)) );
%            elseif abs(B) < 1e-6 && A < C
%              theta(found_landmark) = 0;
%            elseif abs(B) < 1e-6 && A >= C
%              theta(found_landmark) = pi/2;
%            end
         
%         landmarks_ground(1, i) = k(1);
%         landmarks_ground(2, i) = k(2);
        
%         landmarks_ground_area1 = sqrt((k1(1)-k3(1))^2+(k1(2)-k3(2))^2)*sqrt((k2(1)-k4(1))^2+(k2(2)-k4(2))^2)/4;

    
        % Computation of Area in the case of othogonal direction
%         cam_point1= [landmarks_cam((i-1)*2+1)+landmarks_cam(201+(i-1)*3+1)*cos(landmarks_cam(201+(i-1)*3+3)), landmarks_cam((i-1)*2+2)+landmarks_cam(201+(i-1)*3+1)*sin(landmarks_cam(201+(i-1)*3+3)), 0];
%         cam_point2= [landmarks_cam((i-1)*2+1)+landmarks_cam(201+(i-1)*3+2)*cos(landmarks_cam(201+(i-1)*3+3)), landmarks_cam((i-1)*2+2)-landmarks_cam(201+(i-1)*3+2)*sin(landmarks_cam(201+(i-1)*3+3)), 0];  
%         cam_point3= [landmarks_cam((i-1)*2+1)-landmarks_cam(201+(i-1)*3+1)*cos(landmarks_cam(201+(i-1)*3+3)), landmarks_cam((i-1)*2+2)-landmarks_cam(201+(i-1)*3+1)*sin(landmarks_cam(201+(i-1)*3+3)), 0];  
%         cam_point4= [landmarks_cam((i-1)*2+1)-landmarks_cam(201+(i-1)*3+2)*cos(landmarks_cam(201+(i-1)*3+3)), landmarks_cam((i-1)*2+2)+landmarks_cam(201+(i-1)*3+2)*sin(landmarks_cam(201+(i-1)*3+3)), 0];         
% 
%         %       k = quatrotate(q_multiplication(q_BM_est, q_CB)', cam_point)' + CC;
%         k1=transpose(Matqp)*cam_point1'+CC;
%         k2=transpose(Matqp)*cam_point2'+CC;
%         k3=transpose(Matqp)*cam_point3'+CC;
%         k4=transpose(Matqp)*cam_point4'+CC;
%         
%         k1 = ground_intersect(k1', W); 
%         k2 = ground_intersect(k2', W);
%         k3 = ground_intersect(k3', W);
%         k4 = ground_intersect(k4', W);      
%         
%         landmarks_ground_area2 = sqrt((k1(1)-k3(1))^2+(k1(2)-k3(2))^2)*sqrt((k2(1)-k4(1))^2+(k2(2)-k4(2))^2)/4;
%         landmarks_ground_area(i) = landmarks_ground_area1*(cos(landmarks_cam(201+(i-1)*3+3)))^2+landmarks_ground_area2*(sin(landmarks_cam(201+(i-1)*3+3)))^2;
    
    end

    % OUTPUTS
    for i=1:num_landmarks*2
        sys(i) = ellipse_center(i);
    end
    sys(201)=num_landmarks;
    for i=202:201+num_landmarks*3
        sys(i) = landmarks_ground_radius(i);
    end
end

