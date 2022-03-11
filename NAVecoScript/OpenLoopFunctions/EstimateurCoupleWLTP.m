function [Torq, Vitesse, Op, Temps] = EstimateurCoupleWLTP(NAVecoData,Profile,problem)

    DistanceTotal = str2num(string(NAVecoData(end,4)));
    SlopeVFiltre = [str2double(NAVecoData(:,4)) str2double(NAVecoData(:,6))];

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

    Tinit = 0
    Dinit = 0

    TempsWLTP    = Profile(:,1);     % s 
    VitesseWLTP  = Profile(:,3)/3.6; % m/s
    AccelWLTP    = Profile(:,4);     % m/s2
    DistanceWLTP = cumtrapz(TempsWLTP,VitesseWLTP);

    Temps    = [];     % s 
    Vitesse  = []; % m/s
    Accel    = [];     % m/s2
    Distance = [];

    count = 1;

    while (1)

        Temps    = [Temps Tinit+TempsWLTP(count)];       % s 
        Vitesse  = [Vitesse VitesseWLTP(count)];   % m/s
        Accel    = [Accel AccelWLTP(count)];       % m/s2
        Distance = [Distance Dinit+DistanceWLTP(count)]; % m

        Distance(end)

        if Distance(end)>DistanceTotal
            break
        end

        if (count==size(TempsWLTP,1))
            count = 1;
            Tinit = Temps(end);
            Dinit = Distance(end);
        else
            count = count +1;
        end

    end

    Distance_theorique = Distance;
    Distance_absolute  = str2double(NAVecoData(1:end,4));
    Op =[ ];

    % Pente conversion distance en temps
    for i=1:size(Distance_theorique,2)
        ind = find(abs(Distance_absolute-Distance_theorique(i))==min(abs(Distance_absolute-Distance_theorique(i))));
        Slope_temp = SlopeVFiltre(ind,2);
        Op =[Op Slope_temp];
    end

    OpPor    = tan(deg2rad(Op))*100;

    %% Calculo del Torque
    Torq=[];
    
    for i=1:max(size(Temps,1),size(Temps,2))
        Torq=[Torq   problem.data.Rw*(problem.data.M*Accel(i) +  problem.data.M*problem.data.grav*OpPor(i)  +  0.5*problem.data.pair*problem.data.Cxair*problem.data.Supf*Vitesse(i)^2  +  problem.data.M*problem.data.grav*problem.data.Cr)];
    end
end

