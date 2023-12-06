#!/bin/bash
##############################################################################
#
# Author: Logan Mancuso
# Created: 11.10.2023
#
##############################################################################

# Redirect all output to log file
exec > >(tee -a "${log_dst}") 2>&1

# Function to map arguments to local variables
function map_arguments() {
  OPTS=$(getopt -o p1:p2: --long param1:param2: -- "$@")
  if [ $? != 0 ] ; then echo "Failed parsing options." >&2 ; exit 1 ; fi
  eval set -- "$OPTS"
  while true; do
    case "$1" in
      -p1 | --param1 ) PARAM1="$2"; shift ;;
      -p2 | --param2 ) PARAM2="$2"; shift ;;
      -- ) shift; break ;;
      * ) break ;;
    esac
  done
  echo "Param 1 $PARAM1"
  echo "Param 2 $PARAM2"
  echo -e "END:\tmap_arguments"
}

# Helper function
function helper() {
  # Add the logic that the script will perform here
  echo -e "START:\thelper"
  echo -e "END:\thelper"
}

# Main function
function main() {
  echo -e "START:\tmain"
  echo "Waiting for cloud-init to finish"
  cloud-init status --wait
  echo "System information:"
  echo "Hostname: $(hostname)"
  echo "CPU usage: $(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1"%"}')"
  echo "Memory usage: $(free | grep Mem | awk '{print $3/$2 * 100.0"%"}')"
  map_arguments "$@"
  helper
  echo -e "END:\tmain"
}

# Start the script
main "$@"