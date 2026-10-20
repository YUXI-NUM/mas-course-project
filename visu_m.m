%% Visualization
set(groot, 'defaultAxesTickLabelInterpreter','latex');
set(groot, 'defaultTextInterpreter','latex');
set(groot, 'defaultLegendInterpreter','latex');
set(groot, 'defaultAxesFontSize',14);
set(groot, 'defaultLineLineWidth',1.5);

%% 
N = 5;  
x = cell(N,1);
v = cell(N,1);

tmp = getElement(logsout,'x1');
t = tmp.Values.Time;

for i = 1:N
    tmp = getElement(logsout, sprintf('x%d',i));
    x{i} = tmp.Values.Data;   

    tmp = getElement(logsout, sprintf('v%d',i));
    v{i} = tmp.Values.Data;   
end

%% (1) 3D positions -
% figure(1); clf;
% hold on; grid on;
% for i = 1:N
%     plot3(x{i}(:,1), x{i}(:,2), x{i}(:,3));
% end
% xlabel('$x$ (m)'); ylabel('$y$ (m)'); zlabel('$z$ (m)');
% title('3D Positions');
% legend(arrayfun(@(i) sprintf('$x_%d$',i), 1:N, 'UniformOutput', false), ...
%      'Location','best');

%% (2) Position trajectories (all agents) 
figure(2); clf;
for k = 1:3
    subplot(3,1,k); hold on; grid on;
    for i = 1:N
        plot(t, x{i}(:,k));
    end
    if k==1
        title('Position trajectories');
    end
    ylabel(sprintf('$x_{i%d}$ (m)', k));
    if k==3
        xlabel('$t$ (s)');
    end
end
legend(arrayfun(@(i) sprintf('$x_%d$',i), 1:N, 'UniformOutput', false), ...
       'Location','best');

%% (3) Position errors to agent 1 (reference)
figure(3); clf;
for k = 1:3
    subplot(3,1,k); hold on; grid on;
    for i = 2:N
        plot(t, x{i}(:,k) - x{1}(:,k));
    end
    if k==1
        title('Position errors w.r.t agent 1');
    end
    ylabel(sprintf('$x_{i%d}-x_{1%d}$ (m)', k, k));
    if k==3
        xlabel('$t$ (s)');
    end
end
legend(arrayfun(@(i) sprintf('$x_%d-x_1$',i), 2:N, 'UniformOutput', false), ...
       'Location','best');

%% (4) Velocity trajectories + consensus value
V0 = zeros(3,N);
for i = 1:N
    V0(:,i) = v{i}(1,:).';   
end
v_star = mean(V0,2);         % 3x1

figure(4); clf;
for k = 1:3
    subplot(3,1,k); hold on; grid on;

    % plot all agents
    for i = 1:N
        plot(t, v{i}(:,k));
    end

    % plot consensus reference line
    yline(v_star(k), '--', '$v^\star$', 'Interpreter','latex');
    if k==1
        title('Velocity trajectories (consensus on velocities)');
    end
    ylabel(sprintf('$v_{i%d}$ (m/s)', k));
    if k==3
        xlabel('$t$ (s)');
    end
end
legend([arrayfun(@(i) sprintf('$v_%d$',i), 1:N, 'UniformOutput', false), {'$v^\star$'}], ...
       'Location','best');
% relative-velocity disagreement
Lt = evalin('base','L').';   % use the same L as in init
eta = zeros(length(t),1);

for kk = 1:length(t)
    Vk = zeros(3,N);
    for i = 1:N
        Vk(:,i) = v{i}(kk,:).';
    end
    eta(kk) = norm(Vk*Lt,'fro');   % = || (L ⊗ I3) vec(V) ||
end

figure(7); clf; grid on; hold on;
plot(t, eta);
xlabel('$t$ (s)'); ylabel('norm');
title('Relative-velocity disagreement |V(t)L^top|_F');
%% (5) Mean trajectory vs theoretical consensus trajectory (relative damping)
X0 = zeros(3,N); V0 = zeros(3,N);
for i = 1:N
    X0(:,i) = x{i}(1,:).';
    V0(:,i) = v{i}(1,:).';
end
xbar0 = mean(X0,2);
vbar0 = mean(V0,2);

xbar = zeros(length(t),3);
for kk = 1:length(t)
    s = zeros(3,1);
    for i = 1:N
        s = s + x{i}(kk,:).';
    end
    xbar(kk,:) = (s/N).';
end

dampCase = evalin('base','dampCase');
gamma    = evalin('base','gamma');
K        = evalin('base','K');

if dampCase == 2
    x_theory = xbar0.' + t * vbar0.';   % relative damping
    theoryLabel = 'theory $\bar R(0)+t\bar V(0)$';
else
    x_theory = xbar0.' + ((1 - exp(-gamma*K*t))/(gamma*K)) * vbar0.'; % absolute damping
    theoryLabel = 'theory $\bar R(0)+\frac{1-e^{-\gamma K t}}{\gamma K}\bar V(0)$';
end



figure(5); clf;
for k = 1:3
    subplot(3,1,k); hold on; grid on;
    plot(t, xbar(:,k));                 % simulation mean
    plot(t, x_theory(:,k), '--');       % theoretical mean
    if k==1, title('Mean position vs theoretical consensus trajectory'); end
    ylabel(sprintf('$\\bar x_%d$ (m)',k));
    if k==3, xlabel('$t$ (s)'); end
end
legend({'simulation $\bar R(t)$','theory $\bar R(0)+t\bar V(0)$'}, 'Location','best');

%% (6) Consensus error norms
eR2 = zeros(length(t),1);
eV2 = zeros(length(t),1);

for kk = 1:length(t)
    xbar_k = xbar(kk,:).';
    vbar_k = zeros(3,1);
    for i = 1:N
        vbar_k = vbar_k + v{i}(kk,:).';
    end
    vbar_k = vbar_k/N;

    sR = 0; sV = 0;
    for i = 1:N
        dx = x{i}(kk,:).' - xbar_k;
        dv = v{i}(kk,:).' - vbar_k;
        sR = sR + dx.'*dx;
        sV = sV + dv.'*dv;
    end
    eR2(kk) = sR;
    eV2(kk) = sV;
end

figure(6); clf; grid on; hold on;
plot(t, sqrt(eR2));
plot(t, sqrt(eV2));
xlabel('$t$ (s)'); ylabel('norm');
title('Consensus error norms');
legend({'$\|e_R(t)\|$','$\|e_V(t)\|$'}, 'Location','best');

%% (8) Relative-velocity disagreement ||V(t)L^T||_F  (strong verification)
Lt = evalin('base','L').';
eta = zeros(length(t),1);
for kk = 1:length(t)
    Vk = zeros(3,N);
    for i = 1:N
        Vk(:,i) = v{i}(kk,:).';
    end
    eta(kk) = norm(Vk*Lt,'fro');
end

figure(8); clf; grid on; hold on;
plot(t, eta);
xlabel('$t$ (s)'); ylabel('norm');
title('Relative-velocity disagreement $\|V(t)L^\top\|_F$');
