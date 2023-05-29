#!/bin/bash

## @file
## @author Jens Tirsvad Nielsen
## @brief Logger
## @details
## **Logger**
##
## Info to screen
## Log info and error to file

declare -g IFS=$'\n\t'
declare -g TCLI_LOGGER_INFOSCREEN_WARN=0
# screen color output
declare -g -r TCLI_LOGGER_NC='\033[0m' # No Color
declare -g -r TCLI_LOGGER_RED='\033[0;31m'
declare -g -r TCLI_LOGGER_GREEN='\033[0;32m'
declare -g -r TCLI_LOGGER_BROWN='\033[0;33m'
declare -g -r TCLI_LOGGER_BLUE='\033[0;34m'
declare -g -r TCLI_LOGGER_YELLOW='\033[1;33m'
declare -g -r TCLI_LOGGER_WHITE='\033[0;37m'

## @fn tcli_logger_init()
## @details
## **Initial logger**
## All output to file
## output to screen example
## printf "this output is visible" >&3
## @param logfil full path
tcli_logger_init() {
  local _file=${1-my.log}
  local _dir
  _dir=$(dirname "${1}")
	[ ! -d ${_dir} ] && mkdir $_dir || rm -f ${1}
  exec 3>&1 4>&2
  exec 3>$_file 2>&3
  printf "Logger loaded" >&3
}

tcli_logger_infoscreen() {
	printf $(printf "[......] ${TCLI_LOGGER_BROWN}$1 ${TCLI_LOGGER_NC}$2$n")
}

tcli_logger_infoscreenDone() {
	[ ${TCLI_LOGGER_INFOSCREEN_WARN} == 1 ] && TCLI_LOGGER_INFOSCREEN_WARN=0 || printf "\r\033[1C${TCLI_LOGGER_GREEN} DONE ${TCLI_LOGGER_NC}"
	printf "\r\033[80C\n"
}

tcli_logger_infoscreenFailed() {
	[ ${TCLI_LOGGER_INFOSCREEN_WARN} == 1 ] && TCLI_LOGGER_INFOSCREEN_WARN=0
	printf "\r\033[1C${TCLI_LOGGER_RED}FAILED${TCLI_LOGGER_NC}\n"
	[ ${1} ] && printf "${TCLI_LOGGER_RED}${1:-}"
	[ ${2} ] && printf " ${TCLI_LOGGER_BLUE}$2"
	[ ${3} ] && printf " ${TCLI_LOGGER_RED}$3"
	printf "${TCLI_LOGGER_NC}\n"
}

tcli_logger_infoscreenFailedExit() {
	printf "\r\033[1C${TCLI_LOGGER_RED}FAILED${TCLI_LOGGER_NC}\n"
	[ ${1} ] && printf "${TCLI_LOGGER_RED}${1:-}"
	[ ${2} ] && printf " ${TCLI_LOGGER_BLUE}$2"
	[ ${3} ] && printf " ${TCLI_LOGGER_RED}$3"
	printf "${TCLI_LOGGER_NC}\n"
	exit 1
}

tcli_logger_infoscreenWarn() {
	printf "\r\033[1C${TCLI_LOGGER_YELLOW} WARN ${TCLI_LOGGER_NC}"
	TCLI_LOGGER_INFOSCREEN_WARN=1
}

tcli_logger_infoscreenStatus() {
    if [ $1 != "0" ]; then
        tcli_logger_infoscreenFailed
    else
        tcli_logger_infoscreenDone
    fi
}

tcli_logger_errorCheck() {
	if [ "$?" = "0" ]; then
		printf "${TCLI_LOGGER_RED}An error has occured.${TCLI_LOGGER_NC}"
		# read -p "Press enter or space to ignore it. Press any other key to abort." -n 1 key
		# if [[ $key != "" ]]; then
		# 	exit
		# fi
	fi
}

tcli_logger_title() {
  local _fillerlength=${2:-79}
  local _n_pad=$(( (${_fillerlength} - ${#1} - 2) / 2 ))
  # (( _fillerlength++ ))
  # echo "string ${_fillerlength}"
  # echo "Some _n_pad len $_n_pad"
  i=$(( $_n_pad * 2 + 2 +${#1} ))
  # echo "Some len $i"
  # printf '%c\e[%db\n' "+" "${_fillerlength}"
  printf "$(printf "%${_fillerlength}s" | tr ' ' +)\n"
  printf $(printf "%${_n_pad}s" | tr ' ' +)
  printf $(printf ' %s ' "$1")
  if [ $(( $_n_pad * 2 + ${#1} + 2 )) -gt ${2} ]; then
    (( _n_pad-- ))
  elif [ $(($_n_pad*2+${#1}+2)) -lt ${2} ]; then
    (( _n_pad++ ))
  fi
  printf $(printf "%${_n_pad}s" | tr ' ' +)"\n"
  printf "$(printf "%${_fillerlength}s" | tr ' ' +)\n"
  # printf '%c\e[%db\n' "+" "${_fillerlength}"
  # echo "Some _n_pad len $_n_pad"
}