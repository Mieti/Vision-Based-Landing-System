%% Load Data and Catalogues
load REAL_quaternion
load REAL_posx_data
load REAL_posy_data
load REAL_posz_data
Cat1 = load('PinPointToolBox/Catalogue/Cat_5000_600elements_filtered.mat').landmarks_filtered;
Cat2 = load('PinPointToolBox/Catalogue/Cat_3000_600elements_filtered.mat').landmarks2_filtered;
Cat1_unfiltered = load('PinPointToolBox/Catalogue/Cat_5000_600elements.mat').landmarks;
Cat2_unfiltered = load('PinPointToolBox/Catalogue/Cat_3000_600elements.mat').landmarks2;
% Cat1 = load('PinPointToolBox/Catalogue/Cat_5000_600elements.mat').landmarks;
% Cat2 = load('PinPointToolBox/Catalogue/Cat_3000_600elements.mat').landmarks2;
Cat = load('PinPointToolBox/Catalogue/Cat_real_1200elements.mat').landmarks_real;

RealCat = structToBus(Cat);
num_RealLandmarks = Cat.num_landmarks;


%% Lander
% Lander position (body)
% B = [10; -50; 2000];
% Lander size (only for visual)
% S = [200, 200, 300];
% Lander attitude
%q = [0.985 0.000 0.174 0.000];
% q = [0.0000 0.0000 0.0089 1.0000];
%q = [-0.2603 0.0322 0.0108 0.9649];
%q = [0 1 0 0];
% P = parallelepiped_vertex(S, q) + B';


%% Camera
% Camera Placement on Lander (x, y, z and attitude)
r_BC_B = [0; 0; -0.60];
% r_CB = [0; 0; -100];
q_BC = [0 0 0 1];
% Camera specifications
w = 0.11;
h = 0.11;
f = 0.08;
Errf=0.001;
actualf=f*(1+Errf);
a = 34.5; % half-cone aperture (in degrees!)
% LVS (pinhole model)
% [W, CC, C_pinhole, G] = pinhole(w, h, actualf, a, B', q, r_CB, q_CB);
% [s] Sampling time of LVS
% Tl=0.1; 
% Minimum matched landmarks to use LVS
% MinMatchedLandmarks = 5;


%% Estimation

% Initial known position
known_pos = [KnownXhX0 KnownXhY0 KnownAlt0];

% Initial known velocity
%KnownVhX0 = KnownVel0(1);%9.7410;
%KnownVhY0 = KnownVel0(2);%-9.8826;
%KnownVhZ0 = KnownVel0(3);%-100.1411;
%KnownVel0 = [KnownVhX0 KnownVhY0 KnownVhZ0];

% Initial known acceleration
% KnownAhX0 = KnownAcc0(1); %0;
% KnownAhY0 = KnownAcc0(2); %0;
% KnownAhZ0 = KnownAcc0(3); %0;
% KnownAcc0 = [KnownAhX0 KnownAhY0 KnownAhZ0];

% Initial known quaternion
% Knownq10 = -0.0079;
% Knownq20 = -0.0064;
% Knownq30 = 0.0017;
% Knownq40 = 0.9999;
known_quat = [Knownq10 Knownq20 Knownq30 Knownq40];

% Initial known Omega
% KnownOm0 = 0;


%% Other parameters
% n_points = 5;
landmarks_number_lvs = 100;
landmarks_initial = zeros(1, landmarks_number_lvs*5+1);

%% Landmark Threshold
% cat_threshold = 50;

%% Matching Threshold
matchingThreshold1 = 200;%200;%150;%75;
matchingThreshold2 = 125;%125;%85;%75;

%% Simulation settings
CatTime = 25;