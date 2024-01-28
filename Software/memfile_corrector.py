#!/usr/bin/python3

import sys
import fileinput

file_path = sys.argv[1]

with fileinput.input(file_path, inplace=True) as file:
    for line in file:
        if line.startswith("@"):
            address = int(line[1:], 16)
            address >>= 2
            print(f"@{address:0{8}X}")
        else:
            print(line, end='')