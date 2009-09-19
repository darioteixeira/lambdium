#!/bin/bash

# sudo su - postgres
# createuser -d user_name
# createlang -d template1 plpgsql

# Here we define an array of tasks to be executed by this script.  Each task is
# essentially a tuple consisting of the type of action, filename, and a textual
# description of the action.

declare -a tasks

tasks[1]="EXEC:dropdb lambdium:Deleting database (may fail upon first invocation)"
tasks[2]="EXEC:createdb lambdium:Creating database"
tasks[3]="PSQL:/usr/share/postgresql/8.4/contrib/pgcrypto.sql:Loading the pgcrypto module"
tasks[4]="PSQL:types.sql:Creating types (SQL domains)"
tasks[5]="PSQL:structure.sql:Creating the database tables"
tasks[6]="PSQL:triggers.sql:Creating triggers that ensure database consistency"
tasks[7]="PSQL:api-functions.sql:Creating the API functions"
tasks[8]="PSQL:timezones.sql:Initialising timezone data"
tasks[9]="PSQL:analyze.sql:Using ANALYZE to optimise database access"


# Main loop.

NUM_TASKS=${#tasks[@]}

for i in `seq 1 $NUM_TASKS`; do
	if [ -n "${tasks[$i]}" ];
	then
		ACTION=`echo ${tasks[$i]} | cut -d: -f1`
		FILENAME=`echo ${tasks[$i]} | cut -d: -f2`
		COMMENT=`echo ${tasks[$i]} | cut -d: -f3-`

		if [ "$ACTION" = "PSQL" ];
		then COMMAND="psql --set ON_ERROR_STOP=on -d lambdium -f $FILENAME"
		elif [ "$ACTION" = "SCRIPT" ];
		then COMMAND=". $FILENAME"
		elif [ "$ACTION" = "EXEC" ];
		then COMMAND="$FILENAME"
		else COMMAND=false
		fi
			
		echo -e -n "\033[34m$COMMENT... \033[0m"
		OUTPUT=`$COMMAND 2>&1`

		if [ $? -eq "0" ];
		then
			echo -e "\033[32mSuccess!\033[0m";
		else
			echo -e "\033[31mFailure:\033[0m";
			echo -e "\n$OUTPUT\n"
		fi
	else
		echo -e "\033[31mTask $i is empty!\033[0m"
	fi
done

