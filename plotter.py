import matplotlib.pyplot as plt
import numpy as np
 
reno=[]
cubic=[]
counter = 0
delay = ""
loss = ""
renotp_mean = []
cubictp_mean = []
renotp_std = []
cubictp_std = []
with open('textfile.txt','r') as f:
    for line in f:
        if(counter%3 == 0):
            reno=[]
            cubic=[]
            L = line[:-1].split(" ")
            delay = L[1]
            loss = L[3]
        elif(counter%3 == 1):
            if (line[-1] == '\n'):
                reno = line[9:-1].split(" ")
                reno = [float(i) for i in reno]
            else:
                reno = line[9:].split(" ")
                reno = [float(i) for i in reno]
        elif(counter%3 == 2):
            if (line[-1] == '\n'):
                cubic = line[10:-1].split(" ")
                cubic = [float(i) for i in cubic]
            else:
                cubic = line[10:].split(" ")
                cubic = [float(i) for i in cubic]
        counter = counter + 1
        if(counter%3 == 0):
            renotp_mean.append(np.mean(reno))
            renotp_std.append(np.std(reno))
            cubictp_mean.append(np.mean(cubic))
            cubictp_std.append(np.std(cubic))

print(cubictp_mean,cubictp_std,renotp_mean,renotp_std)
# print("The mean of these values is %s"% (np.mean(L)))
# print("The standard deviation of these values is %s"% (np.std(L)))
# x = np.array(range(len(L)))
# y = np.array(L)
# ci = 0.9 * np.std(y) / np.mean(y)
# plt.plot(x, y)
# plt.fill_between(x, (y-ci), (y+ci), color='blue', alpha=0.1)
# plt.show()