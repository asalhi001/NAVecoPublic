%Script Etape E3%
%%Définir
clear all
close all
clc

tic

SpeedProfileWLTP

Rref = 1; %Resolution_reference = Rref;
Rcou = Rref; %Resolution_courante = Rcou;
% v = 50/3.6; %Vitesse cte = v;  
AddresseDepart = '9_Rue_Edouard_Lefebvre_Versailles';
AddresseArrive = 'Expleo,_Avenue_des_Prés,_Montigny-le-Bretonneux';

OrdreFiltre = 350;%72;

%% Update CSV

UpdateData(AddresseDepart, AddresseArrive, Rref, OrdreFiltre);

%% Lecture de .CSV Initial Data

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
plot(Distance_absolute,Num)
title('Num Nodes')
grid on
figure
geoplot(Lat,Long)
figure
plot(Distance_absolute,Dist)
title('Distance [m]')
grid on
figure
plot(Distance_absolute,Slope)
title('Slope [rad]')
grid on
figure
plot(Distance_absolute,Altitude)
title('Altitude [m]')
grid on

%% Segmentation CSV

%SegmentData(seg_speed_ext, seg_slope_ext, seg_slope_sample, constant_slope_ext, duration_user)
SegmentData('False', 'False', num2str(deg2rad(1.5)), 'True', num2str(1000))

%Table: 8.5864e+03 m
% True  True  871.33/871.33 Wh 452.24/419.30 s 0.90 m 
% False True  828.03/826.06 Wh 383.16/466.60 s 0.22 m
% True  False 1.1104e+03/1.6103e+03 Ws 284.99/188.39 s -2.1334e+03 m
% False False 682.91/682.91 16.30/16.31 s 5.4631e-06 m OrderFilter350EeqVitesse
 
%% Lecture de .CSV Segmented Data

name = 'SegmentedData.csv';
% name = 'dataResol1_GMaps_38KmRcteVitR1.csv';
%%M = csvread(name);
NAVecoSegData = readmatrix(name,'OutputType','char');
NumSeg = str2double(NAVecoSegData(1:end,1));
LatSeg  = str2double(NAVecoSegData(1:end,2));
LongSeg = str2double(NAVecoSegData(1:end,3));
DistSeg =str2double(NAVecoSegData(1:end,4));
MaxSpeedSeg = str2double(NAVecoSegData(1:end,5));
SlopeSeg = str2double(NAVecoSegData(1:end,6));
AltitudeSeg = str2double(NAVecoSegData(1:end,7));
DureeSeg = str2double(NAVecoSegData(1:end,8));
Distance_absoluteSeg = DistSeg;

figure
plot(Distance_absoluteSeg,NumSeg)
title('Nom Sous segments')
grid on

figure
plot(Distance_absolute,Num)
title('Distance Absolute')
grid on
%% Optimisation

NAVecoSegments = NAVecoSegData;

DistanceTotal = str2num(string(NAVecoSegments(end,4)))
DureeTotal = str2num(string(NAVecoSegments(end,8)))

DureeTotalH = floor(DureeTotal/3600)
DureeTotalM = floor(floor(DureeTotal/60)-floor(DureeTotal/3600)*60)
DureeTotalS = round(DureeTotal-DureeTotalH*3600-DureeTotalM*60,1)
SlopeVect = rad2deg(str2double(NAVecoSegments(:,6)));
round(max(SlopeVect)-min(SlopeVect),1)

SlopeV = [str2double(NAVecoSegments(:,4)) str2double(NAVecoSegments(:,6))];

