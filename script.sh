#!/bin/bash
make client
make server

# tc qdisc add dev lo root netem delay 0ms 
# tc qdisc add dev lo root netem loss 0%

# delays 10 50 100
delays=("10000ms" "50ms" "100ms");
# Loss 0.1% 0.5% 1%
losses=("0.1%" "0.5%" "1%");

for delay in ${delays[*]}; do
	sudo tc qdisc change dev lo root netem delay "$delay";
	for loss in ${losses[*]}; do
		sudo tc qdisc change dev lo root netem loss "$loss";
		echo "delay ${delay} loss ${loss}"
		data_reno=()  
		data_cubic=()
		for i in {1..20}; do 
			port=`expr 8000 + $i`;
			./server reno $port> temp.txt &
			./client localhost reno $port> temp2.txt
			
			var1=$(awk 'NR==5 {print $NF}' temp.txt)
			var2=$(awk 'NR==5 {print $NF}' temp2.txt)
			data_reno+=(`expr $var1 - $var2`);

			./server cubic $port> temp.txt &
			./client localhost cubic $port> temp2.txt 

			var3=$(awk 'NR==5 {print $NF}' temp.txt)
			var4=$(awk 'NR==5 {print $NF}' temp2.txt)
			data_cubic+=(`expr $var3 - $var4`);
		done	
		echo "TCP reno ${data_reno[*]}" > reno.txt;
		echo "TCP cubic ${data_cubic[*]}" > cubic.txt;
	done
done