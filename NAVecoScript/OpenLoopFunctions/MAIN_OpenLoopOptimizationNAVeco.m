% Main script to solve the Optimal Control Problem 
%
% Double Integrator Tracking Problem
%
%--------------------------------------------------------

function [StatesHist, UnputHist, Temps, solution, problem] = MAIN_OpenLoopOptimizationNAVeco (OptimizationData ,TrajectData, VehicleData)

    %clear all;close all;format compact;

    [problem,guess]=DoubleIntegratorTracking(OptimizationData ,TrajectData, VehicleData);          % Fetch the problem definition
    options= problem.settings(30);                  % Get options and solver settings 
    [solution,MRHistory]=solveMyProblem( problem,guess,options);
    [ tv, xv, uv ] = simulateSolution( problem, solution, 'ode113', 0.1 );

    xx=linspace(solution.T(1,1),solution.tf,1000);
    
    StatesHist = struct('X1', speval(solution,'X',1,xx),'X2', speval(solution,'X',2,xx))
    UnputHist  = struct('U', speval(solution,'U',1,xx))
    Temps         = linspace(solution.T(1,1),solution.tf,1000);


    %% figure
    
    plotOpt=0;
    
    if plotOpt
        figure
        subplot(3,1,1)
        hold on
        plot(xx,speval(solution,'X',1,xx),'r-' )
        plot(tv,xv(:,1),'k-.' )
        xlabel('Time [s]')
        ylabel('Distance')
        grid on

        subplot(3,1,2)
        hold on
        plot(xx,speval(solution,'X',2,xx),'r-' )
        plot(xx,[0; diff(speval(solution,'X',1,xx))./diff(xx')],'b-' )
        plot(tv,xv(:,2),'k-.' )
        xlabel('Time [s]')
        ylabel('Vitesse')
        grid on

        subplot(3,1,3)
        hold on
        plot(xx,[0; diff(speval(solution,'X',2,xx))./diff(xx')],'k-' )
        plot([solution.T(1,1); solution.tf],[problem.data.grav*0.2, problem.data.grav*0.2],'r--' )
        plot([solution.T(1,1); solution.tf],[problem.data.grav*-0.2, problem.data.grav*-0.2],'r-' )
        xlabel('Time [s]')
        ylabel('Accel')
        grid on

%         figure
%         hold on
%         plot(xx,speval(solution,'U',1,xx),'b-' )
%         plot(tv,uv(:,1),'k-.' )
%         plot([solution.T(1,1); solution.tf],[problem.inputs.ul, problem.inputs.ul],'r-' )
%         plot([solution.T(1,1); solution.tf],[problem.inputs.uu, problem.inputs.uu],'r-' )
%         xlim([0 solution.tf])
%         xlabel('Time [s]')
%         grid on
%         ylabel('Control Input')
%         legend('u [N]')
    end

end

