#!/usr/bin/env bash

###################################################################################
#                                                                                 #
#                   Copyright 2010-2014 Ning, Inc.                                #
#                   Copyright 2014-2015 Groupon, Inc.                             #
#                   Copyright 2014-2015 The Billing Project, LLC                  #
#                                                                                 #
#      The Billing Project licenses this file to you under the Apache License,    #
#      version 2.0 (the "License"); you may not use this file except in           #
#      compliance with the License.  You may obtain a copy of the License at:     #
#                                                                                 #
#          http://www.apache.org/licenses/LICENSE-2.0                             #
#                                                                                 #
#      Unless required by applicable law or agreed to in writing, software        #
#      distributed under the License is distributed on an "AS IS" BASIS, WITHOUT  #
#      WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the  #
#      License for the specific language governing permissions and limitations    #
#      under the License.                                                         #
#                                                                                 #
###################################################################################

HERE=`cd \`dirname $0\`; pwd`

REPORTS=$HERE/reports
SYSTEM=$HERE/system

function install_ddl() {
	local ddl=$1

	echo -e "\033[1;35m$x\033[0m"

	echo -e "\033[1;32m"
	cat "$ddl"
	echo -e "\033[0m"

	echo -e "\033[1;37m"
	while true
	do
		echo "Running psql -p5433 killbill -f $ddl"
		failed=false
		psql -p5433 -v ON_ERROR_STOP=1 -f $ddl killbill || failed=true

		if "$failed"; then
			echo "There was an error in the migration, what do you wish to do?"
			echo "[Y/y] for reruning"
			echo "[S/s] for skipping"
			echo "[E/e] for editing the file $ddl"
			echo "[C/c] for cancel or exit program"
			read answer

			if [ "$answer" != "${answer#[Yy]}" ] ;then
				echo "Repeating"
			elif [ "$answer" != "${answer#[Cc]}" ] ;then
				echo "Exiting program..."
				exit 0
			elif [ "$answer" != "${answer#[Ee]}" ] ;then
				echo "Opening "${EDITOR:-vi}" $ddl"
				"${EDITOR:-vi}" $ddl
				echo "Done editing file... $ddl"
			else
				echo "Skipping..."
				break
			fi
		else
			break
		fi
	done
	echo -e "\033[0m"
}

# Install the DDL - the calendar table needs to be first
install_ddl $REPORTS/calendar.sql
for r in `find $REPORTS -type f -name '*.sql' -o -name '*.ddl' -maxdepth 1`; do install_ddl $r; done
for r in `find $SYSTEM -type f -name '*.sql' -o -name '*.ddl' -maxdepth 1`; do install_ddl $r; done

