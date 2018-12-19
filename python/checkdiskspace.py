#!/usr/bin/python

import subprocess

#Variables
output = subprocess.Popen(['df','-h'], stdout = subprocess.PIPE)
list = output.communicate()[0].split("\n")
list_lenght = len(list)
#print list
exceeded = {}

for i in (list[1:]):
    if i:
        partition =  i.split()[0]
        percentage = int(i.split()[4].replace("%", ""))
        if percentage > 80:
            print partition, percentage

print exceeded
