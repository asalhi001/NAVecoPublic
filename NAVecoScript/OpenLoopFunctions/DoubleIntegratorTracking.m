function [problem,guess] = DoubleIntegratorTracking(OptimizationData ,TrajectData, VehicleData)
%DoubleIntergratorTracking - Double Integrator Tracking Problem
%
% Syntax:  [problem,guess] = DoubleIntergratorTracking
%
% Outputs:
%    problem - Structure with information on the optimal control problem
%    guess   - Guess for state, control and multipliers.
%
% Other m-files required: none
% MAT-files required: none

%------------- BEGIN CODE --------------

MaxSpeed  = TrajectData.MaxSpeed;
SlopeVect = TrajectData.SlopeVect;

if(length(MaxSpeed(:,1))>1)
    MaxSpeedpchip=pchip(MaxSpeed(:,1),MaxSpeed(:,2));
    SlopeVectpchip=pchip(SlopeVect(:,1),SlopeVect(:,2));
else
    MaxSpeedpchip=pchip([MaxSpeed(:,1) MaxSpeed(:,1)+4],[MaxSpeed(:,2) MaxSpeed(:,2)]);
    SlopeVectpchip=pchip([SlopeVect(:,1) SlopeVect(:,1)+4],[SlopeVect(:,2) SlopeVect(:,2)]);
end

%Parametros ctes Moto
Cr = VehicleData.Cr;   %0.01;  %[N/rad] Coef long delantero asociado al relacion (slip rate) deslizamiento
Rw = VehicleData.Rw;   %0.61976/2; %[m] Radio Llanta trasera
M  = VehicleData.M;    %1500; %[kgr] Peso total 165+43.52+25.84 moto+rider_up+rider_down CHECK

%Parametros ctes entorno
grav = VehicleData.g;    %9.81;  %[m/s2] gravedad.
pair = VehicleData.Pair;    %1.25; %[Kg/m3] Masa volumetrica aire
Cxair= VehicleData.SCx;    %0.11;  %Coef penetracion longitudinal del aire CHECK
Supf = 1; %SCx = S*Cx    %2.2;   %[m2] 

Ang  =deg2rad(TrajectData.Slope);    %[°]

minU= VehicleData.minU;
maxU= VehicleData.maxU;
Ig= VehicleData.Ig;
Krpm= VehicleData.Krpm;
Ktorq= VehicleData.Ktorq;
maxRPM= VehicleData.maxRPM;
maxTorq= VehicleData.maxTorq;
Tech= VehicleData.Tech;

% Plant model name, used for Adigator
InternalDynamics=@DoubleIntegratorTracking_Dynamics_Internal;
SimDynamics=@DoubleIntegratorTracking_Dynamics_Sim;

% Analytic derivative files (optional)
% problem.analyticDeriv.gradCost=[];
% problem.analyticDeriv.hessianLagrangian=[];
% problem.analyticDeriv.jacConst=[];

% Settings file
problem.settings=@settings_DoubleIntegratorTracking;

%Initial Time. t0<tf
problem.time.t0_min=0;
problem.time.t0_max=0;
guess.t0=0;

% Final time. Let tf_min=tf_max if tf is fixed.
problem.time.tf_min=TrajectData.Duration;     
problem.time.tf_max=TrajectData.Duration; 
guess.tf=TrajectData.Duration;

% Parameters bounds. pl=< p <=pu
problem.parameters.pl=[];
problem.parameters.pu=[];
guess.parameters=[];

% Initial conditions for system.
problem.states.x0=[0 0];

% Initial conditions for system. Bounds if x0 is free s.t. x0l=< x0 <=x0u
problem.states.x0l=[0 TrajectData.InitSpeed]; 
problem.states.x0u=[0 TrajectData.InitSpeed]; 

% State bounds. xl=< x <=xu
problem.states.xl=[0 0]; %
problem.states.xu=[inf TrajectData.MaxSpeedT];

