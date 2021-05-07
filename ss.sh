#!/bin/bash
make client
make server
> results.txt
mkdir Figures

ifconfig lo mtu 1500
# delays 10 50 100
delays=("10ms" "50ms" "100ms");
# Loss 0.1% 0.5% 1%
losses=("0.1%" "0.5%" "1%");

function find_port() {
	port=$RANDOM
	quit=0;
	while [ "$quit" -ne 1 ]; do
		netstat -an | grep $port >> /dev/null 
		if [ $? -gt 0 ]; then 
			quit=1
		else 
			port=`expr $port + 1`
		fi
	done
}

for i in {0..2}; do
	for j in {0..2}; do
		echo "delay ${delays[i]} loss ${losses[j]}" >> results.txt;
		sudo tc qdisc change dev lo root netem delay "${delays[i]}" loss "${losses[j]}";
		
		data_reno=()  
		data_cubic=()
		for k in {0..19}; do 
			find_port;
			port1=$port;
			./server reno ${port1} > temp.txt &
			./client localhost reno ${port1} > temp2.txt ;
			wait

			var=`awk ' NR==FNR{if(FNR==5){var1=$2;var2=$3} next}{if(FNR==5){var3=$2;var4=$3;print 5/((var1-var3)*(1000)+(var2-var4)*(0.001))}}' temp.txt temp2.txt`
			data_reno+="$var ";

			rm temp.txt;
			rm temp2.txt;

			find_port;
			port2=$port;
			./server cubic ${port2} > temp.txt &
			./client localhost cubic ${port2} > temp2.txt;
			wait

			var=`awk ' NR==FNR{if(FNR==5){var1=$2;var2=$3} next}{if(FNR==5){var3=$2;var4=$3;print 5/((var1-var3)*(1000)+(var2-var4)*(0.001))}}' temp.txt temp2.txt`
			data_cubic+="$var ";

			rm temp.txt;
			rm temp2.txt;
		done	
		echo "${data_reno[*]}" >> results.txt;
		echo "${data_cubic[*]}" >> results.txt;
	done
done


# python3.8 -m pip install matplotlib;
python3.8 plotter.py
