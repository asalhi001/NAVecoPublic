from scipy.integrate import odeint
import numpy as np
import matplotlib.pyplot as plt

T_r = 3
k = 1
r = 1
m = 1
g = 1
R = 1
L = 1

def R_nonlinear(t):
    return R + 8*(1 - np.exp(-t/T_r))

t = np.arange(0, 20, 1e-3)

# this one could be any other function of time
def u_t(t):
    return 0

def f(x, t):
    dx_dt = [0, 0, 0]
    dx_dt[0] = x[1]
    dx_dt[1] = k/(r*m)*x[2]-g
    dx_dt[2] = -R_nonlinear(t)/L*x[2] - k/r*x[1] + 1/L*u_t(t)
    return dx_dt

# y0 is our initial state
s = odeint(f, y0=[0, 0, 0], t=t)

# s is a Nx3 matrix with N timesteps
plt.figure(figsize=(10,4))
plt.plot(t,s)
#plt.fill_between(DistCum,theta_vals_int,alpha=0.1)
plt.ylabel("Position (rad)")
plt.xlabel("Temps (s)")
plt.grid()
plt.show()