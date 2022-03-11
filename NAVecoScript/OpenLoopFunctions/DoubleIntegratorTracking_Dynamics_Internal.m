function [dx,g_neq] = DoubleIntegratorTracking_Dynamics_Internal(x,u,p,t,vdat)
% Double Integrator Dynamics - Internal
%
% Syntax:  
%          [dx] = Dynamics(x,u,p,t,vdat)	(Dynamics Only)
%          [dx,g_eq] = Dynamics(x,u,p,t,vdat)   (Dynamics and Eqaulity Path Constraints)
%          [dx,g_neq] = Dynamics(x,u,p,t,vdat)   (Dynamics and Inqaulity Path Constraints)
%          [dx,g_eq,g_neq] = Dynamics(x,u,p,t,vdat)   (Dynamics, Equality and Ineqaulity Path Constraints)
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
%    g_eq - constraint function for equality constraints
%    g_neq - constraint function for inequality constraints
%
%------------- BEGIN CODE --------------
MaxSpeed  = vdat.MaxSpeed; 
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
u1 = u(:,1);

Ang   = ppval(SlopeVect,x1);%vdat.Ang;% 

Faer = 0.5*pair*Cxair*Supf*x2.*x2; %Pendiente encontrar relacion entre direction del viento y del vehiculo.
Frr  = M*grav*Cr*cos(Ang);
Fw   = M*grav*sin(Ang);

dx(:,1) = x2;
dx(:,2) = 1/M.*(u1/Rw-Faer-Frr-Fw);

MaxSpeedTemp = ppval(MaxSpeed,x1);

g_neq=MaxSpeedTemp-x2;
%g_neq=u1/Rw-M*(-0.2*grav)-Faer-Frr-Fw;

%------------- END OF CODE --------------