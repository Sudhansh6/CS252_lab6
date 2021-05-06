#!/bin/bash
make client
make server
# mkdir frontend
# mkdir backend

# tc qdisc add dev lo root netem delay 0ms 
# tc qdisc add dev lo root netem loss 0%

# delays 10 50 100
delays=("10000ms" "50ms" "100ms");
# Loss 0.1% 0.5% 1%
losses=("0.1%" "0.5%" "1%");

for delay in ${delays[*]}; do
	tc qdisc change dev lo root netem delay "$delay" 
	for loss in ${losses[*]}; do
		tc qdisc change dev lo root netem loss "$loss"
		echo "delay ${delay} loss ${loss}"
		data_reno=()  
		data_cubic=()
		for i in {1..1}; do 
			./server reno > temp.txt &
			./client localhost reno > temp2.txt
			
			data_reno+=($i);

			./server cubic > temp.txt &
			./client localhost cubic > temp2.txt
			data_cubic+=($i);
		done	
		echo "TCP reno ${data_reno[*]}";
		echo "TCP cubic ${data_cubic[*]}";
	done
done

# rm -rf frontend
# rm -rf backend

# delay - 10, loss - 0.1
# tcp reno - 11 101 101 101011 1011 10 309 2309 2039 54
# tcp cubic - 11 101 101 101011 1011 10 309 2309 2039
# delay - 10, loss - 0.5
# tcp reno - 11 101 101 101011 1011 10 309 2309 2039 53
# tcp cubic - 11 101 101 101011 1011 10 309 2309 2039
# delay - 10, loss - 1
# tcp reno - 11 101 101 101011 1011 10 309 2309 2039 52
# tcp cubic - 11 101 101 101011 1011 10 309 2309 2039