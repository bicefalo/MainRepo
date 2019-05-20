#!/usr/bin/env python
#############################################
# *Developed with python 2.7*               #
# Created by Lewis Rodriguez.               #
# 2018-10-05                                #
# Last modification: 05/01/19               #
# Script to check disk space in Linux/Unix  #
# systems.                                  #
#############################################

import subprocess, smtplib
from socket import gethostname
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart


def mail_sender(exceeded, host_name):
    try:
        email_server = smtplib.SMTP_SSL('smtp.gmail.com', 587)
        email_server.ehlo()
        From = ""
        To = ['']
        Subject = "[ WARNING ] Disk Space utilization in server {0} almost full.".format(host_name)
        with open("/tmp/report", 'w') as report:
                html_header = '''<!DOCTYPE html>
                <html>
                <head>
                <style>
                table {
                  border-collapse: collapse;
                }
                
                th, td {
                  text-align: center;
                  padding: 8px;
                }
                
                tr:nth-child(even){background-color: #f2f2f2}
                
                th {
                  background-color: #4CAF50;
                  color: white;
                }
                </style>
                </head>
                <body>
               '''

                html_body = '''
                <tr>
                    <th>Partition</th>
                    <th>Percentage</th>
                  </tr>'''

                html_botton = '''
                </table>
                </body>
                </html>
               '''
                report.write(html_header)
                report.write("<h2>" + host_name + " </h2>")
                report.write("<table>")
                report.write(html_body)
                for key, value in exceeded.items():
                    print key, value
                    report.write("<tr>")
                    report.write("<td>" + key + "</td>")
                    report.write("<td>" + str(value) + "%</td>")
                    report.write("</tr>") 
                report.write(html_botton)
        email_server.login("","")
        email_server.sendmail(From, To, report.readlines())
    except Exception as  e:
        print "There is a connection error to the email server, email will not be sent."
        print e
        exit(1)


        





            
            

#Starting point 
output = subprocess.Popen(['df','-h'], stdout = subprocess.PIPE)
output_list = output.communicate()[0].split("\n")
list_lenght = len(output_list)
exceeded = {}
host_name = gethostname()

for i in (output_list[1:]):
    if i:
        partition =  i.split()[0]
        percentage = int(i.split()[4].replace("%", ""))
        if percentage > 80:
            exceeded.update({partition: percentage})

if  exceeded:
    mail_sender(exceeded, host_name)
else:
    print "No file systems over 80% of capacity."
