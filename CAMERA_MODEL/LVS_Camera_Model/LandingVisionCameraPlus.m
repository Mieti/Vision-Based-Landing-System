function [sys,x0,str,ts] = LandingVisionCameraPlus(t, x, u, flag, Tl, Cat, r_CB, q_CB, w, h, actualf, n_points)
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
        sys=mdlOutputs(t, x, u, Tl, Cat, r_CB, q_CB, w, h, actualf, n_points);   


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
    sizes.NumOutputs     = 1001;
    sizes.NumInputs      = 7;
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
function sys=mdlOutputs(t, x, u, Tl, Cat, r_CB, q_CB, w, h, actualf, n_points)

    % Input and output are in the inertial reference frame

    time = t;
    max_landmark=100;
    max_handled_landmark=100;
    eps=0.001;  % tolerance for landmark detection in the camera area

    found_landmark=0;
    for i=1:max_landmark*10+1
       sys(i) = 0; 
    end

    %%INPUT
    %q_BM = reshape(u(1:4), [1, 4]);
    q_BM = u(1:4);
    r_BM = u(5:7);
    %q_CB = reshape(q_CB, [1, 4]);
    %a = 34.5;
    a=atand(w/(2*actualf));
    
    %%fprintf("-------CAMERA MODEL-----------\n");
    %LVS (pinhole model)
    [W, CC, C_pinhole, ~] = pinhole1(w, h, actualf, a, r_BM', q_BM, r_CB, q_CB);

    %Data
    camera_center_landmarks = zeros(3, Cat.num_landmarks);
    
    % Threshold for camera model landmark identification
 %   cat_threshold = 50;
    p_iP = zeros(2*n_points,1);   
    
    %For all landmarks
    for j=1:Cat.num_landmarks
        A = [Cat.clandmarkX(j); Cat.clandmarkY(j); Cat.clandmarkZ(j)];
        RADIUS=Cat.rlandmark(j);
        NORMAL=[Cat.nlandmarkX(j); Cat.nlandmarkY(j); Cat.nlandmarkZ(j)];
        
        
        %Landmark center projection in camera
        [k1, k] = camera_projection1(A', W, C_pinhole, CC, r_BM, q_BM, q_CB);
    
        %Criterion of angles to decide if a landmark is seen of not.  If landmark is internal the sum of angles is 2*pi    
        if (is_inside_camera_lens(k1', C_pinhole) && (found_landmark < max_handled_landmark))
            found_landmark = found_landmark + 1;
            
            camera_center_landmarks(:, found_landmark) = k';
           
           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
           % Computation of ellipse terms for each landmark
           
           % Cartesian unit vectors
           e1 = [1;0;0];
           e2 = [0;1;0];
           e3 = [0;0;1];
           
           p_iM = zeros(3,n_points);
           p_iC = zeros(3,1);

%           BB = zeros(6,6);
           
           % For each landmark, supplementary information are derived on the area of
           % the landmark (semiaxes) and orientation in space of the ellipse (theta angle)
           
           Mat_CB = [q_CB(1)^2-q_CB(2)^2-q_CB(3)^2+q_CB(4)^2   2*(q_CB(1)*q_CB(2)+q_CB(3)*q_CB(4))          2*(q_CB(1)*q_CB(3)-q_CB(2)*q_CB(4));...
           2*(q_CB(1)*q_CB(2)-q_CB(3)*q_CB(4))      -q_CB(1)^2+q_CB(2)^2-q_CB(3)^2+q_CB(4)^2      2*(q_CB(2)*q_CB(3)+q_CB(1)*q_CB(4));...
           2*(q_CB(1)*q_CB(3)+q_CB(2)*q_CB(4))      2*(q_CB(2)*q_CB(3)-q_CB(1)*q_CB(4))      -q_CB(1)^2-q_CB(2)^2+q_CB(3)^2+q_CB(4)^2];

           Matq = [q_BM(1)^2-q_BM(2)^2-q_BM(3)^2+q_BM(4)^2   2*(q_BM(1)*q_BM(2)+q_BM(3)*q_BM(4))          2*(q_BM(1)*q_BM(3)-q_BM(2)*q_BM(4));...
           2*(q_BM(1)*q_BM(2)-q_BM(3)*q_BM(4))      -q_BM(1)^2+q_BM(2)^2-q_BM(3)^2+q_BM(4)^2      2*(q_BM(2)*q_BM(3)+q_BM(1)*q_BM(4));...
           2*(q_BM(1)*q_BM(3)+q_BM(2)*q_BM(4))      2*(q_BM(2)*q_BM(3)-q_BM(1)*q_BM(4))      -q_BM(1)^2-q_BM(2)^2+q_BM(3)^2+q_BM(4)^2];

       
           % % Five points on the rim circle, in Planet Ref Frame
           p_iM = points_on_rim(A, NORMAL, RADIUS, n_points);
           
           for i = 1 : n_points
               
               % Vectors of the five landmark Points w.r.t. the Camera in the Cam Ref Fr
               p_iC(1:3,i) = Mat_CB*Matq * (p_iM(1:3,i) - r_BM) - Mat_CB * r_CB;
               
               % Landmark Points in the pinhole Camera model
               %p_iP(1:2,i) = [h/2; w/2] - actualf / ( dot(e3, p_iC(1:3,i)) ) * [e2';e1'] * p_iC(1:3,i);
               if (i==1)
                 % p_iP((found_landmark-1)*4+2*i-1) = w/2 - actualf / ( dot(e3, p_iC(1:3,i)) ) * e1' * p_iC(1:3,i);
                 % p_iP((found_landmark-1)*4+2*i) = h/2 - actualf / ( dot(e3, p_iC(1:3,i)) ) * e2' * p_iC(1:3,i);
                  p_iP((found_landmark-1)*2+2*i-1) = actualf / ( dot(e3, p_iC(1:3,i)) ) * e1' * p_iC(1:3,i);
                  p_iP((found_landmark-1)*2+2*i) = actualf / ( dot(e3, p_iC(1:3,i)) ) * e2' * p_iC(1:3,i);
               else   
                 % p_iP((found_landmark-1)*6+201+2*(i-2)-1) = w/2 - actualf / ( dot(e3, p_iC(1:3,i)) ) * e1' * p_iC(1:3,i);
                 % p_iP((found_landmark-1)*6+201+2*(i-2)) = h/2 - actualf / ( dot(e3, p_iC(1:3,i)) ) * e2' * p_iC(1:3,i);
                  p_iP((found_landmark-1)*8+201+2*(i-1)-1) = actualf / ( dot(e3, p_iC(1:3,i)) ) * e1' * p_iC(1:3,i);
                  p_iP((found_landmark-1)*8+201+2*(i-1)) = actualf / ( dot(e3, p_iC(1:3,i)) ) * e2' * p_iC(1:3,i);
               end 
            end                  
% %                % Create matrix for solution of homogeneous system
% %                BB(i,1) = p_iP(1,i)^2;
% %                BB(i,2) = 2 * p_iP(1,i) * p_iP(2,i);
% %                BB(i,3) = p_iP(2,i)^2;
% %                BB(i,4) = 2 * p_iP(1,i);
% %                BB(i,5) = 2 * p_iP(2,i);
% %                BB(i,6) = 1;
% %                

           
               
%            
%             BB(6,6) = 1;
%            
%            % Obtained non-null solution k values from system BB k = 0
%            %k = null(BB);
%            
%             k2 = (BB)\[zeros(n_points,1); 1];
% 
%            
%            % Compute parameters of the ellipse
% %            A = k2(1);
% %            B = k2(2);
% %            C = k2(3);
% %            D = k2(4);
% %            F = k2(5);
% %            G = k2(6);
%            A = k2(1);
%            B = 2*k2(2);
%            C = k2(3);
%            D = 2*k2(4);
%            E = 2*k2(5);
%            F = k2(6);
%            
% %            % Center of the ellipse
% %             ellipse_center(1,found_landmark) = (C * D - B * F) / (B^2 - A * C);
% %             ellipse_center(2,found_landmark) = (A * F - B * D) / (B^2 - A * C);
%            ellipse_center(1,found_landmark) = (2 * C * D - B * E) / (B^2 - 4 * A * C);
%            ellipse_center(2,found_landmark) = (2 * A * E - B * D) / (B^2 - 4 * A * C);  
%            ellipse_center(1,found_landmark) = -ellipse_center(1,found_landmark)+w/2;
%            ellipse_center(2,found_landmark) = -ellipse_center(2,found_landmark)+h/2;
%            
%            % Semi-minor and major axis
% %            arg=2*(A*F^2 + C*D^2 + G*B^2 - 2*B*D*F - A*C*G) / ...
% %                (B^2-A*C)*(sqrt((A-C)^2+4*B^2)-(A+C));
% %            if (arg>=0)
% %                halfaxisa(found_landmark) = sqrt(arg);
% %            else
% %                halfaxisa(found_landmark) = 0;
% %            end
% %            
% %            arg=2*(A*F^2 + C*D^2 + G*B^2 - 2*B*D*F - A*C*G) / ...
% %                (B^2-A*C)*(-sqrt((A-C)^2+4*B^2)-(A+C));
% %            if (arg>=0)
% %                halfaxisb(found_landmark) = sqrt(arg);
% %            else
% %                halfaxisb(found_landmark) = 0;
% %            end
%             halfaxisa(found_landmark) = - sqrt(2 * (A * E^2 + C * D^2 - B * D * E + (B^2 - 4 * A * C)*F ) * ...
%     ((A + C) + sqrt( (A -C)^2 + B^2) )) / (B^2 - 4 * A * C);
%             halfaxisb(found_landmark) = - sqrt(2 * (A * E^2 + C * D^2 - B * D * E + (B^2 - 4 * A * C)*F ) * ...
%     ((A + C) - sqrt( (A -C)^2 + B^2) )) / (B^2 - 4 * A * C);
% 
%             % Rotation angle          
% %            if (A<C)
% %                if (B==0)
% %                   theta(found_landmark) = 0;
% %                else
% %                   theta(found_landmark) = (1/2)*acot((A-C)/(2*B));
% %                end
% %            else
% %                if (B==0)
% %                   theta(found_landmark) = pi/2;
% %                else
% %                   theta(found_landmark) = pi/2+(1/2)*acot((A-C)/(2*B));
% %                end
% %            end
%            if abs(B) > 1e-6
%              theta(found_landmark) = atan(1 / B * (C - A - sqrt((A - C )^2 + B^2)) );
%            elseif abs(B) < 1e-6 && A < C
%              theta(found_landmark) = 0;
%            elseif abs(B) < 1e-6 && A >= C
%              theta(found_landmark) = pi/2;
%            end
% 
%            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%           

    % In output only the center of landmark.  Additional info expected useful for
    % initial geolocalisation
            
%             if found_landmark == max_handled_landmark
%                break; 
%             end
            
         end % if inside camera FoV
 
    end % closes the for on all landmarks

 

    %OUTPUT
    for i=1:found_landmark*2
        sys(i) = p_iP(i);
    end
    sys(201)=found_landmark;
    for i=202:201+found_landmark*8
        sys(i) = p_iP(i);
    end

end