% State error bounds
problem.states.xErrorTol_local=[1e-1 1e-1];
problem.states.xErrorTol_integral=[1e-1 1e-1];


% State constraint error bounds
problem.states.xConstraintTol=[1e-1 1e-1];

% Terminal state bounds. xfl=< xf <=xfu
problem.states.xfl=[0 TrajectData.FinalSpeed]; %TrajectData.MinSpeedC FinalSpeed
problem.states.xfu=[inf inf];

% Guess the state trajectories with [x0 xf]
guess.time=[0 guess.tf/4 guess.tf/3 guess.tf/2 guess.tf];
guess.states(:,1)=[0 5 5 5 3];
guess.states(:,2)=[5 0 1 1 5];

% Residual Error Scale
% problem.states.ResErrorScale
% problem.states.resCusWeight

% Number of control actions N 
% Set problem.inputs.N=0 if N is equal to the number of integration steps.  
% Note that the number of integration steps defined in settings.m has to be divisible 
% by the  number of control actions N whenever it is not zero.
problem.inputs.N=0;       
      
% Input bounds
problem.inputs.ul=minU; %-982 = (1500*-0.2*9.81-0.5*1.25*0.11*2.2*23*23-1500*9.81*0.01*cos(0)- 1500*9.81*sin(0))*0.61976/2
problem.inputs.uu=maxU;

% Bounds on the first control action
problem.inputs.u0l=minU;
problem.inputs.u0u=maxU;

% Input constraint error bounds
problem.inputs.uConstraintTol=[0.1];

% Guess the input sequences with [u0 uf]
guess.inputs(:,1)=[0 0 0 0 0];



% Choose the set-points if required
problem.setpoints.states=[];
problem.setpoints.inputs=[];

% Bounds for path constraint function gl =< g(x,u,p,t) =< gu
problem.constraints.ng_eq=0;
problem.constraints.gTol_eq=[];

problem.constraints.gl=[0];
problem.constraints.gu=[inf];
problem.constraints.gTol_neq=[0.00001];

% Bounds for boundary constraints bl =< b(x0,xf,u0,uf,p,t0,tf) =< bu
problem.constraints.bl=[];
problem.constraints.bu=[];
problem.constraints.bTol=[];

% store the necessary problem parameters used in the functions
% problem.data=[];
problem.data.MaxSpeed    = MaxSpeedpchip;
problem.data.SlopeVect    = SlopeVectpchip;

problem.data.Cr    = Cr; % [lb]
problem.data.Rw    = Rw; % [lb]
problem.data.grav  = grav; % [lb]
problem.data.M     = M; % [lb]
problem.data.pair  = pair; % [lb]
problem.data.Cxair = Cxair; % [lb]
problem.data.Supf  = Supf; % [lb]
problem.data.Ang  = Ang; % [lb]
problem.data.Ig  = Ig; % [lb]
problem.data.Krpm  = Krpm; % [lb]
problem.data.Ktorq  = Ktorq; % [lb]
problem.data.maxRPM  = maxRPM; % [lb]
problem.data.maxTorq  = maxTorq; % [lb]
problem.data.Tech  = Tech; % [lb]

problem.data.MinEneBool  = OptimizationData.MinEneBool; % [lb]
problem.data.MaxDisBool  = OptimizationData.MaxDisBool; % [lb]
problem.data.MaxVitBool  = OptimizationData.MaxVitBool; % [lb]
problem.data.MinTemBool  = OptimizationData.MinTemBool; % [lb]
problem.data.MinEqDistBool  = OptimizationData.MinEqDistBool; % [lb]
problem.data.MinEqViteBool  = OptimizationData.MinEqViteBool; % [lb]
problem.data.ConfortBool  = OptimizationData.ConfortBool; % [lb]
problem.data.EnergyFactor  = OptimizationData.EnergyFactor; % [lb]
problem.data.DistanceFactor  = OptimizationData.DistanceFactor; % [lb]
problem.data.SpeedFactor  = OptimizationData.SpeedFactor; % [lb]
problem.data.ConfortFactor  = OptimizationData.ConfortFactor; % [lb]
problem.data.Distance  = TrajectData.Distance; % [lb]
problem.data.Duration  = TrajectData.Duration; % [lb] 
problem.data.OptSpeed  = TrajectData.OptSpeed; % [lb]

