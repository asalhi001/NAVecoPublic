%Script Sensibilité Filtro Elevation%
%%Définir
clear all
close all
clc

SpeedProfileWLTP

Rref = 1; %Resolution_reference = Rref;
Rcou = Rref; %Resolution_courante = Rcou;  
AddresseDepart = '9_Rue_Edouard_Lefebvre_Versailles';
AddresseArrive = 'Expleo,_Avenue_des_Prés,_Montigny-le-Bretonneux';

OrdreFiltre = 2;
UpdateData(AddresseDepart, AddresseArrive, Rref, OrdreFiltre);

name = 'dataResolE3.csv';
% name = 'dataResol1_GMaps_38KmRcteVitR1.csv';
%%M = csvread(name);
NAVecoData = readmatrix(name,'OutputType','char');
Num = str2double(NAVecoData(1:end,1));
Lat  = str2double(NAVecoData(1:end,2));
Long = str2double(NAVecoData(1:end,3));
Dist =str2double(NAVecoData(1:end,4));
MaxSpeed = str2double(NAVecoData(1:end,5));
Slope = str2double(NAVecoData(1:end,6));
Altitude = str2double(NAVecoData(1:end,7));
Duree = str2double(NAVecoData(1:end,8));
Distance_absolute = Dist;

figure
geoplot(Lat,Long)

figure
plot(Distance_absolute,Slope)
title('Slope [rad]')
grid on
figure
plot(Distance_absolute,Altitude)
title('Altitude [m]')
grid on

Database = [];

data.dist = Distance_absolute;
data.slop = Slope;
data.Altt = Altitude;

Distance_absoluteP = diff(Distance_absolute);
SlopeP             = diff(Slope);
AltitudeP          = diff(Altitude);

data.distP = Distance_absoluteP;
data.slopP = SlopeP;
data.AlttP = AltitudeP;

data.MAX_AlttP  = max(AltitudeP);
data.MIN_AlttP  = min(AltitudeP);
data.MEAN_AlttP = mean(AltitudeP);

data.MAX_slopP  = max(SlopeP);
data.MIN_slopP  = min(SlopeP);
data.MEAN_slopP = mean(SlopeP);

data.CorrelAltt  = ones(2,2);
data.CorrelAlttP = ones(2,2);
data.CorrelSlop  = ones(2,2);
data.CorrelSlopP = ones(2,2);

Database = [Database data];

pause(0.5)

%% Iterations

for i=4:2:500
    OrdreFiltre = i;
    UpdateData(AddresseDepart, AddresseArrive, Rref, OrdreFiltre);

    name = 'dataResolE3.csv';
    % name = 'dataResol1_GMaps_38KmRcteVitR1.csv';
    %%M = csvread(name);
    NAVecoData = readmatrix(name,'OutputType','char');
    Num = str2double(NAVecoData(1:end,1));
    Lat  = str2double(NAVecoData(1:end,2));
    Long = str2double(NAVecoData(1:end,3));
    Dist =str2double(NAVecoData(1:end,4));
    MaxSpeed = str2double(NAVecoData(1:end,5));
    Slope = str2double(NAVecoData(1:end,6));
    Altitude = str2double(NAVecoData(1:end,7));
    Duree = str2double(NAVecoData(1:end,8));
    Distance_absolute = Dist;

    data.dist = Distance_absolute;
    data.slop = Slope;
    data.Altt = Altitude;
    
    Distance_absoluteP = diff(Distance_absolute);
    SlopeP             = diff(Slope);
    AltitudeP          = diff(Altitude);
    
    data.distP = Distance_absoluteP;
    data.slopP = SlopeP;
    data.AlttP = AltitudeP;
    
    data.MAX_AlttP  = max(AltitudeP);
    data.MIN_AlttP  = min(AltitudeP);
    data.MEAN_AlttP = mean(AltitudeP);
    
    data.MAX_slopP  = max(SlopeP);
    data.MIN_slopP  = min(SlopeP);
    data.MEAN_slopP = mean(SlopeP);
    
    data.CorrelAltt  = corrcoef(Database(1).Altt,Altitude);
    data.CorrelAlttP = corrcoef(Database(1).AlttP,AltitudeP);
    data.CorrelSlop  = corrcoef(Database(1).slop,Slope);
    data.CorrelSlopP = corrcoef(Database(1).slopP,SlopeP);

    Database = [Database data];
    
    i
    
