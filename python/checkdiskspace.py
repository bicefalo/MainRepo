#!/usr/bin/env python

import subprocess
from socket import gethostname


def mail_sender(exceeded):
    print exceeded

#Starting point 
output = subprocess.Popen(['df','-h'], stdout = subprocess.PIPE)
output_list = output.communicate()[0].split("\n")
list_lenght = len(output_list)
exceeded = {}
host_name = gethostname()

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

if  exceeded:
    mail_sender(exceeded)
else:
    print "No file systems over 80% of capacity."

