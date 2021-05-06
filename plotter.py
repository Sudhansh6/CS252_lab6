import matplotlib.pyplot as plt
import numpy as np

L=[]
with open('textfile.txt','r') as f:
    for line in f:
        if(line[-1] != '\n'):
            L.append(float(line))
        else:
            L.append(float(line[:-1]))
print("The mean of these values is %s"% (np.mean(L)))
print("The standard deviation of these values is %s"% (np.std(L)))
x = np.array(range(len(L)))
y = np.array(L)
ci = 0.9 * np.std(y) / np.mean(y)
plt.plot(x, y)
plt.fill_between(x, (y-ci), (y+ci), color='blue', alpha=0.1)
plt.show()