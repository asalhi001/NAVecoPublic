import numpy as np
from scipy import integrate
import matplotlib.pyplot as plt

# Input constants
m = 1 # mass (kg)
L = 1 # length (m)
b = 0 # damping value (kg/m^2-s)
g = 9.81 # gravity (m/s^2)
delta_t = 0.02 # time step size (seconds)
t_max = 10 # max sim time (seconds)
theta1_0 = np.pi/2 # initial angle (radians)
theta2_0 = 0 # initial angular velocity (rad/s)
theta_init = (theta1_0, theta2_0)
# Get timesteps
t = np.linspace(0, t_max, int(t_max/delta_t))

def int_pendulum_sim(theta_init, t, L=1, m=1, b=0, g=9.81):
    theta_dot_1 = theta_init[1]
    theta_dot_2 = -b/m*theta_init[1] - g/L*np.sin(theta_init[0])
    return theta_dot_1, theta_dot_2

theta_vals_int = integrate.odeint(int_pendulum_sim, theta_init, t)

def euler_pendulum_sim(theta_init, t, L=1, g=9.81):
    theta1 = [theta_init[0]]
    theta2 = [theta_init[1]]
    dt = t[1] - t[0]
    for i, t_ in enumerate(t[:-1]):
        next_theta1 = theta1[-1] + theta2[-1] * dt
        next_theta2 = theta2[-1] - (b/(m*L**2) * theta2[-1] - g/L *
            np.sin(next_theta1)) * dt
        theta1.append(next_theta1)
        theta2.append(next_theta2)
    return np.stack([theta1, theta2]).T

theta_vals_euler = euler_pendulum_sim(theta_init, t)

mse_pos = np.power(
    theta_vals_int[:,0] - theta_vals_euler[:,0], 2).mean()
mse_vel = np.power(
    theta_vals_int[:,1] - theta_vals_euler[:,1], 2).mean()
print("MSE Position:\t{:.4f}".format(mse_pos))
print("MSE Velocity:\t{:.4f}".format(mse_vel))


plt.figure(figsize=(10,4))
plt.plot(t,theta_vals_int)
#plt.fill_between(DistCum,theta_vals_int,alpha=0.1)
plt.ylabel("Position (rad)")
plt.xlabel("Temps (s)")
plt.grid()
plt.show()