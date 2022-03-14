import numpy
import math
import matplotlib.pyplot as plt

# Input constants
# Parametros ctes Peugeot 208
Cr =0.01  #[N/rad] Coef long delantero asociado al relacion (slip rate) deslizamiento
Rw =0.61976/2 #[m] Radio Llantas Style vertion
M  =1500  #[kgr] % 208 110 308 1300 508 1500

#Parametros ctes entorno
g    =9.81   #[m/s2] gravedad.
rho  =1.25  #[Kg/m3] Masa volumetrica aire
SCx  =0.24   #Coef aerodinamique 208 0.61 308 0.63 508 0.58

T = -2
alpha = 0.08726646259971647 #5deg

d0 = d = 0
v0 = v = 30

ts = numpy.linspace(0, 100, 1000)
dt = ts[1]

ds = []
vs = []
for t in ts:

    Faer = 0.5*rho*SCx*v**2
    Frr  = M*g*Cr*math.cos(alpha)
    Fw   = M*g*math.sin(alpha)

    dddt = v
    dvdt = (T/Rw-Faer-Frr-Fw)/M

    v += dvdt*dt
    d += dddt*dt

    vs.append(v)
    ds.append(d)


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
