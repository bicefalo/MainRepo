#!/usr/bin/python

import subprocess

output = subprocess.Popen(['df','-h'], stdout = subprocess.PIPE)
print output.communicate()

