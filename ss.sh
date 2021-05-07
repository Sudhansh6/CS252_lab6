#!/bin/bash
make client
make server
> results.txt
mkdir -p Figures

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
> tmp.txt
for i in {0..2}; do
	for j in {0..2}; do
		echo "delay ${delays[i]} loss ${losses[j]}" >> results.txt;
		sudo tc qdisc change dev lo root netem delay "${delays[i]}" loss "${losses[j]}";
		
		data_reno=()  
		data_cubic=()
		for k in {0..19}; do
			> recv.txt;
			while ! cmp -s send.txt recv.txt; do
				find_port;
				port1=$port;
				./server reno ${port1} > temp.txt &
				./client localhost reno ${port1} > temp2.txt ;
				wait
				cat temp.txt temp2.txt >> tmp.txt;
				echo $'\n' >> tmp.txt;
			done

			var=`awk '/#/ { printf ( "%.6f\n", ($6*8)/ ( ($4 - $2) + ($5 - $3)*0.000001 ) ); }' temp2.txt`;
			echo $var;
			data_reno+="$var ";

			rm temp.txt;
			rm temp2.txt;

			> recv.txt;
			while ! cmp -s send.txt recv.txt; do
				find_port;
				port2=$port;
				./server cubic ${port2} > temp.txt &
				./client localhost cubic ${port2} > temp2.txt;
				wait
			done

			var=`awk '/#/ { printf ( "%.6f\n", ($6*8)/ ( ($4 - $2) + ($5 - $3)*0.000001 ) ); }' temp2.txt`;
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