addpath('OpenLoopFunctions\')    

load('C:\Users\crybelloceferin\Documents\MATLAB\Supun\E3Yesid\Vehicles\P308.mat')
VehicleData = struct('Nom', 'Sky',...
                     'M', M,...
                     'Cr', Cr,...
                     'Rw', Rw,...
                     'g', 9.81,...
                     'Pair', pair,...
                     'SCx', SCx,...
                     'minU', minU,...
                     'maxU',  maxU,...
                     'Ig',  Ig,...
                     'Krpm',  Krpm,...
                     'Ktorq',  Ktorq,...
                     'maxRPM',  maxRPM,...
                     'maxTorq',  maxTorq,...                     
                     'Tech', 'Electrique'); 
                 
load('C:\Users\crybelloceferin\Documents\MATLAB\Supun\E3Yesid\Vehicles\P308.mat')
VehicleData1 = struct('Nom', 'Sky',...
                     'M', M,...
                     'Cr', Cr,...
                     'Rw', Rw,...
                     'g', 9.81,...
                     'Pair', pair,...
                     'SCx', SCx,...
                     'minU', minU,...
                     'maxU',  maxU,...
                     'Ig',  Ig,...
                     'Krpm',  Krpm,...
                     'Ktorq',  Ktorq,...
                     'maxRPM',  maxRPM,...
                     'maxTorq',  maxTorq,...                     
                     'Tech', 'Electrique');
                 
Tech = 'Electrique';

OptimizationData = struct('MinEneBool', 1,...
                          'MaxDisBool', 0,...
                          'MaxVitBool', 0,...
                          'MinTemBool', 0,...
                          'MinEqDistBool', 1,...
                          'MinEqViteBool', 0,...
                          'ConfortBool', 1,...
                          'EnergyFactor', 1,...
                          'DistanceFactor', 1,...
                          'SpeedFactor', 1,...
                          'ConfortFactor', 1e-3);

%%
                      
[th, Xh, Vh, Uh, problem] = OptimisationBO(NAVecoSegments,SlopeV,OptimizationData, VehicleData, max(NumSeg))


MaxSpeed = [str2double(NAVecoSegments(:,4)) str2double(NAVecoSegments(:,5))];
MaxSpeedpchip=pchip(MaxSpeed(:,1),MaxSpeed(:,2));

MaxSpeedTemps = [];
for i = 1:size(Xh,1)
    MaxSpeedTemps = [MaxSpeedTemps ppval(MaxSpeedpchip,Xh(i))];
end

SlopeVect = [str2double(NAVecoSegments(:,4)) str2double(NAVecoSegments(:,6))];
SlopeVectpchip=pchip(SlopeVect(:,1),SlopeVect(:,2));

SlopeVectTemps = [];
for i = 1:size(Xh,1)
    SlopeVectTemps = [SlopeVectTemps ppval(SlopeVectpchip,Xh(i))];
end

figure
subplot(4,1,1)
plot(th,Xh,'k-.' )
xlabel('Time [s]')
ylabel('Distance [m]')
grid on

subplot(4,1,2)
plot(th,SlopeVectTemps,'b-.' )
xlabel('Time [s]')
ylabel('Slope [rad]')
% hold on
% plot(SlopeVFiltre(:,1),rad2deg(SlopeVFiltre(:,2)))
% grid on
title('Pente degrées Filtré')
grid on

subplot(4,1,3)
plot(th,Vh,'k-.' )
hold on
plot(th,MaxSpeedTemps,'r-.' )
grid on

subplot(4,1,4)
plot(th,Uh,'k-.' )
xlabel('Time [s]')
ylabel('Couple [Nm]')
grid on

%%
[th, Xh, Vh, Uh, problem] = OptimisationBO(NAVecoSegments,SlopeV,OptimizationData, VehicleData1, max(NumSeg))

MaxSpeed = [str2double(NAVecoSegments(:,4)) str2double(NAVecoSegments(:,5))];
MaxSpeedpchip=pchip(MaxSpeed(:,1),MaxSpeed(:,2));

MaxSpeedTemps = [];
for i = 1:size(Xh,1)
    MaxSpeedTemps = [MaxSpeedTemps ppval(MaxSpeedpchip,Xh(i))];
end

SlopeVect = [str2double(NAVecoSegments(:,4)) str2double(NAVecoSegments(:,6))];
SlopeVectpchip=pchip(SlopeVect(:,1),SlopeVect(:,2));

SlopeVectTemps = [];
for i = 1:size(Xh,1)
    SlopeVectTemps = [SlopeVectTemps ppval(SlopeVectpchip,Xh(i))];
end

figure
subplot(4,1,1)
plot(th,Xh,'k-.' )
xlabel('Time [s]')
ylabel('Distance [m]')
grid on

subplot(4,1,2)
plot(th,SlopeVectTemps,'b-.' )
xlabel('Time [s]')
ylabel('Slope [rad]')
% hold on
% plot(SlopeVFiltre(:,1),rad2deg(SlopeVFiltre(:,2)))
% grid on
title('Pente degrées Filtré')
grid on

subplot(4,1,3)
plot(th,Vh,'k-.' )
hold on
plot(th,MaxSpeedTemps,'r-.' )
grid on

subplot(4,1,4)
plot(th,Uh,'k-.' )
xlabel('Time [s]')
ylabel('Couple [Nm]')
grid on

RPMwh  = 30*Vh./(Rw*pi);    % RPM de la roue
RPM    = Ig*RPMwh;          % RPM du moteur
RPMopt = maxRPM/3;          % 1/3 de RPM max
u1opt  = (2/5)*maxTorq;     % 2/5 du couple max

if (Tech(1)=='E'||Tech(1)=='H') % Hibrido Pendiente
    effm = 0.9 - ((RPM-RPMopt).^2)*Krpm - ((Uh-u1opt).^2)*Ktorq;
    effr = 0.74 - ((RPM-RPMopt).^2)*Krpm - ((abs(Uh)-u1opt).^2)*Ktorq; 
else
    effm = 0.5 - ((RPM-RPMopt).^2)*Krpm - ((Uh-u1opt).^2)*Ktorq;
    effr = 0 - ((RPM-RPMopt).^2)*Krpm*0 - ((Uh-u1opt).^2)*Ktorq*0;
end

eff=ones(size(Uh));

for i=1:length(Uh)
    if(Uh(i)>0)
        eff(i)=abs(1/effm(i));
        %eff(i)=1/0.8;
    else
        eff(i)=abs(effr(i));
        %eff(i)=0.2;
    end
end

Puissance = Vh.*Uh/Rw;
for i=1:size(Puissance,1) % On est avec un voiture termique
    if Puissance(i)<0
        Puissance(i)=0;
    else
        Puissance(i)=Puissance(i)*eff(i);
    end
end

Energie = cumtrapz(th,Puissance);
Energie = Energie/(3600); % Ws -> Wh

figure
plot(th,Energie,'k-.' )
grid on

Energie(end)

Xh(end)-Distance_absolute(end)

toc
