#!/bin/bash
make client
make server
# mkdir frontend
# mkdir backend

# tc qdisc add dev lo root netem delay 10000ms 

# delays 10 50 100
delays=("10ms"); # "50ms" "100ms");
# Loss 0.1% 0.5% 1%
losses=("0.1%"); #c "0.5%" "1%");

for delay in ${delays[*]}; do
	for loss in ${losses[*]}; do
		tc qdisc change dev lo root netem delay "$delay" loss "$loss";
		echo "delay ${delay} loss ${loss}" >> textfile.txt;
		data_reno=()  
		data_cubic=()
		for i in {1..2}; do 
			./server reno $(9000 + i) > temp.txt &
			./client localhost reno $(9000 + i) > temp2.txt
			 
			# data_reno+=($i);
			wait

			# ./server cubic > temp.txt &
			# ./client localhost cubic > temp2.txt
			# data_cubic+=($i);
			# wait 
		done	
		echo "TCP reno ${data_reno[*]}"; >> textfile.txt
		echo "TCP cubic ${data_cubic[*]}"; >> textfile.txt
	done
done
# python3.8 plotter.py
