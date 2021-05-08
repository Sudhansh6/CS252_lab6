from matplotlib import pyplot as plt
import numpy as np
import sys
from math import sqrt

counter = 0
#checking for correct usage
if(len(sys.argv) != 3):
	print("Usage: python3.8 plotter.py tcp1 tcp2")
	exit(1)
#initialling values to type of protocol or empty lists
t1 = sys.argv[1]
t2 = sys.argv[2]
tcp1 = []
tcp2 = []
tcp1tp_mean = []
tcp1tp_std = []
tcp2tp_mean = []
tcp2tp_std = []
f2 = open("results.txt", 'w')
with open('textfile.txt','r') as f:
	for line in f:
		f2.write(line)
		if (counter % 5 == 0):
            #taking mod 5 because of the format of the file we're reading from
			f2.write("\n")
		if(counter%5 == 0):
            #emptying the lists once a new experiment(or rather 20 experiments with new conditions) is done
			tcp1=[]
			tcp2=[]
		elif(counter%5 == 2):
            #mod(2) would give us the Protocol-1 values, we calculate and store required values in tcp1_mean and tcp1_std
			tcp1 = line[0:-2].split(" ")
			tcp1 = [float(i) for i in tcp1]
			tcp1_mean = np.mean(tcp1)
			f2.write("Throughput mean  = {} bits/sec\n".format(tcp1_mean))
			tcp1_std = np.std(tcp1)
			f2.write("Throughput standard deviation  = {} bits/sec\n\n".format(tcp1_std))
            #we also printed these values out to results.txt
		elif(counter%5 == 4):
            #mod(2) would give us the Protocol-2 values, we calculate and store required values in tcp2_mean and tcp2_std
			tcp2 = line[0:-2].split(" ")
			tcp2 = [float(i) for i in tcp2]
			tcp2_mean = np.mean(tcp2)
			f2.write("Throughput mean  = {} bits/sec\n".format(tcp2_mean))
			tcp2_std = np.std(tcp2)
			f2.write("Throughput standard deviation  = {} bits/sec\n\n".format(tcp2_std))
            #we also printed these values out to results.txt
		counter+=1
		if(counter%5 == 0 and counter>0):
            #appending the values calculated for a particular set of delay and loss, to the lists
            #tcp1tp_mean, tcp2tp_mean, tcp1tp_std, tcp2tp_std
			tcp1tp_mean.append(tcp1_mean)
			tcp1tp_std.append(tcp1_std)
			tcp2tp_mean.append(tcp2_mean)
			tcp2tp_std.append(tcp2_std)

#setting up confidence intervals of 90%, to use in generating the required plots
tcp1tp_std = list(map(lambda c: c/2.718, tcp1tp_std)) # 1.645*tcp1tp_std/sqrt(20)
tcp2tp_std = list(map(lambda c: c/2.718, tcp2tp_std)) # 1.645*tcp2tp_std/sqrt(20)

#these are the values of loss and delay that correspond to the items in the tcp1tp_{..} and tcp2tp_{..} lists
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
    #making plots for a particular loss value
	plt.title('Mean throughput vs Delay for Loss=%s'%loss[i])
	plt.xlabel('Delay')
	plt.ylabel('Throughput')
	plt.grid()

    #taking values of mean throughput at the three different delay values
	ytcp2 = np.array([tcp2tp_mean[i],tcp2tp_mean[i+3],tcp2tp_mean[i+6]])
	ytcp1 = np.array([tcp1tp_mean[i],tcp1tp_mean[i+3],tcp1tp_mean[i+6]])
	tcp1_std = np.array([tcp1tp_std[i],tcp1tp_std[i+3],tcp1tp_std[i+6]])
	tcp2_std = np.array([tcp2tp_std[i],tcp2tp_std[i+3],tcp2tp_std[i+6]])

	plt.plot(delay, ytcp1, color="red",label=t1)
	plt.fill_between(delay, ytcp1 - tcp1_std, ytcp1 + tcp1_std, color='red', alpha=0.1)
	plt.plot(delay, ytcp2, color="blue", label=t2)
	plt.fill_between(delay, ytcp2 - tcp2_std, ytcp2 + tcp2_std, color='blue', alpha=0.1)
	plt.legend()
	plt.savefig('Figures/Plot-%s.png'%(i+1))
	plt.figure()

for i in range(3):
    #making plots for a particular delay value
	plt.title('Mean throughput vs Loss for Delay=%sms'%delay[i])
	plt.xlabel('Loss')
	plt.ylabel('Throughput')
	plt.grid()

    #taking values of mean throughput at the three different loss values
	ytcp2 = np.array([tcp2tp_mean[3*i],tcp2tp_mean[3*i+1],tcp2tp_mean[3*i+2]])
	ytcp1 = np.array([tcp1tp_mean[3*i],tcp1tp_mean[3*i+1],tcp1tp_mean[3*i+2]])
	tcp1_std = np.array([tcp1tp_std[3*i],tcp1tp_std[3*i+1],tcp1tp_std[3*i+2]])
	tcp2_std = np.array([tcp2tp_std[3*i],tcp2tp_std[3*i+1],tcp2tp_std[3*i+2]])

	plt.plot(delay, ytcp1, color="red", label=t1)
	plt.fill_between(delay, ytcp1 - tcp1_std, ytcp1 + tcp1_std, color='red', alpha=0.1)
	plt.plot(delay, ytcp2, color="blue", label=t2)
	plt.fill_between(delay, ytcp2 - tcp2_std, ytcp2 + tcp2_std, color='blue', alpha=0.1)
	plt.legend()
	plt.savefig('Figures/Plot-%s.png'%(i+4))
	plt.figure()
