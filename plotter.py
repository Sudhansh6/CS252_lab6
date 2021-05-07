from matplotlib import pyplot as plt
import numpy as np
 
reno=[]
cubic=[]
counter = 0
renotp_mean = []
cubictp_mean = []
renotp_std = []
cubictp_std = []
with open('results.txt','r') as f:
    for line in f:
        if(counter%3 == 0):
            reno=[]
            cubic=[]
        elif(counter%3 == 1):
        	reno = line[0:-2].split(" ")
        	reno = [float(i) for i in reno] # gives throughput in GBps
        elif(counter%3 == 2):
        	cubic = line[0:-2].split(" ")
        	cubic = [float(i) for i in cubic] # gives throughput in GBps
        counter+=1
        if(counter%3 == 0 and counter>0):
            renotp_mean.append(np.mean(reno))
            renotp_std.append(np.std(reno))
            cubictp_mean.append(np.mean(cubic))
            cubictp_std.append(np.std(cubic))

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
    ycubic = np.array([cubictp_mean[i],cubictp_mean[i+3],cubictp_mean[i+6]])
    yreno = np.array([renotp_mean[i],renotp_mean[i+3],renotp_mean[i+6]])
    reno_std = np.array([renotp_std[i],renotp_std[i+3],renotp_std[i+6]])
    cubic_std = np.array([cubictp_std[i],cubictp_std[i+3],cubictp_std[i+6]])
    # cireno = 0.9*np.std(yreno)/np.mean(yreno)
    # cicubic = 0.9*np.std(ycubic)/np.mean(ycubic)
    plt.errorbar(delay, yreno, yerr = 1.645*reno_std, label="Reno", marker='.', alpha = 0.5)
    # plt.fill_between(delay,yreno-cireno,yreno+cireno,color='blue',alpha=0.1)
    plt.errorbar(delay,ycubic, yerr = 1.645*cubic_std, label="Cubic", marker='.',  alpha = 0.5)
    # plt.fill_between(delay,ycubic-cicubic,ycubic+cicubic,color='blue',alpha=0.1)
    plt.title('Mean throughput vs Delay for Loss=%s'%loss[i])
    plt.xlabel('Delay')
    plt.ylabel('Throughput')
    plt.legend()
    plt.savefig('Figures/Plot-%s.png'%(i+1))
    plt.figure()
for i in range(3):
    ycubic = np.array([cubictp_mean[3*i],cubictp_mean[3*i+1],cubictp_mean[3*i+2]])
    yreno = np.array([renotp_mean[3*i],renotp_mean[3*i+1],renotp_mean[3*i+2]])
    reno_std = np.array([renotp_std[3*i],renotp_std[3*i+1],renotp_std[3*i+2]])
    cubic_std = np.array([cubictp_std[3*i],cubictp_std[3*i+1],cubictp_std[3*i+2]])
    # cireno = 0.9*np.std(yreno)/np.mean(yreno)
    # cicubic = 0.9*np.std(ycubic)/np.mean(ycubic)
    plt.errorbar(loss,yreno, yerr = 1.645*reno_std,label="Reno",marker='.', alpha = 0.5)
    # plt.fill_between(loss,yreno-cireno,yreno+cireno,color='blue',alpha=0.1)
    plt.errorbar(loss,ycubic, yerr = 1.645*cubic_std,label="Cubic",marker='.', alpha = 0.5)
    # plt.fill_between(loss,ycubic-cicubic,ycubic+cicubic,color='blue',alpha=0.1)
    plt.title('Mean throughput vs Loss for Delay=%sms'%delay[i])
    plt.xlabel('Loss')
    plt.ylabel('Throughput')
    plt.legend()
    plt.savefig('Figures/Plot-%s.png'%(i+4))
    plt.figure()