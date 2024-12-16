clear all
close all
clc

%% Path Configuration

path_configuration;
% NOTE:  genpath allows inclusion of subfolders

%% Simulation Sampling time
Tl=0.1;
%% settings
scenario_settings;


%% Simulation 
open('LVS_model_upgrade.slx');
SimOut = sim('LVS_model_upgrade.slx');
cam_landmarks = SimOut.landmarks;
num_landmarks = SimOut.num_landmarks;
landmarks_ground = SimOut.Cam_landmarks_ground;

%% Plot
% figure(1)
% plot(num_landmarks);
% grid on
% title('Landmarks found');
% xlabel('$t$', 'Interpreter', 'latex');
% ylabel('$landmarks\:found$', 'Interpreter', 'latex');
% % Adjust the linewidth of the axes and labels
% set(gca, 'LineWidth', 0.5); % Set the linewidth of the axes
% set(gca, 'FontWeight', 'normal'); % Set the font weight of the axes labels
% print('img/landmarks_found.eps', '-depsc');
% saveas(gcf, 'img/landmarks_found.jpg');

% figure(2)
% plot(EST_Quaternion.Time,(EST_Quaternion.Data-ACT_Quaternion.Data)*180/pi)
% grid on
% title('ERROR ATTITUDE EST-ACT')
% xlabel('Time [s]')
% ylabel('[-]')
% legend('q1','q2','q3','q4')
% set(gca, 'LineWidth', 0.5); % Set the linewidth of the axes
% set(gca, 'FontWeight', 'normal'); % Set the font weight of the axes labels
% print('img/Error_Attitude.eps', '-depsc');
% saveas(gcf, 'img/Error_Attitude.jpg');

% figure(3); 
% plot(EST_PosX.time,(EST_PosX.signals.values-ACT_PosX.signals.values))
% hold on
% plot(EST_PosY.time,(EST_PosY.signals.values-ACT_PosY.signals.values))
% plot(EST_PosZ.time,(EST_PosZ.signals.values-ACT_PosZ.signals.values))
% grid on
% title('ERROR POSITION EST-ACT')
% xlabel('Time [s]')
% ylabel('Distance [m]')
% legend('X','Y','Z')
% set(gca, 'LineWidth', 0.5); % Set the linewidth of the axes
% set(gca, 'FontWeight', 'normal'); % Set the font weight of the axes labels
% print('img/Error_Position.eps', '-depsc');
% saveas(gcf, 'img/Error_Position.jpg');


num_landmarks_cat=length(Cat.clandmarkX);

figure(4); %Simulation Init

for k=1:num_landmarks_cat
    CatX(k)=Cat.clandmarkX(k);
    CatY(k)=Cat.clandmarkY(k);
    Catr(k)=Cat.rlandmark(k);
    theta = linspace(0,2*pi);
    Catx = Catr(k)*cos(theta) + CatX(k);
    Caty = Catr(k)*sin(theta) + CatY(k);
    plot(Catx,Caty,'b')
    hold on;
end

num_landmarks_found=0;
for j=1:100
  GroundX(j)=0;
  GroundY(j)=0;
  r(j)=0;
  if (landmarks_ground(2,j*2-1) < 0) || (landmarks_ground(2,j*2-1) > 0)
    num_landmarks_found = num_landmarks_found+1;
  end  
end    
for i=1:num_landmarks_found
    CamX(i)=landmarks_ground(2,i*2-1);
    CamY(i)=landmarks_ground(2,i*2);
    Camr(i)=landmarks_ground(2,199+i*3);
    theta = linspace(0,2*pi);
    Camx = Camr(i)*cos(theta) + CamX(i);
    Camy = Camr(i)*sin(theta) + CamY(i); 
    plot(Camx,Camy,'r')
    hold on;
end
% create catalogue for matching algorithm
cameraShot.PosX = CamX';
cameraShot.PosY = CamY';
cameraShot.Radius = Camr';
writetable(struct2table(cameraShot), '..\..\CameraShotSim.csv');
% ---
set(gca, 'LineWidth', 0.5); % Set the linewidth of the axes
set(gca, 'FontWeight', 'normal'); % Set the font weight of the axes labels
print('img/Found_Craters_Init.eps', '-depsc');
saveas(gcf, 'img/Found_Craters_Init.jpg');

