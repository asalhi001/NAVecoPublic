function [problem,guess] = DoubleIntegratorTracking
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

%Parametros ctes Moto
Cr =0.01;  %[N/rad] Coef long delantero asociado al relacion (slip rate) deslizamiento
Rw =0.61976/2; %[m] Radio Llanta trasera
M  =1500; %[kgr] Peso total 165+43.52+25.84 moto+rider_up+rider_down CHECK

%Parametros ctes entorno
grav =9.81;  %[m/s2] gravedad.
pair =1.25; %[Kg/m3] Masa volumetrica aire
Cxair=0.29;  %Coef penetracion longitudinal del aire CHECK
Supf =2.1;   %[m2] 

Ang  =deg2rad(0);    %[°] degrees OpPorc = tan(deg2rad(10))*100 6°max

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
problem.time.tf_min=80;     
problem.time.tf_max=80; 
guess.tf=80;

% Parameters bounds. pl=< p <=pu
problem.parameters.pl=[];
problem.parameters.pu=[];
guess.parameters=[];

% Initial conditions for system.
problem.states.x0=[0 0];

% Initial conditions for system. Bounds if x0 is free s.t. x0l=< x0 <=x0u
problem.states.x0l=[0 0]; 
problem.states.x0u=[0 0]; 

% State bounds. xl=< x <=xu
problem.states.xl=[0 0];
problem.states.xu=[inf 23];

% State error bounds
problem.states.xErrorTol_local=[1e-1 1e-1];
problem.states.xErrorTol_integral=[1e-1 1e-1];


% State constraint error bounds
problem.states.xConstraintTol=[1e-1 1e-1];

% Terminal state bounds. xfl=< xf <=xfu
problem.states.xfl=[0 0];
problem.states.xfu=[inf 23];

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
problem.inputs.ul=-1000;
problem.inputs.uu=1000;

% Bounds on the first control action
problem.inputs.u0l=-1000;
problem.inputs.u0u=1000;

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

problem.constraints.gl=[];
problem.constraints.gu=[];
problem.constraints.gTol_neq=[];

% Bounds for boundary constraints bl =< b(x0,xf,u0,uf,p,t0,tf) =< bu
problem.constraints.bl=[];
problem.constraints.bu=[];
problem.constraints.bTol=[];

% store the necessary problem parameters used in the functions
% problem.data=[];
problem.data.Cr    = Cr; % [lb]
problem.data.Rw    = Rw; % [lb]
problem.data.grav  = grav; % [lb]
problem.data.M     = M; % [lb]
problem.data.pair  = pair; % [lb]
problem.data.Cxair = Cxair; % [lb]
problem.data.Supf  = Supf; % [lb]
problem.data.Ang  = Ang; % [lb]

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

%------------- BEGIN CODE --------------

x1 = x(:,1);
x2 = x(:,2);

u1=u(:,1);

Rw    = vdat.Rw;
RPM   = x2./(Rw*0.10472);
RPMopt = 15/(Rw*0.10472); % Hipothese v optimale

eff = 0.9 - ((RPM-RPMopt).^2)/1.8e6 - ((u1-300).^2)/1e6;

%e1=x1-1000;
e1=x1-1000;
e3=x2-23;

for i=1:length(u1)
    if(u1(i)>0)
        %eff(i)=1/eff(i);
        eff(i)=1/0.85;
    else
        eff(i)=0.0;
    end
end

e2=(x2.*u1).*eff;
%e2=(x2.*u1);

stageCost = e1.*e1 + e2 + u1.*u1.*1e-1; %This one!!!!
%stageCost = e3.*e3;
%stageCost = e1.*e1 + e2 ;
%stageCost = e1.*e1 + u1.*u1.*1e-1;
%stageCost = e1.*e1 + eff;

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
