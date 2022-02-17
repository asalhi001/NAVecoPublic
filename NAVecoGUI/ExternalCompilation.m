close all
clear all
% 
% Departure = 'Expleo, Avenue des Prés, Montigny-le-Bretonneux';
% Arrival   = '1098 Avenue Roger Salengro, Chaville';
% Departure = strrep(Departure,' ','_');
% Arrival   = strrep(Arrival,' ','_');
% 
% command = char(horzcat('python C:\Users\yesid\Documents\Trabajo\EXPLEO\Naveco\GUI\V40Segmentation2Vehicules\|DataGMs.py ',Departure,' ',Arrival,' 5'));
% [status, commandOut] = system(command); 

NAVecoData = readmatrix('saved_data\DataGMs.csv','OutputType','char');

Coordenates  = NAVecoData(3:end,2);

Lat  = str2double(NAVecoData(3:end,2));
Long = str2double(NAVecoData(3:end,3));
Pente = str2double(NAVecoData(3:end,6));

fg = figure;
geoplot(Lat,Long,'g-*')
close(fg)

command = char(horzcat('python C:\Users\crybelloceferin\Documents\MATLAB\GUI\Demostrateur\OpenLoop\V41Segmentation2Vehicules\segmentation.py ','True',' ','True',' ',num2str(deg2rad(2)),' ','True',' ','1000'));
%command = char(horzcat('python C:\Users\yesid\Documents\Trabajo\EXPLEO\Naveco\GUI\V40Segmentation2Vehicules\segmentation.py ','True',' ','True',' ','0.0873',' ','True',' ','1000'));
[status, commandOut] = system(command); 

NAVecoSegments = readmatrix('saved_data\Segments.csv','OutputType','char');

DistanceTotal = str2num(string(NAVecoSegments(end,4)))
DureeTotal = str2num(string(NAVecoSegments(end,8)))

DureeTotalH = floor(DureeTotal/3600)
DureeTotalM = floor(floor(DureeTotal/60)-floor(DureeTotal/3600)*60)
DureeTotalS = round(DureeTotal-DureeTotalH*3600-DureeTotalM*60,1)
SlopeVect = rad2deg(str2double(NAVecoSegments(:,6)));
round(max(SlopeVect)-min(SlopeVect),1)

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
% plot(SlopeVFiltre(:,1),rad2deg(SlopeVFiltre(:,2)))
% grid on

addpath('OpenLoopFunctions\')    

load('C:\Users\crybelloceferin\Documents\MATLAB\GUI\Demostrateur\OpenLoop\V41Segmentation2Vehicules\Vehicles\P308.mat')
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
                 
load('C:\Users\crybelloceferin\Documents\MATLAB\GUI\Demostrateur\OpenLoop\V41Segmentation2Vehicules\Vehicles\P308.mat')
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
                     'Tech', 'Thermique');

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

[th, Xh, Vh, Uh, problem] = OptimisationBO(NAVecoSegments,SlopeVFiltre,OptimizationData, VehicleData, 25)
%%


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
subplot(3,1,1)
plot(th,Xh,'k-.' )
xlabel('Time [s]')
ylabel('Distance [m]')
grid on

subplot(3,1,2)
plot(th,Vh,'k-.' )
hold on
plot(th,MaxSpeedTemps,'r-.' )
hold on
plot(th,SlopeVectTemps*100,'b-.' )
xlabel('Time [s]')
ylabel('Vitesse [m/s]')
grid on

subplot(3,1,3)
plot(th,Uh,'k-.' )
xlabel('Time [s]')
ylabel('Couple [Nm]')
grid on


[th, Xh, Vh, Uh, problem] = OptimisationBO(NAVecoSegments,SlopeVFiltre,OptimizationData, VehicleData1, 25)
%%


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
subplot(3,1,1)
plot(th,Xh,'k-.' )
xlabel('Time [s]')
ylabel('Distance [m]')
grid on

subplot(3,1,2)
plot(th,Vh,'k-.' )
hold on
plot(th,MaxSpeedTemps,'r-.' )
hold on
plot(th,SlopeVectTemps*100,'b-.' )
xlabel('Time [s]')
ylabel('Vitesse [m/s]')
grid on

subplot(3,1,3)
plot(th,Uh,'k-.' )
xlabel('Time [s]')
ylabel('Couple [Nm]')
grid on

