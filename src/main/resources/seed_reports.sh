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

# Text formatting
bold=$(tput bold)
normal=$(tput sgr0)
underline=$(tput smul)
end_underline=$(tput rmul)
red=$(tput setaf 1)

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
		echo -e "\033[0m"
	done
}


function seed()
{
	local folder=$1

	echo "Seeding folder $folder"
	for r in `find $folder -type f -name '*.sql' -o -name '*.ddl' -maxdepth 1`; do install_ddl $r; done
}

function seed_ranked()
{
	local folder=$1

	echo "Seeding folder $folder"
	for r in `find $folder -type f -name 'v_report_*.sql' -o -name 'v_*.ddl' -maxdepth 1`; do install_ddl $r; done
	for r in `find $folder -type f -name 'report_*.sql' -o -name 'report_*.ddl' -maxdepth 1`; do install_ddl $r; done
	for r in `find $folder -type f -name 'refresh_report_*.sql' -o -name 'refresh_report_*.ddl' -maxdepth 1`; do install_ddl $r; done
}

function print_help
{
	script_name=`basename "$0"`

	echo "${underline}$script_name${normal} generates java or typescript clients with ease"
	echo
	echo "${bold}Usage:${normal}   $script_name [OPTION]"
	echo
	echo "${bold}Example:${normal} client_generate -l java -v 0.0.3 -h http://localhost:8067 -n lpco"
	echo
	echo "${bold}Options:${normal}"
	echo "  -h --help                         print this help"
	echo "  -l|--language [language]          set language"
	echo "  -n|--service-name [service_name]  set service name, eg. lpco"
	echo "  -H|--host [hosturl]               set service host, eg. http://localhost:8067"
	echo "  -v|--version [client version]     set client version, default: 0.0.1-SNAPSHOT for java and 0.0.1 for typescript"
	echo
	echo "${bold}Language Options:${normal}"
	echo "   1. ${bold}Java client:${normal}       [java|java-resttemplate|java-gson-okhttp]"
	echo
	echo "   2. ${bold}Angular TS client:${normal} [js|ts|angular|typescript]"
	echo "      --ng-version   set angular version"
	echo
}


while [ ! -z "$1" ]
do
	case "$1" in
		"-h"|"--help")
			print_help
			exit
			;;
		"-f"|"--folder")
			shift
			if [ ! -d $1 ]; then
				log_error "Invalid folder" "Should be a directory"
			fi
			seed_ranked $HERE/$1
			;;
		"-d"|"--default")
			shift
			install_ddl $REPORTS/calendar.sql
			seed $REPORTS
			seed $SYSTEM
			;;
		*)
			log_error "Invalid option" "$1 $2$"
			echo
			print_help
			exit 3
	esac
	shift
done