end

% save('DataBase500.mat', 'Database');
% load('DataBase500.mat', 'Database');

%% Comparatif

%Variables: 
%     Alt p Max/Min/Mean
%     Slope p Max/Min/Mean
%     Correlation alt/Slope/Alt p

MAX_AlttP_V   = [];
MIN_AlttP_V   = [];
MEAN_AlttP_V  = [];

MAX_slopP_V   = [];
MIN_slopP_V   = [];
MEAN_slopP_V  = [];

CorrelAltt_V  = [];
CorrelAlttP_V = [];
CorrelSlop_V  = [];
CorrelSlopP_V = [];

for i=1:size(Database,2)
    
    MAX_AlttP_V   = [MAX_AlttP_V Database(i).MAX_AlttP];
    MIN_AlttP_V   = [MIN_AlttP_V Database(i).MIN_AlttP];
    MEAN_AlttP_V  = [MEAN_AlttP_V Database(i).MEAN_AlttP];
    
    MAX_slopP_V   = [MAX_slopP_V Database(i).MAX_slopP];
    MIN_slopP_V   = [MIN_slopP_V Database(i).MIN_slopP];
    MEAN_slopP_V  = [MEAN_slopP_V Database(i).MEAN_slopP];
    
    CorrelAltt_V  = [CorrelAltt_V Database(i).CorrelAltt(1,2)];
    CorrelAlttP_V = [CorrelAlttP_V Database(i).CorrelAlttP(1,2)];
    CorrelSlop_V  = [CorrelSlop_V Database(i).CorrelSlop(1,2)];
    CorrelSlopP_V = [CorrelSlopP_V Database(i).CorrelSlopP(1,2)];
    
end

%% Plots

figure
subplot(3,1,1)
plot([2:2:500],MAX_AlttP_V)
grid on
xlabel('Ordre du filtre [-]')
ylabel('Max. variation de l"altitude [m]')
subplot(3,1,2)
plot([2:2:500],MIN_AlttP_V)
grid on
xlabel('Ordre du filtre [-]')
ylabel('Min. variation de l"altitude [m]')
subplot(3,1,3)
plot([2:2:500],MEAN_AlttP_V)
grid on
xlabel('Ordre du filtre [-]')
ylabel('Variation moyene de l"altitude [m]')

figure
subplot(3,1,1)
plot([2:2:500],MAX_slopP_V)
grid on
xlabel('Ordre du filtre [-]')
ylabel('Max. variation de la pente [rad]')
subplot(3,1,2)
plot([2:2:500],MIN_slopP_V)
grid on
xlabel('Ordre du filtre [-]')
ylabel('Min. variation de la pente [rad]')
subplot(3,1,3)
plot([2:2:500],MEAN_slopP_V)
grid on
xlabel('Ordre du filtre [-]')
ylabel('Variation moyene de la pente [rad]')

figure
subplot(2,2,1)
plot([2:2:500],CorrelAltt_V)
grid on
xlabel('Ordre du filtre [-]')
ylabel('Corralation entre altitude originala et filtré [-]')
subplot(2,2,2)
plot([2:2:500],CorrelAlttP_V)
grid on
xlabel('Ordre du filtre [-]')
ylabel('Corralation entre la dérivé de l"altitude original et filtré [-]')
subplot(2,2,3)
plot([2:2:500],CorrelSlop_V)
grid on
xlabel('Ordre du filtre [-]')
ylabel('Corralation entre la pente original et filtré [-]')
subplot(2,2,4)
plot([2:2:500],CorrelSlopP_V)
grid on
xlabel('Ordre du filtre [-]')
ylabel('Corralation entre la dérivé de la pente original et filtré [-]')


