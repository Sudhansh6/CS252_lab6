#!/bin/bash
make client
make server

# tc qdisc add dev lo root netem delay 10000ms 

# delays 10 50 100
delays=("10ms" "50ms" "100ms");
# Loss 0.1% 0.5% 1%
losses=("0.1%" "0.5%" "1%");

# 	for loss in ${losses[*]}; do
# 		tc qdisc change dev lo root netem delay "$delay" loss "$loss";
# 		echo "delay ${delay} loss ${loss}" >> textfile.txt;
# 		data_reno=()  
# 		data_cubic=()
# 		for i in {1..2}; do 
# 			./server reno $(9000 + i) > temp.txt &
# 			./client localhost reno $(9000 + i) > temp2.txt
			 
# 			# data_reno+=($i);
# 			wait

# 			# ./server cubic > temp.txt &
# 			# ./client localhost cubic > temp2.txt
# 			# data_cubic+=($i);
# 			# wait 
# 		done	
# 		echo "TCP reno ${data_reno[*]}"; >> textfile.txt
# 		echo "TCP cubic ${data_cubic[*]}"; >> textfile.txt
# 	done
# done
# python3.8 plotter.py

for i in {0..1}; do
	for j in {0..1}; do
		echo "delay ${delays[i]} loss ${losses[j]}"
		tc qdisc change dev lo root netem delay "${delays[i]}" loss "${losses[j]}";
		
		data_reno=();
		data_cubic=();
		for k in {1..20}; do 
			port=$((6000 + 1000*$i + 100*$j + 2*$k + 1));
			./server reno ${port} > temp.txt  &
			./client localhost reno ${port} > temp2.txt;
			wait

			var1=$(awk 'NR==5 {print $NF}' temp.txt);
			var2=$(awk 'NR==5 {print $NF}' temp2.txt);
			data_reno+="$(($var1 - $var2)) ";

			port=$((6000 + 1000*$i + 100*$j + 2*$k ));
			./server cubic ${port} > temp.txt &
			./client localhost cubic ${port} > temp2.txt;
			
			var3=$(awk 'NR==5 {print $NF}' temp.txt)
			var4=$(awk 'NR==5 {print $NF}' temp2.txt)
			data_cubic+="$(($var3 - $var4)) ";
			wait 
		done	
		echo "TCP reno ${data_reno[*]}" ;
		echo "TCP cubic ${data_cubic%, *}" ;
	done
done

