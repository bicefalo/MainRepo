#!/usr/bin/bash -x 
export ENV=${1}
export HOME_DIR="/apps/opt/jenkins/workspace/VEC-WORKSPACE-${ENV}"
export REPORT_HOME="/home/jenkins/scripts/AccuRev/DP_Reports"
export List_Report="${REPORT_HOME}/Deployment_report.${ENV}_${JOB_BUILD_ID}"
export Report="${REPORT_HOME}/Deployment_report.${ENV}_${JOB_BUILD_ID}.html"
export EMAIL_LIST="$(cat ${List_Report} | awk '{print $1}' | sort -u | sed 's/$/@one.verizon.com/g' | xargs | sed 's/ /,/g' | sed 's/beneta.b@one.verizon.com/beneta.b@in.verizon.com/g' | sed 's/pradeep.x.ravindran@one.verizon.com/pradeep.x.ravindran@intl.verizon.com/g' | sed 's/sathish.kumar.dhakshinamoorthy@one.verizon.com/sathish.kumar.dhakshinamoorthy@intl.verizon.com/g' | sed 's/hemalata.venkateswaran@one.verizon.com/hemalata.venkateswaran@intl.verizon.com/g')"
cat EMAIL_LIST > /home/jenkins/scripts/AccuRev/DP_Reports/EMAIL_LIST.${ENV}_${JOB_BUILD_ID}

Mail_Report(){
DateTime=$(date "+%H:%M:%S %m/%d/%Y")
(
 echo "From: VECEnvironmentTeam@one.verizon.com"
 echo "To: ${EMAIL_LIST}"
 echo "Cc: VECEnvironmentTeam@one.verizon.com"
 echo "Subject: ${ENV} - VEC development DP have been started jenkins build #${JOB_BUILD_ID}. -- ${DateTime} --  EST."
 echo "Content-Type: text/html"
 echo " "
 echo " "
 echo " "
 echo " "
 echo "<a href=\"http://v19sacgta41.ebiz.verizon.com:8080/view/PIPE_LINES/view/VEC/view/VEC-DP-${ENV}\">VEC-DP-${ENV} Link.</a>" 
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

