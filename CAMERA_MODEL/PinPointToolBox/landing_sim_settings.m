%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LANDING SINGLE RUN
% SCOPE: Define the simulation parameters
DM2GNC=[0 0 1; 0 1 0; -1 0 0];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Parameters for the landing vision system
%CatalogueGeneration1;
%CatalogueGeneration2;
CatTime=25;
r_CB=[0; 0; -0.60];
q_B_C=[0 0 0 1];
% Rotation matrix for orientation of BRF wrt Planet Ref Frame at time k

w=0.11;
h=0.11;
f=0.08;
n_points=5;
MinMatchedLandmarks=5; % number of the minimum number of matching to be found between expected and observed features

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Number of simulations of the Montecarlo run
nrun=9;

% Sampling Times
Tm=0.001;     % [s] Sampling time of model integration (equal to gyro data generation and IMU integration)
Ts=0.001;     % [s] Sampling time for the RCS

% Sampling Times for the GNC section
Tg=0.01;      % [s] Sampling time of IMU acquisition and associated navigation filter 

Tr=0.05;     % [s] RDA related time
Tc=0.1;      % [s] Guidance and Control related time
Tl=0.1;      % [s] Sampling time of LVS
Tplot=0.01;   % [s] time for saving results

Tstop=85;   % [s];   Simulation Time


%SeparationDuration=1; %[s] Prescribed time between RJ separation and Turning On

% Duration of the BAM profile
% BAM_Duration=15; %with 2500;
BAM_Duration=9; %7 No BAM only angular correction;
Final_Leg_Altitude=1.3;%[m] Detected by Legs
hFinalGNC=1.3;
vFinalGNC=-0.7; %-1.2


% SIMULATION FLAGS FOR ALTERNATIVES ON DEMAND
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
RDA_NadirFlagPresence=0; %[0 Flag NotPresent, 1 Flag Present]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

InputDataReading;

%$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
% MODEL OF THE FLIGHT OBJECT
    
% ReadDataInput Landing (Descend) Module;
DM_ModelParameters;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SENSORS AND THRUSTER MODELS

% IMU platform
IMU_ModelParameters;

% RDA platform
RDA_ModelParameters;

% RCS system
RCS_ModelParameters;

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ON-BOARD SW PARAMETERS

IMU_PreProcParameters;

NAV2_RotationExecParameters; % Initialisation Montecarlo of the quaternion

RDA_PreProcParameters;

NAVR_TransSelectorExecParameters; % Initialisation Montecarlo of position and velocity

NAVR1_TranslationExecParameters;

NAVR2_TranslationExecParameters;

GUI_ExecParameters;

CON_ExecParameters;

EVN_SeparationParameters

EVN_ClosedLoopParameters;

EVN_BackshellAvoidanceManParameters;

EVN_IntensiveBrakingParameters;

EVN_FinalPhaseTransitionParameters;

EVN_RadarOutsideTheLoopParameters;

EVN_ReadyForTouchdownParameters;

EVN_TouchDownParameters;

scenario_settings;
% Cat1 = load('PinPointToolBox/Catalogue/Cat_5000_600elements_filtered.mat').landmarks_filtered;
% Cat2 = load('PinPointToolBox/Catalogue/Cat_3000_600elements_filtered.mat').landmarks2_filtered;
Cat1 = load('PinPointToolBox/Catalogue/Cat_5000_600elements.mat').landmarks;
Cat2 = load('PinPointToolBox/Catalogue/Cat_3000_600elements.mat').landmarks2;

Cat = load('PinPointToolBox/Catalogue/Cat_real_1200elements.mat').landmarks_real;