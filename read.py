
import os
from mpl_toolkits.mplot3d import Axes3D
import matplotlib.pylab as plt
import numpy  as np
from matplotlib import cm 
import math

a=['1024','2048','4096','8192','16384','32768','65536','131072','262144','524288','10485760']
c=['0','1']
X=[10,11,12,13,14,15,16,17,18,19,20]
Y=[5,9,13,17,21]
Z1 = np.zeros([11])
#for k in range(0,2):
for i in range(0,11):
    li = ['./p53',' ',a[i]]
    main = ''.join(li)  
    f = os.popen(main) 
    data = f.readline()
    data = f.readline(9)
    f.close
    print (data)
    Z1[i]=float(data)


Z=[math.log(a,2) for a in Z1]
plot1 = plt.plot(X,Z)
plt.xlabel('log_2(npartitions)')
plt.ylabel('log_2(t)')#plt.zlabel('t_s/t_0')
plt.show()