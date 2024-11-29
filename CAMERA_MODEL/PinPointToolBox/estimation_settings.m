%% Estimation

% Initial known position
KnownXhX0 = -760;
KnownXhY0 = -2910;
KnownAlt0 = 2451;
known_pos1 = [KnownXhX0 KnownXhY0 KnownAlt0];

KnownXhX0 = -700;
KnownXhY0 = -2410;
KnownAlt0 = 2370;
known_pos2 = [KnownXhX0 KnownXhY0 KnownAlt0];

KnownXhX0 = 450;
KnownXhY0 = -1210;
KnownAlt0 = 2401;
known_pos3 = [KnownXhX0 KnownXhY0 KnownAlt0];

% Initial known velocity
KnownVhX0 = 9.7410;
KnownVhY0 = -9.8826;
KnownVhZ0 = -100.1411;
KnownVel0 = [KnownVhX0 KnownVhY0 KnownVhZ0];

% Initial known acceleration
KnownAhX0 = 0;
KnownAhY0 = 0;
KnownAhZ0 = 0;
KnownAcc0 = [KnownAhX0 KnownAhY0 KnownAhZ0];

% Initial known quaternion
Knownq10 = -0.0079;
Knownq20 = -0.0064;
Knownq30 = 0.0017;
Knownq40 = 0.9999;
known_quat = [Knownq10 Knownq20 Knownq30 Knownq40];

% Initial known Omega
KnownOm0 = 0;

%% Montecarlo Simulation

known_initial_estimation_data.known_pos = [
    known_pos1 
    known_pos2 
    known_pos3];


