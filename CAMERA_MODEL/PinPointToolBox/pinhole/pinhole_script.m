clear all
close all
clc

%% Lander
% Lander position
L = [3200; 3200; 3000];
% Lander size (for graphics purposes)
S = [200, 200, 400];
% Lander attitude
q = [0.985 0.000 0.174 0.000];
P = parallelepiped_vertex(S, q) + L';

%% Camera
% Camera Placement on Lander (x, y, z)
L;
% Camera specifications
w = 0.011;
h = 0.011;
f = 0.008;
a = 34.5; % half-cone aperture (in degrees!)
r_CB = [0; 0; -0.60];
q_BC = [0 0 0 1];

%% Interface
[W, CC, C_pinhole, G] = pinhole(w, h, f, a, L', q, r_CB, q_BC)

%% Plot
figure(1);
hold on;
grid on;
% Plot Lander
plot3(P(:, 1), P(:, 2), P(:, 3));
% Plot pinhole origin
%[w1, w2, w3] = dot(W);
%surf(w1, w2, w3);
% Plot camera lens center
%[cc1, cc2, cc3] = dot(CC);
%surf(cc1, cc2, cc3);
% Plot camera lens (rectangle)
plot3(C_pinhole(:, 1), C_pinhole(:, 2), C_pinhole(:, 3));
% Plot image on terrain map
p = fill3(G(:, 1), G(:, 2), G(:, 3), 'o');
p(1).FaceAlpha = 0.2;
% axis and view
xlim([0 7000])
ylim([0 7000])
zlim([0 7000])
view(38, 40);