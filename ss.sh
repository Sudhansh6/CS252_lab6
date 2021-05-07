#!/bin/bash
make client
make server
> results.txt

# sudo tc qdisc add dev lo root netem delay 10000ms 

# delays 10 50 100
delays=("10ms" "50ms" "100ms");
# Loss 0.1% 0.5% 1%
losses=("0.1%" "0.5%" "1%");

for i in {0..2}; do
	for j in {0..2}; do
		echo "delay ${delays[i]} loss ${losses[j]}" >> results.txt;
		sudo tc qdisc change dev lo root netem delay "${delays[i]}" loss "${losses[j]}";
		
		data_reno=()  
		data_cubic=()
		for k in {1..5}; do 
			port1=$((6000 + 1000*$i + 100*$j + 2*$k + 1));
			# echo "hello ${port}";
			./server reno ${port1} > temp.txt  &
			./client localhost reno ${port1} > temp2.txt;
			wait

			var=`awk ' NR==FNR{if(FNR==5){var1=$2;var2=$3} next}{if(FNR==5){var3=$2;var4=$3;print (var1-var3)*(1000)+(var2-var4)*(0.001)}}' temp.txt temp2.txt`
			data_reno+="$var ";

			port2=$((8000 + 1000*$i + 100*$j + 2*$k));
			# echo "hello ${port}";
			./server cubic ${port2} > temp.txt  &
			./client localhost cubic ${port2} > temp2.txt;
			wait

			var=`awk ' NR==FNR{if(FNR==5){var1=$2;var2=$3} next}{if(FNR==5){var3=$2;var4=$3;print (var1-var3)*(1000)+(var2-var4)*(0.001)}}' temp.txt temp2.txt`
			data_cubic+="$var ";

		done	
		echo "TCP reno ${data_reno[*]}" >> results.txt;
		echo "TCP cubic ${data_cubic[*]}" >> results.txt;
	done
done



python3.8 plotter.py





