import numpy
import math
import matplotlib.pyplot as plt
import scipy.signal
from simple_pid import PID

# Input constants
# Parametros ctes Peugeot 208
Cr =0.01  #[N/rad] Coef long delantero asociado al relacion (slip rate) deslizamiento
Rw =0.61976/2 #[m] Radio Llantas Style vertion
M  =1500  #[kgr] % 208 110 308 1300 508 1500

#Parametros ctes entorno
g    =9.81   #[m/s2] gravedad.
rho  =1.25  #[Kg/m3] Masa volumetrica aire
SCx  =0.24   #Coef aerodinamique 208 0.61 308 0.63 508 0.58

T0 = T = 0
alpha = -0.08726646259971647 #5deg
Eff = 0.7

d0 = d = 0
v0 = v = 0
e0 = e = 0

ts = numpy.linspace(0, 100, 1000)
dt = ts[1]

pid = PID()
pid.sample_time = dt
pid.setpoint = 10
pid.Kp = 2000
pid.Ki = 0.1
pid.Kd = 50000
# pid.tunings = (1.0, 0.2, 0.4)
# pid.output_limits = (0, 10)    # Output value will be between 0 and 10
# pid.output_limits = (0, None)  # Output will always be above 0, but with no upper bound
# pid.auto_mode = False  # No new values will be computed when pid is called
# pid.auto_mode = True   # pid is enabled again
# pid.set_auto_mode(True, last_output=8.0)

vf = 20

ds = []
vs = []
es = []
for t in ts:

    T = pid(v)

    Faer = 0.5*rho*SCx*v**2
    Frr  = M*g*Cr*math.cos(alpha)
    Fw   = M*g*math.sin(alpha)

    dddt = v
    dvdt = (T/Rw-Faer-Frr-Fw)/M
    dedt = (T/Rw)*v*Eff

    v += dvdt*dt
    d += dddt*dt
    e += dedt*dt

    vs.append(v)
    ds.append(d)
    es.append(e)


plt.figure(figsize=(10,4))
plt.plot(ts, ds)
#plt.fill_between(DistCum,theta_vals_int,alpha=0.1)
plt.ylabel("Position (m)")
plt.xlabel("Temps (s)")
plt.grid()
plt.show()

plt.figure(figsize=(10,4))
plt.plot(ts, vs)
#plt.fill_between(DistCum,theta_vals_int,alpha=0.1)
plt.ylabel("Vitesse (m/s)")
plt.xlabel("Temps (s)")
plt.grid()
plt.show()

plt.figure(figsize=(10,4))
plt.plot(ts, es)
#plt.fill_between(DistCum,theta_vals_int,alpha=0.1)
plt.ylabel("Energie (Ws)")
plt.xlabel("Temps (s)")
plt.grid()
plt.show()