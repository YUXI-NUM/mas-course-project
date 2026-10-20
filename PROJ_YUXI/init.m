% script init

clear, close,clc

tf = 200;

%%%%% Constants %%%%
G = 6.67430*1e-11; % N*m^2*kg^(?2)
m1 = 1e+3;%kg
m2 = 1e+3;%kg
m3 = 100;
m4 = 50;
m5 = 10;
m_vec = [m1; m2; m3; m4; m5];
%%%%%%%%%%%%%%%%%%%%

%%%% Control gains %%%%
K = 1;

% Graph2
W_mat = zeros(5);
W_mat(1,2)=1; W_mat(2,1)=1;
W_mat(1,4)=1; W_mat(4,1)=1;
W_mat(1,5)=1; W_mat(5,1)=1;
W_mat(2,3)=1; W_mat(3,2)=1;
W_mat(2,5)=1; W_mat(5,2)=1;
W_mat(4,5)=1; W_mat(5,4)=1;

D_mat = diag(sum(W_mat,2));
L = D_mat-W_mat;

[V,D,W] = eig(L) ;
eigenvalues = diag(D);
fprintf('Eigenvalues of L:\n');
disp(eigenvalues);
fprintf('Eigenvectors of L:\n');
disp(V);
%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%% Initial Conditions %%%%%%%%%%%%%%% 

x1_0=[2e+2; 0; 5e+4];% m
x2_0=[1e+5; -5e+2; -1e+3];% m
x3_0=5*x1_0;
x4_0=5*x2_0;
x5_0=-10*(x1_0+x2_0);

v1_0 = [10; -20; 10];%m/s
v2_0 = [-10; 10; 30];
v3_0 = v1_0;
v4_0 = v2_0;
v5_0 = [0;0;0];

x_0 = [x1_0; v1_0; ...
    x2_0; v2_0; ...
    x3_0; v3_0; ...
    x4_0; v4_0; ...
    x5_0; v5_0];

V0 = [v1_0, v2_0, v3_0, v4_0, v5_0];   % 3x5
V0_vec = V0(:); 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 2.2 Second-order dynamics
gamma = 10;          % damping coefficient > 0
dampCase = 1;       % 1: absolute damping, 2: relative damping

%% 2.2) Calculate the consensus trajectory. Verify in simulation.
m_ref   = 100; 
% Control gains 
k1 = 1;            
k2 = 10;           
K_cons = k1 / m_ref;   
gamma = k2 / k1; 
dampCase = 2;     % 2 = relative damping
epsSoft = 1e-3;