% Get function handles and return to Main.m
problem.data.InternalDynamics=InternalDynamics;
problem.data.functionfg=@fg;
problem.data.plantmodel = func2str(InternalDynamics);
problem.functions={@L,@E,@f,@g,@avrc,@b};
problem.sim.functions=SimDynamics;
problem.sim.inputX=[];
problem.sim.inputU=1:length(problem.inputs.ul);
problem.functions_unscaled={@L_unscaled,@E_unscaled,@f_unscaled,@g_unscaled,@avrc,@b_unscaled};
problem.data.functions_unscaled=problem.functions_unscaled;
problem.data.ng_eq=problem.constraints.ng_eq;
problem.constraintErrorTol=[problem.constraints.gTol_eq,problem.constraints.gTol_neq,problem.constraints.gTol_eq,problem.constraints.gTol_neq,problem.states.xConstraintTol,problem.states.xConstraintTol,problem.inputs.uConstraintTol,problem.inputs.uConstraintTol];

%------------- END OF CODE --------------

function stageCost=L_unscaled(x,xr,u,ur,p,t,vdat)

% L_unscaled - Returns the stage cost.
% The function must be vectorized and
% xi, ui are column vectors taken as x(:,i) and u(:,i) (i denotes the i-th
% variable)
% 
% Syntax:  stageCost = L(x,xr,u,ur,p,t,data)
%
% Inputs:
%    x  - state vector
%    xr - state reference
%    u  - input
%    ur - input reference
%    p  - parameter
%    t  - time
%    data- structured variable containing the values of additional data used inside
%          the function
%
% Output:
%    stageCost - Scalar or vectorized stage cost
%
%  Remark: If the stagecost does not depend on variables it is necessary to multiply
%          the assigned value by t in order to have right vector dimesion when called for the optimization. 
%          Example: stageCost = 0*t;

% Parameter Load

Rw = vdat.Rw;   %0.61976/2; %[m] Radio Llanta trasera

Ig     = vdat.Ig;
Krpm   = vdat.Krpm;
Ktorq  = vdat.Ktorq;
maxRPM = vdat.maxRPM;
maxTorq= vdat.maxTorq;
Tech   = vdat.Tech;

b_e   = vdat.MinEneBool; % [lb]
b_dM  = vdat.MaxDisBool; % [lb]
b_vM  = vdat.MaxVitBool; % [lb]
b_t   = vdat.MinTemBool; % [lb]
b_dE  = vdat.MinEqDistBool; % [lb]
b_vE  = vdat.MinEqViteBool; % [lb]
b_c  = vdat.ConfortBool; % [lb]

F_e   = vdat.EnergyFactor; % [lb]
F_d   = vdat.DistanceFactor; % [lb]
F_v   = vdat.SpeedFactor; % [lb]
F_c   = vdat.ConfortFactor; % 

%------------- BEGIN CODE --------------

x1 = x(:,1);
x2 = x(:,2);

Ref_d   = vdat.Distance; % [lb]
Ref_v   = vdat.OptSpeed; % [lb]
% MaxSpeed  = vdat.MaxSpeed;
% Ref_v     = ppval(MaxSpeed,x1);
Ref_t   = vdat.Duration; % 

u1=u(:,1);

RPMwh  = 30*x2./(Rw*pi);    % RPM de la roue
RPM    = Ig*RPMwh;     % RPM du moteur
RPMopt = maxRPM/3;            % 1/3 de RPM max
u1opt  = (2/5)*maxTorq;         % 2/5 du couple max

