function [Evect] = CalculeEnergieTermique()

    %Modelé moteur. 308 3Cylindres 1,2Lr ESSENCE
    Cap_cylindre = 1.2; %[L] 
    EffCylindre = 0.85;


    name = 'CaptorData.csv';
    ConsomationData = readmatrix(name,'OutputType','char');
    TimeMeassure    = str2double(ConsomationData(1:end,1));
    RegimeMoteur    = str2double(ConsomationData(1:end,2)); % [s]
    Tair_Meass      = str2double(ConsomationData(1:end,3));   % [tr/min]
    PositPedale     = str2double(ConsomationData(1:end,4));    % [°C]
    VittMeassure    = str2double(ConsomationData(1:end,5));   % [%]
    VittMeassure    = VittMeassure/3.6;   % [%]
    PositPapillon   = str2double(ConsomationData(1:end,6));% [Km/h]
    Pair_Meass      = str2double(ConsomationData(1:end,7));      % [bar]
    DistEstimee     = cumtrapz(TimeMeassure,VittMeassure);

    % Pair_Meass = ConsomationData(:,7); %[bar]
    % Tair_Meass = ConsomationData(:,3); %[°C]

%     subplot(2,3,1)
%     plot(TimeMeassure,RegimeMoteur)
%     title('Regime Moteur')
%     xlabel('Temps[s]')
%     ylabel('Regime Moteur [tr/min]')
%     grid on
%     subplot(2,3,2)
%     plot(TimeMeassure,Tair_Meass)
%     title('Tempeature de l"air d"admission')
%     xlabel('Temps[s]')
%     ylabel('Tempeature [°C]')
%     grid on
%     subplot(2,3,3)
%     plot(TimeMeassure,PositPedale)
%     title('Position de la pedale daccelerateur')
%     xlabel('Temps[s]')
%     ylabel('Position [%]')
%     grid on
%     subplot(2,3,4)
%     plot(TimeMeassure,VittMeassure)
%     title('Vitesse du véhicule')
%     xlabel('Temps[s]')
%     ylabel('Vitesse [Km/h]')
%     grid on
%     subplot(2,3,5)
%     plot(TimeMeassure,PositPapillon)
%     title('Position absolue du papillon des gaz')
%     xlabel('Temps[s]')
%     ylabel('Position absolue [%]')
%     grid on
%     subplot(2,3,6)
%     plot(TimeMeassure,Pair_Meass)
%     title('Pression tubulure d"admission')
%     xlabel('Temps[s]')
%     ylabel('Pression [bar]')
%     grid on
% 
%     figure
%     plot(TimeMeassure,DistEstimee)
%     title('Distance Estimée')
%     xlabel('Temps[s]')
%     ylabel('Distance [Km]')
%     grid on
    
    %% Profile Vitesse
    Temps = TimeMeassure;
    Vitesse = VittMeassure; % [m/s]
    Accel   = [0; diff(Vitesse)];     % m/s2
    Distance_theorique = cumtrapz(Temps,Vitesse);

    %% Consommation estimme mechaniquement

    Vair_Theorique = Cap_cylindre*RegimeMoteur/2; % [Lair/min]

    Veff = EffCylindre*Vair_Theorique; %[Litr/Min]

    Pair_MeasskPa = Pair_Meass*100;    %[kPa]
    Tair_MeassK   = Tair_Meass+273.15; %[°K]

    R = 8.314;

    n_air = (Pair_MeasskPa.*Veff)./(R*Tair_MeassK);

    Mm_air = 28.97; %Masse Moleculaire d'air 
    M_air = Mm_air*n_air;

    % Rapport Fixe 14,7:1 (14,7 grammes d'air pour 1 gramme d'essence).
    Messence = M_air/14.7;
    Vessence = Messence/720;

%     figure
%     plot(TimeMeassure,Vessence/60)
%     title('Flux d"Esscence [Ltr/sec]')
%     xlabel('Temps[s]')
%     ylabel('Débit [Lt/Min]')
%     grid on

    ConsomTot = cumtrapz(TimeMeassure,Vessence/60);
    %%
    %Environ 1[Ltr] Essence = 8.9KWh - 9.14KWh - 11.5KWh
    WsperLtrEssence = 10*3600*1000; % 2.3

    Evect = ConsomTot*WsperLtrEssence;

end

