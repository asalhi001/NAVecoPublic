function [Uh, Vh, Xh, th,problem] = EstimateurCoupleMaxSpeed(NAVecoSegments,VehicleData,OptimizationData)

    SlopeVFiltre = [str2double(NAVecoSegments(:,4)) str2double(NAVecoSegments(:,6))];

    OrdreFiltre = 200;
    for i=1:length(SlopeVFiltre(:,2))
        if length(SlopeVFiltre(:,2))>1
            if i<=OrdreFiltre/2
                SlopeVFiltre(i,2)=mean(SlopeVFiltre(1:(OrdreFiltre/2),2));
            elseif i>=(length(SlopeVFiltre)-(OrdreFiltre/2))
                SlopeVFiltre(i,2)=mean(SlopeVFiltre(end-(OrdreFiltre/2):end,2));
            else
                SlopeVFiltre(i,2)=mean(SlopeVFiltre(i-(OrdreFiltre/2):i+(OrdreFiltre/2),2));
            end
        end
    end

    addpath('OpenLoopFunctions\')  

    V0 = 0;
    Xr0 = 0;
    t0 = 0;
    X0 = 0;
    th = [];
    Xh = [];
    Vh = [];
    Uh = [];
    Xr = [];
    Vlu= [];
    Vld= [];

    for j=1:25%max(str2double(NAVecoSegments(:,1)))         
    %     j=17
        Index = find(str2double(NAVecoSegments(:,1))==j);        

        MaxSpeed = [str2double(NAVecoSegments(min(Index):max(Index),4)) str2double(NAVecoSegments(min(Index):max(Index),5))];
        if (max(Index)<max(str2double(NAVecoSegments(:,1))))
            MaxSpeedP1=str2double(NAVecoSegments(max(Index)+1,5));
        else
            MaxSpeedP1=0;
        end
        %SlopeV = [str2double(NAVecoSegments(min(Index):max(Index),4)) str2double(NAVecoSegments(min(Index):max(Index),6))];
        SlopeV = SlopeVFiltre(min(Index):max(Index),:);
        SlopeV(:,1)=SlopeV(:,1)-SlopeV(1,1);
        SlopeV(:,2)=SlopeV(:,2);

        if (Index<max(str2double(NAVecoSegments(:,1))))
            FinalSpeed = str2double(NAVecoSegments(max(Index)+1,5));
        else
            FinalSpeed = 0;
        end

        DurationTemp = str2double(NAVecoSegments(max(Index),11));

        if DurationTemp<3
            DurationTemp = 3;
        end

        DestinationTemp = str2double(NAVecoSegments(max(Index),10));
    %     DestinationTemp = 17;

        TrajectData = struct('Distance', DestinationTemp,...
                             'Duration', DurationTemp,...
                             'OptSpeed', MaxSpeed(end,2),...
                             'MaxSpeed', MaxSpeed,...
                             'SlopeVect', SlopeV,...
                             'MaxSpeedT', 23,...%'MaxSpeedT', str2double(NAVecoSegments(max(Index),5)),...
                             'MaxSpeedC', 23,...%'MaxSpeedC', str2double(NAVecoSegments(max(Index),5)),...
                             'MinSpeedC', 0,...%                          'MinSpeedC', str2double(NAVecoSegments(max(Index),9)),...
                             'FinalSpeed', 0,...
                             'InitSpeed', V0,...
                             'Slope', mean(SlopeV(:,2)));

        [StatesHist, UnputHist, Temps, solution, problem] = MAIN_OpenLoopOptimizationNAVeco (OptimizationData ,TrajectData, VehicleData)
    %     [ tv, xv, uv ] = simulateSolution( problem, solution, 'ode113', 0.1 );

        xx=linspace(solution.T(1,1),solution.tf,1000);

        StatesHist = struct('X1', speval(solution,'X',1,xx),'X2', speval(solution,'X',2,xx))
        UnputHist  = struct('U', speval(solution,'U',1,xx))
        Temps         = linspace(solution.T(1,1),solution.tf,1000)';

        IndFinal = find(StatesHist.X1>=DestinationTemp,1);

        StatesHist.X1 = StatesHist.X1(1:IndFinal);
        StatesHist.X2 = StatesHist.X2(1:IndFinal);
        UnputHist.U   = UnputHist.U(1:IndFinal);
        Temps         = Temps(1:IndFinal);

        th = [th;Temps+t0];
        Xh = [Xh;StatesHist.X1+X0];
        Vh = [Vh;StatesHist.X2];
        Uh = [Uh;UnputHist.U];

        Xr = [Xr;ones(size(StatesHist.X1))*round(problem.data.Distance,2)+Xr0];
        Vlu= [Vlu;ones(size(StatesHist.X2))*round(problem.states.xfu(2),2)];    
        Vld= [Vld;ones(size(StatesHist.X2))*round(problem.states.xfl(2),2)];    

        t0 = th(end);
        X0 = Xh(end);
        V0 = Vh(end);
        Xr0= Xr(end);

        disp(' ')
        disp(' ')
        disp(' Segmento: ')
        disp(j)

    end

end

