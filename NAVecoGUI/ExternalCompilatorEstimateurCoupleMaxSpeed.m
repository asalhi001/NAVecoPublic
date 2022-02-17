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

command = char(horzcat('python C:\Users\yesid\Documents\Trabajo\EXPLEO\Naveco\GUI\V40Segmentation2Vehicules\segmentation.py ','True',' ','True',' ',num2str(deg2rad(2)),' ','True',' ','1000'));
%command = char(horzcat('python C:\Users\yesid\Documents\Trabajo\EXPLEO\Naveco\GUI\V40Segmentation2Vehicules\segmentation.py ','True',' ','True',' ','0.0873',' ','True',' ','1000'));
[status, commandOut] = system(command); 

NAVecoSegments = readmatrix('saved_data\Segments.csv','OutputType','char');

addpath('OpenLoopFunctions\')  
load('C:\Users\yesid\Documents\Trabajo\EXPLEO\Naveco\GUI\V40Segmentation2Vehicules\Vehicles\P308.mat')
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

OptimizationData = struct('MinEneBool', 0,...
                          'MaxDisBool', 0,...
                          'MaxVitBool', 0,...
                          'MinTemBool', 0,...
                          'MinEqDistBool', 0,...
                          'MinEqViteBool', 1,...
                          'ConfortBool', 1,...
                          'EnergyFactor', 1,...
                          'DistanceFactor', 1,...
                          'SpeedFactor', 1,...
                          'ConfortFactor', 1e-3);

[Uh, Vh, Xh, th] = EstimateurCoupleMaxSpeed(NAVecoSegments,VehicleData,OptimizationData);

%%
% sos = ppval(Atomssos,h);MaxSpeed

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


