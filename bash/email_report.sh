#!/usr/bin/bash -x 
export ENV=${1}
export HOME_DIR=""
export REPORT_HOME=""
export List_Report=""
export Report=""
export EMAIL_LIST=""

Mail_Report(){
DateTime=$(date "+%H:%M:%S %m/%d/%Y")
(
 echo "From: "
 echo "To: ${EMAIL_LIST}"
 echo "Cc: "
 echo "Subject: "
 echo "Content-Type: text/html"
 echo " "
 echo " "
 echo " "
 echo " "
 echo "<a href=\"" 
 cat ${Report}
) |  /usr/sbin/sendmail -t
}

> ${Report}
if [[ $? -ne 0 ]]
then
	echo "Was not possible to create the temporary file. Exiting..."
	exit 1 
fi

if [ "${EMAIL_LIST}" != "" ]
then
echo '<html>
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
	<table style="width:100%">' >> ${Report}

	for name in $(sort -k 1 ${List_Report} | awk '{ print $1 }' | sort -u)
	do
  		echo "<tr><td>${name}</td>" >> ${Report}
  		echo "<td>" >> ${Report}
  		for issue in $(grep "${name}" ${List_Report} | awk '{ print $2 }' | sort -u)
  		do
   			#comment="$(grep "${issue}" ${List_Report} | tail -1 | perl -n -e 'print((split(/\s+/,$_,4))[3])')"
			comment="$(grep "$issue" ${List_Report} | tail -1 | perl -n -e 'print((split(/\s+/,$_,4))[3])' | perl -p -e 's/\s+\S+$//')"
			jira_ticket="$(grep "$issue" ${List_Report} | tail -1 | perl -n -e 'print((split(/\s+/,$_,4))[3])' | perl -n -e 'print "$_\n" foreach ((split(/\s+/,$_))[-1])')"
   			echo "<table class=\"child_style\" style=\"width:100%\">" >> ${Report}
   			echo "<tr>" >> ${Report}
   			echo "<th width=\"90%\">Comment: ${comment},   Jira Ticket: <a href=\"http://vectrack.verizon.com/browse/$jira_ticket\">$jira_ticket</a> </th>" >> ${Report}
   			echo "<th width=\"20%\">Issue #: ${issue}</th>" >> ${Report}
   			echo "</tr>" >> ${Report}
   				for filename in $(grep "$name" ${List_Report} | grep "$issue" | awk '{ print $3 }')
   				do
     					echo "<tr>" >> ${Report}
     					echo "<td colspan=\"2\">$filename</td>" >> ${Report}
     					echo '</tr>' >> ${Report}
   				done
   			echo '</table>' >> ${Report}
 		done
 		echo '</td>' >> ${Report}
	done
	echo '
	</table>
	</body>
	</html>
	'  >> ${Report}

	Mail_Report
else	
	echo "******************************************" >> ${Report}
	echo "There are no modified files in this build." >> ${Report}
	echo "******************************************" >> ${Report}
	exit 0
fi

