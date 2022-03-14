import numpy as np
import matplotlib.pyplot as plt
from casadi import *
from casadi.tools import *
import pdb
import sys
sys.path.append('C:/Users/crybelloceferin/Documents/MATLAB/BoubacarDIALLO/PythonController/NMPC_NAVeco3xVar')
import do_mpc

import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
import time

from vehicule_model import vehicule_model
from template_mpc import template_mpc
from template_simulator import template_simulator

""" User settings: """
show_animation = True
store_results = False

DistObj = 250

"""
Get configured do-mpc modules:
"""

model = vehicule_model()
mpc = template_mpc(model,DistObj)
simulator = template_simulator(model)
estimator = do_mpc.estimator.StateFeedback(model)

"""
Set initial state
"""

X_s_0 = 0 # Distance Initielle
V_s_0 = 0 # Vitesse Initielle
E_s_0 = 0 # Vitesse Initielle
x0 = np.array([X_s_0, V_s_0, E_s_0])

xs = []
vs = []
es = []
us = []


mpc.x0 = x0
simulator.x0 = x0
estimator.x0 = x0

mpc.set_initial_guess()

"""
Setup graphic:
"""

# fig, ax, graphics = do_mpc.graphics.default_plot(mpc.data, figsize=(8,5))
# plt.ion()

"""
Run MPC main loop:
"""

for k in range(350):
    u0 = mpc.make_step(x0)
    y_next = simulator.make_step(u0)
    x0 = estimator.make_step(y_next)

    xs.append(float(x0[0]))
    vs.append(float(x0[1]))
    es.append(float(x0[2]))
    us.append(float(u0))


    # if show_animation:
    #     graphics.plot_results(t_ind=k)
    #     graphics.plot_predictions(t_ind=k)
    #     graphics.reset_axes()
    #     plt.show()
    #     plt.pause(0.01)

# input('Press any key to exit.')

# Store results:
# if store_results:
#     do_mpc.data.save_results([mpc, simulator], 'vehicule_MPC')

plt.figure(figsize=(10,4))
plt.plot(xs)
#plt.fill_between(DistCum,theta_vals_int,alpha=0.1)
plt.ylabel("Distance (m)")
plt.xlabel("Temps (s)")
plt.grid()
plt.show()

plt.figure(figsize=(10,4))
plt.plot(vs)
#plt.fill_between(DistCum,theta_vals_int,alpha=0.1)
plt.ylabel("Vitesse (m/s)")
plt.xlabel("Temps (s)")
plt.grid()
plt.show()

plt.figure(figsize=(10,4))
plt.plot(es)
#plt.fill_between(DistCum,theta_vals_int,alpha=0.1)
plt.ylabel("Energie (Ws)")
plt.xlabel("Temps (s)")
plt.grid()
plt.show()

plt.figure(figsize=(10,4))
plt.plot(us)
#plt.fill_between(DistCum,theta_vals_int,alpha=0.1)
plt.ylabel("Couple (Nm)")
plt.xlabel("Temps (s)")
plt.grid()
plt.show()
