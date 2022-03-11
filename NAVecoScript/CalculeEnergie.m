function [E,T] = CalculeEnergie(ProfT,ProfV,ProfA,ProfPente)

%% Calculo del Torque
Torq=[];

%ForceHist
FaHist=[];
FwHist=[];
FrHist=[];

%Selection du vehicule:

value = 2;
% 1 Peogeut 208 1.2L (2020)
% 2 Peogeut 308 1.2L (2019)
% 3 Peogeut 508 1.5L (2019)

    Rwr_v    = [0.580 0.580 0.580]; %[m]
    Cair_v   = [0.29 0.28 0.25];
    Supf_v   = [2.1 2.25 2.32];
    M_v      = [1500 1550+90 1400];
    Miur0_v  = [0.01 0.01 0.01];   %[0.01 0.008]Very good concrete
    Eff_v    = [0.2 0.22 0.27];%[0.2 0.16 0.27];
    
    pair   = 1.25;
    g      = 9.81;
    Miur1  = 4e-8;

    Rwr    = Rwr_v(value); %[m]
    Cair   = Cair_v(value);
    Supf   = Supf_v(value);
    M      = M_v(value);
    Miur0  = Miur0_v(value);   %[0.01 0.008]Very good concrete
    Miur   = Miur0;
    Eff    = Eff_v(value);
    
for i=1:max(size(ProfT,1),size(ProfT,2))
    Torq=[Torq   Rwr*(M*ProfA(i) +  M*g*ProfPente(i)  +  0.5*pair*Cair*Supf*ProfV(i)^2  +  M*g*Miur)];

    FaHist=[FaHist 0.5*pair*Cair*Supf*ProfV(i)^2];
    FwHist=[FwHist M*g*ProfPente(i)];
    FrHist=[FrHist M*g*Miur];
end

Puissance = ProfV.*Torq'/Rwr;
for i=1:size(Puissance,1) % On est avec un voiture termique
    if Puissance(i)<0
        Puissance(i)=0;
    else
        Puissance(i)=Puissance(i)/Eff;
    end
end

Energie = cumtrapz(ProfT,Puissance);

% plot(ProfT,Energie)
% title('Energie - Sist Long')
% grid on
% xlabel('Time [s]');ylabel('Energie [Ws]')

E = Energie;
T = Torq;
end