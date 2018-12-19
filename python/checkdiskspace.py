#!/usr/bin/env python

import subprocess



def mail_sender():
    print "test"


#Starting point 
output = subprocess.Popen(['df','-h'], stdout = subprocess.PIPE)
output_list = output.communicate()[0].split("\n")
list_lenght = len(output_list)
exceeded = {}

counter = 0
for i in (output_list[1:]):
    if i:
        partition =  i.split()[0]
        percentage = int(i.split()[4].replace("%", ""))
        if percentage > 80:
            exceeded[counter] = {
                                partition: percentage
                                }
#            print counter
            counter += 1
print exceeded[0]

