#
#   This file is part of do-mpc
#
#   do-mpc: An environment for the easy, modular and efficient implementation of
#        robust nonlinear model predictive control
#
#   Copyright (c) 2014-2019 Sergio Lucia, Alexandru Tatulea-Codrean
#                        TU Dortmund. All rights reserved
#
#   do-mpc is free software: you can redistribute it and/or modify
#   it under the terms of the GNU Lesser General Public License as
#   published by the Free Software Foundation, either version 3
#   of the License, or (at your option) any later version.
#
#   do-mpc is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU Lesser General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with do-mpc.  If not, see <http://www.gnu.org/licenses/>.

import numpy as np
from casadi import *
from casadi.tools import *
import pdb
import sys
sys.path.append('../../')
import do_mpc


def vehicule_model(symvar_type='SX'):
    """
    --------------------------------------------------------------------------
    vehicule_model: Variables / D / V
    --------------------------------------------------------------------------
    """
    model_type = 'continuous' # either 'discrete' or 'continuous'
    model = do_mpc.model.Model(model_type, symvar_type)

    # Certain parameters
    #Parametros ctes
    Cr =0.01;  #[N/rad] Coef long delantero asociado al relacion (slip rate) deslizamiento
    Rw =0.3099; #[m] Radio Llanta trasera
    M  =1100; #[kgr] Peso total 165+43.52+25.84 moto+rider_up+rider_down CHECK

    #Parametros ctes entorno
    g    =9.81;  #[m/s2] gravedad.
    pair =1.25; #[Kg/m3] Masa volumetrica aire
    SCx=0.6090;  #Surface * Coef penetracion longitudinal del aire

    # States struct (optimization variables):
    X_s = model.set_variable('_x',  'X_s')  # distance
    V_s = model.set_variable('_x',  'V_s')  # vitesse
    E_s = model.set_variable('_x',  'E_s')  # energie

    # Input struct (optimization variables):
    T = model.set_variable('_u',  'T') # Couple


    alpha   = 0#ppval(SlopeVect,x1);%vdat.Ang;%
    Eff     = 0.75

    Faer = 0.5*pair*SCx*V_s*V_s;
    Frr  = M*g*Cr*cos(alpha);
    Fw   = M*g*sin(alpha);

    # Differential equations
    model.set_rhs('X_s', V_s)
    model.set_rhs('V_s', 1/M*(T/Rw-Faer-Frr-Fw))
    model.set_rhs('E_s', (T/Rw)*V_s*Eff)

    # Build the model
    model.setup()

    return model
