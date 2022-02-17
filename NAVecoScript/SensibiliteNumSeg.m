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

OrdreFiltre = 72; %Entre 50 y 100 (Optimum 66/72)
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

%% 

%SegmentData(seg_speed_ext, seg_slope_ext, seg_slope_sample, constant_slope_ext, duration_user)
SegmentData('True', 'True', num2str(deg2rad(1)), 'True', num2str(1000))

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


%%

DatabaseNumSeg = [];

pause(0.5)

%% Iterations

for i=0.2:0.2:5
    SegmentData('True', 'True', num2str(deg2rad(i)), 'True', num2str(1000))

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


    data.dist = Distance_absolute;
    data.slop = Slope;
    data.Altt = Altitude;

    data.distAbs = Distance_absoluteSeg;
    data.NumSegm = NumSeg;

    DatabaseNumSeg = [DatabaseNumSeg data];
    
    i
    
end

% save('DatabaseNumSeg.mat', 'DatabaseNumSeg');
% load('DatabaseNumSeg.mat', 'DatabaseNumSeg');

%% Comparatif

%Variables: 
%     Alt Slope Dist
%     Dist NumSeg

NumSeg_V   = [];

for i=1:size(DatabaseNumSeg,2)
    
    NumSeg_V   = [NumSeg_V DatabaseNumSeg(i).NumSegm(end)];
end

%% Plots

figure
plot([0.2:0.2:5],NumSeg_V)
grid on
xlabel('Pente maximale pour segmentation [rad]')
ylabel('NUm de segmentes [-]')


