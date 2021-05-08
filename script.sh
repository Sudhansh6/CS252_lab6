#!/bin/bash

# Check if the script is being called correctly
if [ $# -ne 2 ]; then
	echo "Usage: ./script.sh TCP_1 TCP_2"
	exit 1
fi

# Compile client and server
make client
make server

# Make a files and directories to store the results
> textfile.txt
mkdir -p Figures

# Set the MTU to 1500B
ifconfig lo mtu 1500

# Lists for delay and loss values
delays=("10ms" "50ms" "100ms");
losses=("0.1%" "0.5%" "1%");

# Function that returns an unused port
function find_port() {
	port=$RANDOM
	quit=0;
	while [ "$quit" -ne 1 ]; do
		# Checks if a port is being used
		netstat -an | grep $port >> /dev/null 
		if [ $? -gt 0 ]; then 
			quit=1
		else 
			port=`expr $port + 1`
		fi
	done
}

# Iterate over delays and losses
for i in {0..2}; do
	for j in {0..2}; do
		# Store the results in a text file
		echo "delay ${delays[i]} loss ${losses[j]}" >> textfile.txt;
		echo -e "\e[1;31m \e[1;47m delay ${delays[i]} loss ${losses[j]} \e[0m"; 
		# Set the delay and loss value of the loopback interface
		sudo tc qdisc change dev lo root netem delay "${delays[i]}" loss "${losses[j]}";  

		# Loop over the TCP variants
		for t in $@; do
			echo -e "\e[1;32m \e[1;44m TCP $t \e[0m";
			data=()
			# Perform 20 experiments
			for k in {0..19}; do
				# Empty the recv.txt file for verification
				> recv.txt;
				echo "Experiment $(($k + 1))";

				# Comment the while loop and wait command to increase the performance
				# while ! cmp -s send.txt recv.txt; do
					find_port;
					port1=$port;
					./server $t ${port1} > temp2.txt &
					./client localhost $t ${port1} > temp.txt ;
					# wait
				# done

				# If you turned of file check above, uncomment this to check if the number of bytes sent is equal to the number of bytes received
				wait
				received=`awk '/@/ {print $2}' temp2.txt`; 
				sent=`awk '/#/ {print $6}' temp.txt`;
				if [ $received != $sent ]; then
					echo "Output file is not the same as the input file"
					exit 1;
				fi

				# Calculate the throughput
				var=`awk '/#/ { printf ( "%.6f\n", ($6*8)/ ( ($4 - $2) + ($5 - $3)*0.000001 ) ); }' temp.txt`;
				data+="$var ";

				# Delete the temporary files
				rm temp.txt; rm temp2.txt;
			done	
			echo "TCP $t:" >> textfile.txt;
			echo "${data[*]}" >> textfile.txt;

		done
	done
done
	
# Use the following line if you get an error while using matplotlib
# python3.8 -m pip install matplotlib;

# Call the python script
python3.8 plotter.py $1 $2
