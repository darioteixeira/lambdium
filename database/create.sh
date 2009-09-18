#!/bin/bash

# sudo su - postgres
# createuser -d user_name
# createlang -d template1 plpgsql

dropdb lambdium
createdb lambdium


# Here we define an array of tasks to be executed by this script.  Each task is
# essentially a tuple consisting of the type of action, filename, and a textual
# description of the action.

declare -a tasks


# Load required modules.

tasks[1]="PSQL:/usr/share/postgresql/8.4/contrib/pgcrypto.sql:Loading the pgcrypto module"


# Create custom types, database structure, internal functions, and triggers.

tasks[2]="PSQL:internal-types.sql:Creating types (SQL domains) used internally by the database"
tasks[3]="PSQL:structure.sql:Creating the database tables"
tasks[4]="PSQL:internal-functions.sql:Creating helper functions used internally by the database"
tasks[5]="PSQL:triggers.sql:Creating triggers that ensure database consistency"


# We now define the types and the functional API meant to be used by clients of
# the database.

tasks[6]="PSQL:api-types.sql:Creating types (SQL domains) visible in the user API"
tasks[7]="PSQL:api-functions.sql:Creating the functions that make the user API"


# Populate with timezone information and some dummy data for users/stories/comments.
# Choose either the SCRIPT or PSQL version.  The former uses precomputed timezone
# data and is fast.  The latter is much slower, but potentially more accurate.

tasks[8]="SCRIPT:timezones.script:Initialising timezone data"
#tasks[8]="PSQL:timezones.sql:Initialising timezone data (may take a long time)"


# Analyze.

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
		then COMMAND="psql -d lambdium -f $FILENAME"
		elif [ "$ACTION" = "SCRIPT" ];
		then COMMAND=". $FILENAME"
		else COMMAND=false
		fi
			
		echo -e -n "\033[34m$COMMENT... \033[0m"
		OUTPUT=`($COMMAND > /dev/null) 2> /dev/null`

		if [ $? -eq "0" ];
		then echo -e "\033[32mSuccess!\033[0m";
		else echo -e "\033[31mFailed!\033[0m";
		fi
	else
		echo -e "\033[31mTask $i is empty!\033[0m"
	fi
done

