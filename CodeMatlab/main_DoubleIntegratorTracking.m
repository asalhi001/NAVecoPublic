% Main script to solve the Optimal Control Problem 
%
% Double Integrator Tracking Problem
%
%--------------------------------------------------------

clear all;close all;format compact;

[problem,guess]=DoubleIntegratorTracking;          % Fetch the problem definition
options= problem.settings(30);                  % Get options and solver settings 
[solution,MRHistory]=solveMyProblem( problem,guess,options);
[ tv, xv, uv ] = simulateSolution( problem, solution, 'ode113', 0.001 );

%% figure
xx=linspace(solution.T(1,1),solution.tf,1000);


figure
subplot(3,1,1)
%hold on
plot(xx,speval(solution,'X',1,xx),'r-' )
%plot(tv,xv(:,1),'k-.' )
xlabel('Time [s]')
ylabel('Distance')
grid on

subplot(3,1,2)
%hold on
plot(xx,speval(solution,'X',2,xx),'r-' )
%plot(tv,xv(:,2),'k-.' )
xlabel('Time [s]')
ylabel('Vitesse')
grid on

Rw    = problem.data.Rw;
x2    = speval(solution,'X',2,xx);
u1    = speval(solution,'U',1,xx);

RPM=x2./(Rw*0.10472);
RPMopt = 15/(Rw*0.10472); % Hipothese v optimale
eff = 0.9 - ((RPM-RPMopt).^2)/1.8e6 - ((u1-300).^2)/1e6;

for i=1:length(u1)
    if(u1(i)>0)
        eff(i)=1/eff(i);
        %eff(i)=1/0.85;
    else
        eff(i)=0;
    end
end

Pow  = (x2.*u1/Rw).*eff;
x3   =  cumtrapz(xx,Pow);

subplot(3,1,3)
%hold on
plot(xx,x3,'r-' )
%plot(tv,xv(:,2),'k-.' )
xlabel('Time [s]')
ylabel('Energie')
grid on

% figure
% plot(xx,eff)
% grid on

figure
hold on
plot(xx,speval(solution,'U',1,xx),'b-' )
plot(tv,uv(:,1),'k-.' )
plot([solution.T(1,1); solution.tf],[problem.inputs.ul, problem.inputs.ul],'r-' )
plot([solution.T(1,1); solution.tf],[problem.inputs.uu, problem.inputs.uu],'r-' )
xlim([0 solution.tf])
xlabel('Time [s]')
grid on
ylabel('Control Input')
legend('u [N]')

disp('Energie finale [Wh]:')
x3(end)/3600
