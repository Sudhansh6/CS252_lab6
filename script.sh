#!/bin/bash
make client
make server
# mkdir frontend
# mkdir backend

for i in {1..2};do 
	gnome-terminal -- bash -c "./client localhost ; exec bash"
	gnome-terminal -- bash -c "./server ; exec bash"
done

# rm -rf frontend
# rm -rf backend