if (Tech(1)=='E'||Tech(1)=='H') % Hibrido Pendiente
    effm = 0.9 - ((RPM-RPMopt).^2)*Krpm - ((u1-u1opt).^2)*Ktorq;
    effr = 0.74 - ((RPM-RPMopt).^2)*Krpm - ((abs(u1)-u1opt).^2)*Ktorq; 
else
    effm = 0.5 - ((RPM-RPMopt).^2)*Krpm - ((u1-u1opt).^2)*Ktorq;
    effr = 0 - ((RPM-RPMopt).^2)*0 - ((abs(u1)-u1opt).^2)*0; 
end

eff=ones(size(u1));

for i=1:length(u1)
    if(u1(i)>0)
        eff(i)=abs(1/effm(i));
        %eff(i)=1/0.8;
    else
        eff(i)=abs(effr(i));
        %eff(i)=0.2;
    end
end

x1 = x(:,1);
x2 = x(:,2);
x3 = (u1.*RPM*pi/30).*eff;

e1eq=x1-Ref_d;
e2eq=x2-Ref_v;
e1  =x1;
e2  =x2;
e3  =x3;

% e1=x1-1000;
% e2=(x2.*u1).*eff;
% stageCost = e1.*e1+1e-3*e2+u1.*u1.*1e-5;

stageCost = F_d.*1e6.*(-b_dM.*e1 + b_dE.*e1eq.*e1eq)+...
            F_v.*1e5.*(-b_vM.*e2 + b_vE.*e2eq.*e2eq)+...
            F_e.*1e0.*(b_e.*e3)+...
            F_c.*1e2.*(b_c.*u1.*u1);

%------------- END OF CODE --------------


function boundaryCost=E_unscaled(x0,xf,u0,uf,p,t0,tf,data) 

% E_unscaled - Returns the boundary value cost
%
% Syntax:  boundaryCost=E_unscaled(x0,xf,u0,uf,p,t0,tf,data) 
%
% Inputs:
%    x0  - state at t=0
%    xf  - state at t=tf
%    u0  - input at t=0
%    uf  - input at t=tf
%    p   - parameter
%    tf  - final time
%    data- structured variable containing the values of additional data used inside
%          the function
%
% Output:
%    boundaryCost - Scalar boundary cost
%
%------------- BEGIN CODE --------------

boundaryCost= 0;

%------------- END OF CODE --------------


function bc=b_unscaled(x0,xf,u0,uf,p,t0,tf,vdat,varargin)

% b_unscaled - Returns a column vector containing the evaluation of the boundary constraints: bl =< bf(x0,xf,u0,uf,p,t0,tf) =< bu
%
% Syntax:  bc=b_unscaled(x0,xf,u0,uf,p,t0,tf,vdat,varargin)
%
% Inputs:
%    x0  - state at t=0
%    xf  - state at t=tf
%    u0  - input at t=0
%    uf  - input at t=tf
%    p   - parameter
%    tf  - final time
%    data- structured variable containing the values of additional data used inside
%          the function
%
%          
% Output:
%    bc - column vector containing the evaluation of the boundary function 
%
%------------- BEGIN CODE --------------
varargin=varargin{1};
bc=[];
%------------- END OF CODE --------------
% When adpative time interval add constraint on time
%------------- BEGIN CODE --------------
if length(varargin)==2
    options=varargin{1};
    t_segment=varargin{2};
    if ((strcmp(options.discretization,'hpLGR')) || (strcmp(options.discretization,'globalLGR')))  && options.adaptseg==1 
        if size(t_segment,1)>size(t_segment,2)
            bc=[bc;diff(t_segment)];
        else
            bc=[bc,diff(t_segment)];
        end
    end
end

%------------- END OF CODE --------------
