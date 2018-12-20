#!/usr/bin/env python

import subprocess, smtplib
from socket import gethostname
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart


def mail_sender(exceeded, host_name):
    sender = "l.rodriguez.contrera@gmail.com"
    receiver = ""
    with open("/tmp/report", 'w+') as report:
        head_html = """
        <html>
	<head>
	<style>

	table {
	    border-collapse: collapse;
 	    width: 100%;
		}

	.child_style {
	border: 0px;
		}

	th, td {
    	text-align: left;
    	border: 1px solid #999;
    	padding: 0px;
	}

	th {
    	background-color: #abd28e;
    	color: black;
    	border: none;
    	font-weight:normal;
	}

	tr:hover {
        	  background-color: #ffff99;
        	}

	td {
    	border-collapse: collapse;
    	border-color: #9dcc7a;
	}

	</style>
	</head>
	<body>
	<table style="width:100%">
        """

        <tr><td>kevin.m.bonanno</td>
        <td>
        <table class="child_style" style="width:100%">
        <tr>
        <th width="90%">Comment: "updates",   Jira Ticket: <a href="http://vectrack.verizon.com/browse/PQ-23">PQ-23</a> </th>
        <th width="20%">Issue #: 31861</th>
        </tr>
        <tr>
        <td colspan="2">vecbusservices/ici/src/main/java/com/vz/ici/service/batch/IciInboundEmailService.java</td>
        </tr>
        <tr>
        <td colspan="2">vecbusservices/ici/src/main/java/com/vz/ici/util/IciUtil.java</td>
        </tr>

        botton_html = """
        </table>
        </td>
        </table>
        </body>
        </html>
        """  
    #msg = MIMEText(report.read())
    #msg['Subject'] = "[WARNING] Diskspace report for server " + host_name
    #msg['From'] = "l.rodriguez.contrera@gmail.com"
    #msg['To'] = "erick.casado@verizon.com"
    #message = smtplib.SMTP('localhost')
    #message.sendmail("l.rodriguez.contrera@gmail.com", "erick.casado@verizon.com", msg.as_string())
    #message.quit()

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
    mail_sender(exceeded, host_name)
else:
    print "No file systems over 80% of capacity."