%ETSM_matching;

RANSAC_matching;

% figure(5); %Simulation after 10 s
% 
% for k=1:num_landmarks_cat
%     CatX(k)=Cat.clandmarkX(k);
%     CatY(k)=Cat.clandmarkY(k);
%     Catr(k)=Cat.rlandmark(k);
%     theta = linspace(0,2*pi);
%     Catx = Catr(k)*cos(theta) + CatX(k);
%     Caty = Catr(k)*sin(theta) + CatY(k);
%     plot(Catx,Caty,'b')
%     hold on;
% end
% 
% num_landmarks_found=0;
% for j=1:100
%   GroundX(j)=0;
%   GroundY(j)=0;
%   r(j)=0;
%   if (landmarks_ground(100,j*2-1) < 0) || (landmarks_ground(100,j*2-1) > 0)
%     num_landmarks_found = num_landmarks_found+1;
%   end  
% end    
% for i=1:num_landmarks_found
%     CamX(i)=landmarks_ground(100,i*2-1);
%     CamY(i)=landmarks_ground(100,i*2);
%     Camr(i)=landmarks_ground(100,199+i*3);
%     theta = linspace(0,2*pi);
%     Camx = Camr(i)*cos(theta) + CamX(i);
%     Camy = Camr(i)*sin(theta) + CamY(i);
%     plot(Camx,Camy,'r')
%     hold on;
% end
% set(gca, 'LineWidth', 0.5); % Set the linewidth of the axes
% set(gca, 'FontWeight', 'normal'); % Set the font weight of the axes labels
% print('img/Found_Craters_1s.eps', '-depsc');
% saveas(gcf, 'img/Found_Craters_1s.jpg');
% 
% 
% figure(6); %Simulation after 20 s
% 
% for k=1:num_landmarks_cat
%     CatX(k)=Cat.clandmarkX(k);
%     CatY(k)=Cat.clandmarkY(k);
%     Catr(k)=Cat.rlandmark(k);
%     theta = linspace(0,2*pi);
%     Catx = Catr(k)*cos(theta) + CatX(k);
%     Caty = Catr(k)*sin(theta) + CatY(k);
%     plot(Catx,Caty,'b')
%     hold on;
% end
% 
% num_landmarks_found=0;
% for j=1:100
%   GroundX(j)=0;
%   GroundY(j)=0;
%   r(j)=0;
%   if (landmarks_ground(200,j*2-1) < 0) || (landmarks_ground(200,j*2-1) > 0)
%     num_landmarks_found = num_landmarks_found+1;
%   end  
% end    
% for i=1:num_landmarks_found
%     CamX(i)=landmarks_ground(200,i*2-1);
%     CamY(i)=landmarks_ground(200,i*2);
%     Camr(i)=landmarks_ground(200,199+i*3);
%     theta = linspace(0,2*pi);
%     Camx = Camr(i)*cos(theta) + CamX(i);
%     Camy = Camr(i)*sin(theta) + CamY(i);
%     plot(Camx,Camy,'r')
%     hold on;
% end
% set(gca, 'LineWidth', 0.5); % Set the linewidth of the axes
% set(gca, 'FontWeight', 'normal'); % Set the font weight of the axes labels
% print('img/Found_Craters_2s.eps', '-depsc');
% saveas(gcf, 'img/Found_Craters_2s.jpg');
% 
% 
% 
% figure(7); %Simulation after 30 s
% 
% for k=1:num_landmarks_cat
%     CatX(k)=Cat.clandmarkX(k);
%     CatY(k)=Cat.clandmarkY(k);
%     Catr(k)=Cat.rlandmark(k);
%     theta = linspace(0,2*pi);
%     Catx = Catr(k)*cos(theta) + CatX(k);
%     Caty = Catr(k)*sin(theta) + CatY(k);
%     plot(Catx,Caty,'b')
%     hold on;
% end
% 
% num_landmarks_found=0;
% for j=1:100
%   GroundX(j)=0;
%   GroundY(j)=0;
%   r(j)=0;
%   if (landmarks_ground(300,j*2-1) < 0) || (landmarks_ground(300,j*2-1) > 0)
%     num_landmarks_found = num_landmarks_found+1;
%   end  
% end    
% for i=1:num_landmarks_found
%     CamX(i)=landmarks_ground(300,i*2-1);
%     CamY(i)=landmarks_ground(300,i*2);
%     Camr(i)=landmarks_ground(300,199+i*3);
%     theta = linspace(0,2*pi);
%     Camx = Camr(i)*cos(theta) + CamX(i);
%     Camy = Camr(i)*sin(theta) + CamY(i);
%     plot(Camx,Camy,'r')
%     hold on;
% end
% set(gca, 'LineWidth', 0.5); % Set the linewidth of the axes
% set(gca, 'FontWeight', 'normal'); % Set the font weight of the axes labels
% print('img/Found_Craters_3s.eps', '-depsc');
% saveas(gcf, 'img/Found_Craters_3s.jpg');
% 
% 
% 
% figure(8); %Simulation after 40 s
% 
% for k=1:num_landmarks_cat
%     CatX(k)=Cat.clandmarkX(k);
%     CatY(k)=Cat.clandmarkY(k);
%     Catr(k)=Cat.rlandmark(k);
%     theta = linspace(0,2*pi);
%     Catx = Catr(k)*cos(theta) + CatX(k);
%     Caty = Catr(k)*sin(theta) + CatY(k);
%     plot(Catx,Caty,'b')
%     hold on;
% end
% 
% num_landmarks_found=0;
% for j=1:100
%   GroundX(j)=0;
%   GroundY(j)=0;
%   r(j)=0;
%   if (landmarks_ground(400,j*2-1) < 0) || (landmarks_ground(400,j*2-1) > 0)
%     num_landmarks_found = num_landmarks_found+1;
%   end  
% end    
% for i=1:num_landmarks_found
%     CamX(i)=landmarks_ground(400,i*2-1);
%     CamY(i)=landmarks_ground(400,i*2);
%     Camr(i)=landmarks_ground(400,199+i*3);
%     theta = linspace(0,2*pi);
%     Camx = Camr(i)*cos(theta) + CamX(i);
%     Camy = Camr(i)*sin(theta) + CamY(i);
%     plot(Camx,Camy,'r')
%     hold on;
% end
% set(gca, 'LineWidth', 0.5); % Set the linewidth of the axes
% set(gca, 'FontWeight', 'normal'); % Set the font weight of the axes labels
% print('img/Found_Craters_4s.eps', '-depsc');
% saveas(gcf, 'img/Found_Craters_4s.jpg');
% 
% 
% figure(9); %Simulation after 40 s
% 
% for k=1:num_landmarks_cat
%     CatX(k)=Cat.clandmarkX(k);
%     CatY(k)=Cat.clandmarkY(k);
%     Catr(k)=Cat.rlandmark(k);
%     theta = linspace(0,2*pi);
%     Catx = Catr(k)*cos(theta) + CatX(k);
%     Caty = Catr(k)*sin(theta) + CatY(k);
%     plot(Catx,Caty,'b')
%     hold on;
% end
% 
% num_landmarks_found=0;
% for j=1:100
%   GroundX(j)=0;
%   GroundY(j)=0;
%   r(j)=0;
%   if (landmarks_ground(500,j*2-1) < 0) || (landmarks_ground(500,j*2-1) > 0)
%     num_landmarks_found = num_landmarks_found+1;
%   end  
% end    
% for i=1:num_landmarks_found
%     CamX(i)=landmarks_ground(500,i*2-1);
%     CamY(i)=landmarks_ground(500,i*2);
%     Camr(i)=landmarks_ground(500,199+i*3);
%     theta = linspace(0,2*pi);
%     Camx = Camr(i)*cos(theta) + CamX(i);
%     Camy = Camr(i)*sin(theta) + CamY(i);
%     plot(Camx,Camy,'r')
%     hold on;
% end
% set(gca, 'LineWidth', 0.5); % Set the linewidth of the axes
% set(gca, 'FontWeight', 'normal'); % Set the font weight of the axes labels
% print('img/Found_Craters_5s.eps', '-depsc');
% saveas(gcf, 'img/Found_Craters_5s.jpg');



return;

