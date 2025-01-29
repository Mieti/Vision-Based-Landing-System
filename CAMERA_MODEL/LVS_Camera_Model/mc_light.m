clear all
close all
clc

path_configuration;

Tl=0.1;

%% SCENARIO SETTINGS

Cat = load('Catalogue/Catalogue.mat').Cat;
r_CB = [0; 0; -0.60];
q_CB = [0 0 0 1];
w = 0.11;
h = 0.11;
f = 0.135;
Errf=0.001;
actualf=f*(1+Errf);

load ACT_Quaternion
load ACT_PosX
load ACT_PosY
load ACT_PosZ
load EST_Quaternion
load EST_PosX
load EST_PosY
load EST_PosZ

n_points = 5;
landmarks_number_lvs = 100;
landmarks_initial = zeros(1, landmarks_number_lvs*10+1);
nrun = 10;

mc_results = struct('ACT_Quaternion', [], ...
                    'EST_Quaternion', [], ...
                    'ACT_PosX', [], ...
                    'ACT_PosY', [], ...
                    'ACT_PosZ', [], ...
                    'Translation', [], ...
                    'Distance', [], ...
                    'Direction', [], ...
                    'Time', [], ...
                    'Accuracy', []);

for run=1:nrun
    %% MC VARIABLES
    if run == 1
        rand('state',5938437);INIT_rand_values=rand(7,nrun);
        randn('state',2845334);INIT_randn_values=randn(7,nrun);
    end

    MURot0=0;
    SIGMARot0=5/3; 
    Rot0 =(MURot0+SIGMARot0*INIT_randn_values(1,run));
    AngRot0=2*pi*(INIT_rand_values(1,run)-0.5);
    RotNomX0=(Rot0/180*pi)*cos(AngRot0);  
    RotNomY0=(Rot0/180*pi)*sin(AngRot0);
    RotNomZ0=2/180*pi*(INIT_rand_values(2,run)-0.5);
    MatNom(1,1)=cos(RotNomY0)*cos(RotNomZ0);
    MatNom(1,2)=cos(RotNomY0)*sin(RotNomZ0);
    MatNom(1,3)=-sin(RotNomY0);
    MatNom(2,1)=-cos(RotNomX0)*sin(RotNomZ0)+sin(RotNomX0)*sin(RotNomY0)*cos(RotNomZ0);
    MatNom(2,2)=cos(RotNomX0)*cos(RotNomZ0)+sin(RotNomX0)*sin(RotNomY0)*sin(RotNomZ0);
    MatNom(2,3)=sin(RotNomX0)*cos(RotNomY0);
    MatNom(3,1)=sin(RotNomX0)*sin(RotNomZ0)+cos(RotNomX0)*sin(RotNomY0)*cos(RotNomZ0);
    MatNom(3,2)=-sin(RotNomX0)*cos(RotNomZ0)+cos(RotNomX0)*sin(RotNomY0)*sin(RotNomZ0);
    MatNom(3,3)=cos(RotNomX0)*cos(RotNomY0);

    if ((0.5*(1+MatNom(1,1)+MatNom(2,2)+MatNom(3,3))^0.5) > 0.1)
      q40=0.5*(1+MatNom(1,1)+MatNom(2,2)+MatNom(3,3))^0.5;
      q10=(1/(4*q40))*(MatNom(2,3)-MatNom(3,2));
      q20=(1/(4*q40))*(MatNom(3,1)-MatNom(1,3));
      q30=(1/(4*q40))*(MatNom(1,2)-MatNom(2,1));
    else
      if ((0.5*(1+MatNom(1,1)-MatNom(2,2)-MatNom(3,3))^0.5) > 0.1)
        q10=0.5*(1+MatNom(1,1)-MatNom(2,2)-MatNom(3,3))^0.5;
        q20=(1/(4*q10))*(MatNom(1,2)+MatNom(2,1));
        q30=(1/(4*q10))*(MatNom(1,3)+MatNom(3,1));
        q40=(1/(4*q10))*(MatNom(2,3)-MatNom(3,2));        
      else
        if ((0.5*(1-MatNom(1,1)+MatNom(2,2)-MatNom(3,3))^0.5) > 0.1)
          q20=0.5*(1-MatNom(1,1)+MatNom(2,2)-MatNom(3,3))^0.5;
          q10=(1/(4*q20))*(MatNom(1,2)+MatNom(2,1));
          q30=(1/(4*q20))*(MatNom(2,3)+MatNom(3,2));
          q40=(1/(4*q20))*(MatNom(3,1)-MatNom(1,3));    
        else
          q30=0.5*(1-MatNom(1,1)-MatNom(2,2)+MatNom(3,3))^0.5;
          q40=(1/(4*q30))*(MatNom(1,2)-MatNom(2,1));
          q20=(1/(4*q30))*(MatNom(2,3)+MatNom(3,2));
          q10=(1/(4*q30))*(MatNom(1,3)+MatNom(3,1));
        end  
      end
    end
        
                    
    q0(1)=q10;
    q0(2)=q20;    
    q0(3)=q30;
    q0(4)=q40;
    ACT_Quaternion.Data(1,1:4) = q0(1,:);

    MURotBiasX=0;
    SIGMARotBiasX=1./3; 
    MURotBiasY=0; 
    SIGMARotBiasY=1./3; 
    MURotBiasZ=0; 
    SIGMARotBiasZ=1./3; 

    InitialErrorX=(MURotBiasX+SIGMARotBiasX*INIT_randn_values(2,run))/180*pi; 
    InitialErrorY=(MURotBiasY+SIGMARotBiasY*INIT_randn_values(3,run))/180*pi;
    InitialErrorZ=(MURotBiasZ+SIGMARotBiasZ*INIT_randn_values(4,run))/180*pi;

    RotX0=RotNomX0+InitialErrorX;
    RotY0=RotNomY0+InitialErrorY;
    RotZ0=RotNomZ0+InitialErrorZ;

    MatC(1,1)=cos(RotY0)*cos(RotZ0);
    MatC(1,2)=cos(RotY0)*sin(RotZ0);
    MatC(1,3)=-sin(RotY0);
    MatC(2,1)=-cos(RotX0)*sin(RotZ0)+sin(RotX0)*sin(RotY0)*cos(RotZ0);
    MatC(2,2)=cos(RotX0)*cos(RotZ0)+sin(RotX0)*sin(RotY0)*sin(RotZ0);
    MatC(2,3)=sin(RotX0)*cos(RotY0);
    MatC(3,1)=sin(RotX0)*sin(RotZ0)+cos(RotX0)*sin(RotY0)*cos(RotZ0);
    MatC(3,2)=-sin(RotX0)*cos(RotZ0)+cos(RotX0)*sin(RotY0)*sin(RotZ0);
    MatC(3,3)=cos(RotX0)*cos(RotY0);

    if ((0.5*(1+MatC(1,1)+MatC(2,2)+MatC(3,3))^0.5) > 0.1)
      Knownq40=0.5*(1+MatC(1,1)+MatC(2,2)+MatC(3,3))^0.5;
      Knownq10=(1/(4*Knownq40))*(MatC(2,3)-MatC(3,2));
      Knownq20=(1/(4*Knownq40))*(MatC(3,1)-MatC(1,3));
      Knownq30=(1/(4*Knownq40))*(MatC(1,2)-MatC(2,1));
    else
      if ((0.5*(1+MatC(1,1)-MatC(2,2)-MatC(3,3))^0.5) > 0.1)
        Knownq10=0.5*(1+MatC(1,1)-MatC(2,2)-MatC(3,3))^0.5;
        Knownq20=(1/(4*Knownq10))*(MatC(1,2)+MatC(2,1));
        Knownq30=(1/(4*Knownq10))*(MatC(1,3)+MatC(3,1));
        Knownq40=(1/(4*Knownq10))*(MatC(2,3)-MatC(3,2));        
      else
        if ((0.5*(1-MatC(1,1)+MatC(2,2)-MatC(3,3))^0.5) > 0.1) 
          Knownq20=0.5*(1-MatC(1,1)+MatC(2,2)-MatC(3,3))^0.5;
          Knownq10=(1/(4*Knownq20))*(MatC(1,2)+MatC(2,1));
          Knownq30=(1/(4*Knownq20))*(MatC(2,3)+MatC(3,2));
          Knownq40=(1/(4*Knownq20))*(MatC(3,1)-MatC(1,3));
        else
          Knownq30=0.5*(1-MatC(1,1)-MatC(2,2)+MatC(3,3))^0.5;
          Knownq40=(1/(4*Knownq30))*(MatC(1,2)-MatC(2,1));
          Knownq20=(1/(4*Knownq30))*(MatC(2,3)+MatC(3,2));
          Knownq10=(1/(4*Knownq30))*(MatC(1,3)+MatC(3,1));
        end  
      end
    end

    q0_known(1)=Knownq10;
    q0_known(2)=Knownq20;    
    q0_known(3)=Knownq30;
    q0_known(4)=Knownq40;
    EST_Quaternion.Data(1,1:4) = q0(1,:);

    Rand_z = 4100+130*(INIT_rand_values(5,run)-0.5);
    ACT_PosZ.signals.values(1:1) = Rand_z;


    Rand_x = -3000 + 6000*INIT_rand_values(6, run);
    Rand_y = -3000 + 6000*INIT_rand_values(7, run);


    AltitudeError = -65; %±65;
    PhiError = 1/180*pi;
    ThtError = -1/180*pi;
    PsiError = 5/180*pi; 
    XAxisRotError = sin(PhiError/2);
    YAxisRotError = sin(ThtError/2);
    ZAxisRotError = sin(PsiError/2);
    ScalarError = sqrt(1-XAxisRotError^2-YAxisRotError^2-ZAxisRotError^2);

    %% SIMULATION
    open('LVS_model_upgrade.slx');
    SimOut = sim('LVS_model_upgrade.slx');
    cam_landmarks = SimOut.landmarks;
    num_landmarks = SimOut.num_landmarks;
    landmarks_ground = SimOut.Cam_landmarks_ground;

    num_landmarks_cat=length(Cat.clandmarkX);

    figure(3*run-2); %Simulation Init
    
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
    currentDir = fileparts(mfilename('fullpath'));
    outputPath = fullfile(currentDir, '..', '..', 'CameraShotSim.csv');
    writetable(struct2table(cameraShot), outputPath);

    tic 
        [translation, distance, direction] = ETSM_matching(run);
    time = toc;

    % tic
    %     RANSAC_matching(run);
    % time = toc;

    mc_results(run).ACT_Quaternion = q0;
    mc_results(run).EST_Quaternion = q0_known;
    mc_results(run).ACT_PosX = Rand_x;
    mc_results(run).ACT_PosY = Rand_y;
    mc_results(run).ACT_PosZ = Rand_z;
    mc_results(run).Translation = translation;
    mc_results(run).Distance = distance;
    mc_results(run).Direction = direction;
    mc_results(run).Time = time;
    % mc_results(run).Accuracy = accuracy;
end
mc_results = struct2table(mc_results);