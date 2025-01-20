%% Load Data and Catalogues
load ACT_Quaternion
load ACT_PosX
load ACT_PosY
load ACT_PosZ
load EST_Quaternion
load EST_PosX
load EST_PosY
load EST_PosZ
%Cat = load('Catalogue/Cat_5000_600elements_filtered.mat').landmarks_filtered;
Cat = load('Catalogue/Catalogue.mat').Cat;
% 
%% Camera
% % Camera Placement on Lander (x, y, z and attitude)
r_CB = [0; 0; -0.60];
q_CB = [0 0 0 1];
% % Camera specifications
w = 0.11;
h = 0.11;
f = 0.135;
Errf=0.001;
actualf=f*(1+Errf);
% 
%% Other parameters
n_points = 5;
landmarks_number_lvs = 100;
landmarks_initial = zeros(1, landmarks_number_lvs*10+1);
%% Errors for analyses
Rand_x = -3000 + 6000*rand;
Rand_y = -3000 + 6000*rand;
AltitudeError = -65; %±65;
PhiError = 1/180*pi;
ThtError = -1/180*pi;
PsiError = 5/180*pi; 
XAxisRotError = sin(PhiError/2);
YAxisRotError = sin(ThtError/2);
ZAxisRotError = sin(PsiError/2);
ScalarError = sqrt(1-XAxisRotError^2-YAxisRotError^2-ZAxisRotError^2);
