#!/usr/bin/env bash
# myBashRC.sh - A simple menu driven shell script to to get information about your 
# Author: Henry O. Zorrilla
# Date: 03/July/2019

# set -o errexit
# set -o pipefail
# set -o nounset
# set -o xtrace

# Set magic variables for current file & dir
# __dir="$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)"
# __file="${__dir}/$(basename ${BASH_SOURCE[0]})"
# __base="$(basename ${__file} .sh)"
# __root="$(cd $(dirname ${__dir}) && pwd)" # <-- change this as it depends on your app
# arg1="${1:-}"

#########################
#                   	#
#  GLOBAL VARIABLES 	#
#                   	#
#########################
trap "echo 'Ctrl-C is trapped.'" SIGINT
gLog="git_log.txt"
eLog="error_log.txt"
cLog="clasp_log.txt"
mLog="meta_log.txt"
mBash="/data/data/com.termux/files/usr/bin/bash"

#################################
#				#
#	UTILITY FUNCTIONS	#
#                   		#
#################################
function create_logs(){
	> gLog
	> eLog
	> cLog
	> mLog
}

# Purpose: Display pause prompt
# $1-> Message (optional)
function pause(){
	local message="$@"
	[ -z $message ] && message="Press [Enter] key to continue..."
	read -p "$message" readEnterKey
}

function stop(){

}
# Display header
function write_header(){
	local ts="@$(date +'%Y-%m-%d %T')"
	local header_text=""
	local border=""
	local top=""
	local mid=""
	local bot=""

	if [ -n "$1" ]; then
		header_text+="$1"
	else
		header_text+="${ts}" && border+="-"
	fi
	if [ -n "$2" ]; then
		border+="$2"
	else
		border+="-"
	fi

	mid+="${header_text}"

	for ((i=0; i<"${#mid}"; i++)); do
		top+="${border}"
		bot+="${border}"
	done

	echo "${top}"
	echo "${mid}"
	echo "${bot}"
}

# Set Aliases
function set_aliases(){
	if [ "$0" == "$mBash" ]; then
		alias code="cd && cd ~/storage/shared/FastHub"
	else
		alias code="cd && cd /Users/thmthmnky/Documents/Coding"
		alias pullClasp="cd src/ && clasp pull && cd ../"
		alias pushClasp="cd src/ && clasp push && cd ../"
		alias loginClasp="cd src/ && clasp login && cd ../"
		alias logoutClasp="cd src/ && clasp logout && cd ../"
	fi
}

function klasp(){
	local ts="@$(date +'%Y-%m-%d %T')"
	if [ -n "$@" ]; then
		local cmd="$1"
		case "$cmd" in
			login) loginClasp;;
			logout) logoutClasp;;
			push) pushClasp;;
			pull) pullClasp;;
			*)
				 echo "$* is not a valid 'Klasp' command"
		esac
	fi
}

#################################
#				#
#	SYTEM INFORMATION	#
#                   		#
#################################

# Purpose - Get info about your operating system
function os_info(){
	local ts="@$(date +'%Y-%m-%d %T')"
	write_header "*** System information ***" "*"
	pause "Press [Enter] key to continue..."
}

# Purpose - Get info about host such as dns, IP, and hostname
function host_info(){
	local ts="@$(date +'%Y-%m-%d %T')"
	local dnsips=$(sed -e '/^$/d' /etc/resolv.conf | awk '{if (tolower($1)=="nameserver") print $2}')
	write_header "*** Hostname and DNS Information ***" "*"
	echo "Hostname : $(hostname -s)"
	echo "DNS domain : $(hostname -d)"
	echo "Fully qualified domain name : $(hostname -f)"
	echo "Network address (IP) :  $(hostname -i)"
	echo "DNS name servers (DNS IP) : ${dnsips}"
	pause "Press [Enter] key to continue..."
}

# Purpose - Network inferface and routing info
function net_info(){
	local ts="@$(date +'%Y-%m-%d %T')"
	devices=$(netstat -i | cut -d" " -f1 | egrep -v "^Kernel|Iface|lo")
	write_header "*** Network information ***" "*"
	echo "Total network interfaces found : $(wc -w <<<${devices})"

	write_header "*** IP Address Information ***" "*"
	ip -4 address show

	write_header "*** Network Routing Information ***" "*"
	netstat -nr

	write_header "*** Interface traffic information ***" "*"
	netstat -i

	pause
}

