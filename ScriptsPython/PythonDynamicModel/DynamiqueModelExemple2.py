import numpy
import matplotlib.pyplot as plt


A = 2
alpha = 20
K = 2

Fin = 1
h = 1
V = A*h
x0 = x = 0.7

def f(x):
    return alpha**(x - 1)

ts = numpy.linspace(0, 100, 1000)
dt = ts[1]

hs = []
for t in ts:
    h = V/A
    Fout = K*f(x)*numpy.sqrt(h)
    dVdt = Fin - Fout
    V += dVdt*dt

    hs.append(h)


plt.figure(figsize=(10,4))
plt.plot(ts, hs)
#plt.fill_between(DistCum,theta_vals_int,alpha=0.1)
plt.ylabel("Position (rad)")
plt.xlabel("Temps (s)")
plt.grid()
plt.show()