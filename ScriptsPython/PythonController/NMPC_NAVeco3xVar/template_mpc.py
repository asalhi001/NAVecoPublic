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


def template_mpc(model,Objective):
    """
    --------------------------------------------------------------------------
    template_mpc: tuning parameters
    --------------------------------------------------------------------------
    """
    mpc = do_mpc.controller.MPC(model)

    setup_mpc = {
        'n_horizon': 5,
        'n_robust': 0,
        'open_loop': 0,
        't_step': 0.1,
        'state_discretization': 'collocation',
        'collocation_type': 'radau',
        'collocation_deg': 2,
        'collocation_ni': 2,
        'store_full_solution': True,
        # Use MA27 linear solver in ipopt for faster calculations:
        #'nlpsol_opts': {'ipopt.linear_solver': 'MA27'}
    }

    mpc.set_param(**setup_mpc)

    # mterm = (model.x['E_s'])
    mterm = ((model.x['X_s']-Objective)**2)*1e6
    lterm = ((model.x['X_s']-Objective)**2)*1e6

    mpc.set_objective(mterm=mterm, lterm=lterm)
    mpc.set_rterm(T=0) #Penalisation de l'entre


    mpc.bounds['lower', '_x', 'X_s'] = 0.0
    mpc.bounds['lower', '_x', 'V_s'] = 0.0
    mpc.bounds['lower', '_x', 'E_s'] = 0.0

    mpc.bounds['upper', '_x','X_s'] = 300000
    mpc.bounds['upper', '_x','V_s'] = 10.0
    mpc.bounds['upper', '_x','E_s'] = 10000000000000.0

    mpc.bounds['lower','_u','T'] = -1000.0
    mpc.bounds['upper','_u','T'] = 1000.0

    # Scaling states
    # Uncertainties

    mpc.setup()

    return mpc
