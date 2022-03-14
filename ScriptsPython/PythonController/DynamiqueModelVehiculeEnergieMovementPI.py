import numpy
import math
import matplotlib.pyplot as plt
import scipy.signal

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
alpha = 0.08726646259971647 #5deg
Eff = 0.7

d0 = d = 0
v0 = v = 0
e0 = e = 0

ts = numpy.linspace(0, 100, 1000)
dt = ts[1]

Kc = 200
tau_i = 10

Gc = scipy.signal.lti([Kc*tau_i, Kc], [tau_i, 0]).to_ss()

vobj = 20

ds = []
vs = []
es = []
Tc = numpy.zeros([Gc.A.shape[0], 1])
for t in ts:

    e = vobj - v
    dTcdt = Gc.A.dot(Tc) + Gc.B.dot(e)
    yc = Gc.C.dot(Tc) + Gc.D.dot(e)

    T = T0 + yc[0,0]  # T0 is the controller bias

    Faer = 0.5*rho*SCx*v**2
    Frr  = M*g*Cr*math.cos(alpha)
    Fw   = M*g*math.sin(alpha)

    dddt = v
    dvdt = (T/Rw-Faer-Frr-Fw)/M
    dedt = (T/Rw)*v*Eff

    v += dvdt*dt
    d += dddt*dt
    e += dedt*dt

    Tc += dTcdt*dt

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