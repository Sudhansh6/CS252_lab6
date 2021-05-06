#!/bin/bash
make client
make server

# tc qdisc add dev lo root netem delay 10000ms 

# delays 10 50 100
delays=("10ms"); # "50ms" "100ms");
# Loss 0.1% 0.5% 1%
losses=("0.1%"); #c "0.5%" "1%");

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

for delay in ${delays[*]}; do
	for loss in ${losses[*]}; do
		tc qdisc change dev lo root netem delay "$delay" loss "$loss";
		echo "delay ${delay} loss ${loss}"
		data_reno=()  
		data_cubic=()
		for i in {1..1}; do 
			port=`expr 8000 + $i`;
			./server reno ${port}  &
			./client localhost reno ${port} ;
			wait

			var1=$(awk 'NR==5 {print $NF}' temp.txt);
			var2=$(awk 'NR==5 {print $NF}' temp2.txt);
			data_reno+=(`expr $var1 - $var2`);

			port=`expr 9000 + $i`;
			./server cubic ${port} > temp.txt &
			./client localhost cubic ${port} > temp2.txt;
			
			var3=$(awk 'NR==5 {print $NF}' temp.txt)
			var4=$(awk 'NR==5 {print $NF}' temp2.txt)
			data_cubic+=(`expr $var3 - $var4`);
			wait 
		done	
		echo "TCP reno ${data_reno[*]}" > reno.txt;
		echo "TCP cubic ${data_cubic[*]}" > cubic.txt;
	done
done