# Purpose - Display a list of users currently logged on
#           display a list of receltly loggged in users
function user_info(){
	local ts="@$(date +'%Y-%m-%d %T')"
	local cmd="$1"
	case "$cmd" in
		who) who -H | write_header; pause;;
		last)
			write_header "*** Last Logged-in Users ***" "*"
			last
			pause
	esac
}

# Purpose - Display used and free memory info
function mem_info(){
	write_header "*** Free and Used Memory ***" "*"
	free -m

	write_header "*** Virtual Memory Statistics ***" "*"
	vmstat

	write_header "*** Top 5 Memory Eating Processes ***" "*"
	ps auxf | sort -nr -k 4 | head -5

	pause
}

#################################
#				#
#	WORKFLOW FUNCTIONS	#
#                   		#
#################################

# Create a new Project and begin a new session with it
function create_project(){
	local ts="@$(date +'%Y-%m-%d %T')"
	local new_project_name
	code
	while [ -z "${new_project_name}" ]; do
		read -p "What are we calling this thing? " new_project_name
		if [ -n "$(ls -l | grep -F ^new_project_name)" ]; then
			echo "I thought you wanted to start a NEW project?"
			break;
		else
			clear
			write_header "*** Creating A New Project ***" "*"
			mkdir $(new_project_name)
			cd $(new_project_name)

			write_header "${ts} Adding Dot Files" "--"
			git init

			write_header "${ts} Create Logs" "--"
			create_logs

			write_header "${ts} Initial Commit" "--"
			git commit -m "Initial Commit"

			write_header "${ts} Create Staging Branch" "--"
			git checkout -b staging

			write_header "${ts} Create Development Branch" "--"
			git checkout -b development
			break;
		fi
	done
}

# Begin a new session in project '$1' and
# checkout to branch '$2'
function start_session() {
	local projects=("")
	local ts="@$(date +'%Y-%m-%d %T')"
	code
	if [ -z "$@" ]; then
		local userInput
		n=0
		write_header "ActiveProjects-${ts}" "-"
		for x in $(ls); do
			projects+=(x)
			echo "		${n}/) ${x}"
			((n++))
		done
		read -p "What will it be today? [ 0 - $((n-1)) ]: " userInput
		clear
		# [TODO] Validate  $userInput
		n=0
		for y in $(ls); do
			if [ "$userInput" == "$n" ]; then
				write_header "BeginSession:$y -${ts}" "*"
				cd "$y"
				break
			fi
			((n++))
		done
		pause
	elif [ -n "$1" -a -n "$(ls | grep -F $1)" ]; then
		write_header "BeginnSession:$1 -${ts}" "*"
		cd "$1"
		pause
	else
		pause "$1 is not the name of any project being tracked."
	fi
}

# End session
function end_session(){
	local ts="@$(date +'%Y-%m-%d %T')"
	code
	if [ -n "${ls | grep ^$1}" ]; then
		cd "$1"
		CURR=$(git branch | grep \* | cut -d ' ' -f2)
		write_header "EndingSession in $1" "*"
		git stash push -m "$1:${CURR}${ts}"
		git stash list
	else
		echo "$1 is not the name of any project being tracked in this repository." 
	fi
}

#################################
#				#
#	USER INPUT ROUTER	#
#				#
#################################
function router(){
        local userInput
        read -p "Enter your choice [ 0 - 9 ]: " userInput
        case "${userInput}" in
                0) clear; create_project;;
		1) clear; start_session;;
		2) clear; switch_session;;
		3) clear; end_session;;
		4) clear; os_info;;
		5) clear; mem_info;;
		6) clear; host_info;;
		7) clear; net_info;;
		8) clear; usr_info;;
		9) clear; echo "Bye!"; exit 0;;
		*)
			echo "Please enter a decimal digit"
			pause
	esac
}

#########################
#			#
#	Main Menu	#
#			#
#########################
function main_menu(){
	write_header "Main Menu" '#'
	echo "	0) Begin a New Project"
	echo "	1) Work on an Existing Project"
	echo "	2) Work on a Different Project"
	echo "	3) Stop Working"
	echo "	4) Operating system info"
	echo "	5) Free and used memory info"
	echo "	6) Hostname and dns info"
	echo "	7) Network info"
	echo "	8) user_info"
	echo "	9) Exit"
}

#########################
#			#
#	MAIN LOGIC	#
#			#
#########################
while true; do
	clear
	set_aliases
 	main_menu
 	router
done
