% Vehicle 1

%Parametros ctes Peugeot 208
Cr = 0.01;  %[N/rad] Coef long delantero asociado al relacion (slip rate) deslizamiento
Rw = 0.580; %Rayon de la roue
M  = 1100; %[kgr] % 208 110 308 1300 508 1500

%Parametros ctes entorno
g    =9.81;  %[m/s2] gravedad.
pair =1.25; %[Kg/m3] Masa volumetrica aire
SCx  =2.1*0.29;  %Coef aerodinamique 208 0.61 308 0.63 508 0.58

Photo= 'P208';
Elect= 1; %1 Electrique, 2 Thermique, 3 Hybride

save('Peugeot208.mat')