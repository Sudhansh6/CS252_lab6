from matplotlib import pyplot as plt
import numpy as np
import sys
import math

counter = 0
if(len(sys.argv) != 3):
	print("Usage: python3.8 plotter.py tcp1 tcp2")
	exit(1)

t1 = sys.argv[1]
t2 = sys.argv[2]
tcp1 = tcp2 = tcp1tp_mean = tcp1tp_std = tcp2tp_mean = tcp2tp_std = []
f2 = open("results.txt", 'w')
with open('textfile.txt','r') as f:
    for line in f:
        f2.write(line)
        if counter == 0:
            f2.write("\n")
        if(counter%5 == 0):
            tcp1=[]
            tcp2=[]
        elif(counter%5 == 2):
            tcp1 = line[0:-2].split(" ")
            tcp1 = [float(i) for i in tcp1]
            tcp1_mean = np.mean(tcp1)
            f2.write("Throughput mean  = {} bits/sec\n".format(tcp1_mean))
            tcp1_std = np.std(tcp1)
            f2.write("Throughput standard deviation  = {} bits/sec\n\n".format(tcp1_std))
        elif(counter%5 == 4):
            tcp2 = line[0:-2].split(" ")
            tcp2 = [float(i) for i in tcp2]
            tcp2_mean = np.mean(tcp2)
            f2.write("Throughput mean  = {} bits/sec\n".format(tcp2_mean))
            tcp2_std = np.std(tcp2)
            f2.write("Throughput standard deviation  = {} bits/sec\n\n".format(tcp2_std))
        counter+=1
        if(counter%5 == 0 and counter>0):
            tcp1tp_mean.append(tcp1_mean)
            tcp1tp_std.append(tcp1_std)
            tcp2tp_mean.append(tcp2_mean)
            tcp2tp_std.append(tcp2_std)

#index 0 - loss0.1 delay10
#index 1 - loss0.5 delay10
#index 2 - loss1 delay10
#index 3 - loss0.1 delay50
#index 4 - loss0.5 delay50
#index 5 - loss1 delay50
#index 6 - loss0.1 delay100
#index 7 - loss0.5 delay100
#index 8 - loss1 delay100
delay = np.array([10,50,100])
loss = np.array([0.1,0.5,1])
for i in range(3):
    ytcp2 = np.array([tcp2tp_mean[i],tcp2tp_mean[i+3],tcp2tp_mean[i+6]])
    ytcp1 = np.array([tcp1tp_mean[i],tcp1tp_mean[i+3],tcp1tp_mean[i+6]])
    tcp1_std = np.array([tcp1tp_std[i],tcp1tp_std[i+3],tcp1tp_std[i+6]])
    tcp2_std = np.array([tcp2tp_std[i],tcp2tp_std[i+3],tcp2tp_std[i+6]])
    # citcp1 = 0.9*np.std(ytcp1)/np.mean(ytcp1)
    # citcp2 = 0.9*np.std(ytcp2)/np.mean(ytcp2)
    plt.errorbar(delay, ytcp1, yerr = 1.645*tcp1_std/math.sqrt(20), label=t1, marker='.', alpha = 0.5)
    # plt.fill_between(delay,ytcp1-citcp1,ytcp1+citcp1,color='blue',alpha=0.1)
    plt.errorbar(delay,ytcp2, yerr = 1.645*tcp2_std/math.sqrt(20), label=t2, marker='.',  alpha = 0.5)
    # plt.fill_between(delay,ytcp2-citcp2,ytcp2+citcp2,color='blue',alpha=0.1)
    plt.title('Mean throughput vs Delay for Loss=%s'%loss[i])
    plt.xlabel('Delay')
    plt.ylabel('Throughput')
    plt.legend()
    plt.savefig('Figures/Plot-%s.png'%(i+1))
    plt.figure()
for i in range(3):
    ytcp2 = np.array([tcp2tp_mean[3*i],tcp2tp_mean[3*i+1],tcp2tp_mean[3*i+2]])
    ytcp1 = np.array([tcp1tp_mean[3*i],tcp1tp_mean[3*i+1],tcp1tp_mean[3*i+2]])
    tcp1_std = np.array([tcp1tp_std[3*i],tcp1tp_std[3*i+1],tcp1tp_std[3*i+2]])
    tcp2_std = np.array([tcp2tp_std[3*i],tcp2tp_std[3*i+1],tcp2tp_std[3*i+2]])
    # citcp1 = 0.9*np.std(ytcp1)/np.mean(ytcp1)
    # citcp2 = 0.9*np.std(ytcp2)/np.mean(ytcp2)
    plt.errorbar(loss,ytcp1, yerr = 1.645*tcp1_std/math.sqrt(20),label=t1,marker='.', alpha = 0.5)
    # plt.fill_between(loss,ytcp1-citcp1,ytcp1+citcp1,color='blue',alpha=0.1)
    plt.errorbar(loss,ytcp2, yerr = 1.645*tcp2_std/math.sqrt(20),label=t2,marker='.', alpha = 0.5)
    # plt.fill_between(loss,ytcp2-citcp2,ytcp2+citcp2,color='blue',alpha=0.1)
    plt.title('Mean throughput vs Loss for Delay=%sms'%delay[i])
    plt.xlabel('Loss')
    plt.ylabel('Throughput')
    plt.legend()
    plt.savefig('Figures/Plot-%s.png'%(i+4))
    plt.figure()