#!/bin/bash

# sudo su - postgres
# createuser -d user_name
# createlang -d template1 plpgsql

dropdb lambdium
createdb lambdium

#################################################################################
#										#
# Here we define an array of tasks to be executed by this script.  Each task is	#
# essentially a tuple of a filename with the action and a textual description.	#
#										#
#################################################################################

declare -a tasks

# Create custom types, database structure, internal functions, and triggers.

tasks[1]="internal-types.sql:Creating types (SQL domains) used internally by the database"
tasks[2]="structure.sql:Creating the database tables"
tasks[3]="internal-functions.sql:Creating helper functions used internally by the database"
tasks[4]="triggers.sql:Creating triggers that ensure database consistency"


# We now define the types and the functional API meant to be used by clients of
# the database.  Note that some of these functions store user passwords in plain
# text. For security reasons, you are advised to also load the "securise.sql"
# module, which redefines a couple of functions so that they rely on strong
# crypto to protect the passwords.

tasks[5]="api-types.sql:Creating types (SQL domains) visible in the user API"
tasks[6]="api-functions.sql:Creating the functions that make the user API"


# Uncomment the following two lines to enable secure storage of passwords.
# (Note that this extra security depends on the pgcrypto PostgreSQL module!)

tasks[7]="/usr/share/postgresql/8.3/contrib/pgcrypto.sql:Loading the pgcrypto module"
tasks[8]="securise.sql:Redefining some API functions to use strong crypto"


# Populate with timezone information and some dummy data for users/stories/comments.

tasks[9]="timezones.sql:Initialising timezone data"


# Analyze.

tasks[10]="analyze.sql:Using ANALYZE to optimise database access"


#################################################################################
#################################################################################

NUM_TASKS=${#tasks[@]}

for i in `seq 1 $NUM_TASKS`; do
	if [ -n "${tasks[$i]}" ];
	then
		FILENAME=`echo ${tasks[$i]} | cut -d: -f1`
		COMMENT=`echo ${tasks[$i]} | cut -d: -f2-`
		COMMAND="psql -d lambdium -f $FILENAME"
		echo "$COMMENT... "
		OUTPUT=`$COMMAND`
	else
		echo "Task ${tasks[$i]} is empty..."
	fi
done

