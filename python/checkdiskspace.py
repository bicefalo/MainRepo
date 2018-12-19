#!/usr/bin/python

import subprocess

#Variables
output = subprocess.Popen(['df','-h'], stdout = subprocess.PIPE)
list = output.communicate()[0].split("\n")
list_lenght = len(list)
#print list
exceeded = {}

counter = 0
for i in (list[1:]):
    if i:
        partition =  i.split()[0]
        percentage = int(i.split()[4].replace("%", ""))
        if percentage > 80:
            exceeded[counter] = {partition:percentage}
#            print counter
            counter += 1
