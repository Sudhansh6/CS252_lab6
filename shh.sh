#!/bin/bash
if cmp -s recv.txt send.txt; then
	echo same
fi