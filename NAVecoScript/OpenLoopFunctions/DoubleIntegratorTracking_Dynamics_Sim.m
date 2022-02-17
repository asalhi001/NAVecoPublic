function dx = DoubleIntegratorTracking_Dynamics_Sim(x,u,p,t,vdat)
%Double Integrator Dynamics for Simulation
%
% Syntax:  
%          [dx] = Dynamics(x,u,p,t,vdat)
% 
% Inputs:
%    x  - state vector
%    u  - input
%    p  - parameter
%    t  - time
%    vdat - structured variable containing the values of additional data used inside
%          the function%      
% Output:
%    dx - time derivative of x
%
%------------- BEGIN CODE --------------

SlopeVect = vdat.SlopeVect;

Cr    = vdat.Cr; 
Rw    = vdat.Rw; 
grav  = vdat.grav;
M     = vdat.M; 
pair  = vdat.pair; 
Cxair = vdat.Cxair; 
Supf  = vdat.Supf;  

x1 = x(:,1);
x2 = x(:,2);

Ang   = ppval(SlopeVect,x1);%vdat.Ang; 

u1 = u(:,1);

Faer = 0.5*pair*Cxair*Supf*x2.*x2; %Pendiente encontrar relacion entre direction del viento y del vehiculo.
Frr  = M*grav*Cr*cos(Ang);
Fw   = M*grav*sin(Ang);

dx(:,1) = x2;
dx(:,2) = 1/M.*(u1/Rw-Faer-Frr-Fw);

%------------- END OF CODE --------------