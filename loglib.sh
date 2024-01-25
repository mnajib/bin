#!/usr/bin/env bash

LOG_FILE="/tmp/${USER}-loglib.log"
LOG_LEVEL="silent"

logToFile(){
  #local logMsg="$1"
  #local logFile="$2"
  #echo "$logMsg" >> "$logFile"
  #echo "$logMsg" >> "$LOG_FILE"
  echo "$1" >> "$LOG_FILE"
}

logToScreen(){
  #local logMsg="$1"
  #echo "$logMsg"
  echo "$1"
}

log(){
  #local logMsg="$1"
  # if (global) $LOG_FILE is set
  #   log2file
  # else
  #   log2screen
  #if
  #if [ -f "$LOG_FILE" ]; then
  if [ -n "$LOG_FILE" ]; then
    #echo "ERROR: $message"
    #log2file "ERROR: $message"
    #log2file "$logMsg"
    logToFile "$1"
  else
    #echo "ERROR: $message"
    #log2screen "ERROR: $message"
    #log2screen "$logMsg"
    #logToScreen "$1"
    logToFile "$1"
  fi
}

logMessage(){
  local message_type="$1"
  local message="$2"

  case $LOG_LEVEL in
    "verbose")  # log all/everything we can get
      if [ "$message_type" = "error" ]; then
        log "ERROR: $message"
      elif [ "$message_type" = "verbose" ]; then
        log "VERBOSE: $message"
      elif [ "$message_type" = "info" ]; then
        log "INFO: $message"
      fi
      ;;
    "info")     # log error and warning
      if [ "$message_type" = "error" ]; then
        log "ERROR: $message"
      elif [ "$message_type" = "info" ]; then
        log "INFO: $message"
      elif [ "$message_type" = "NORMAL" ]; then
        log "INFO: $message"
      fi
      ;;
    "error")    # onlo log error
      if [ "$message_type" = "error" ]; then
        log "ERROR: $message"
      fi
      ;;
    "silent")   # no log
      # do nothing
      ;;
    *)
      log "XXX: $message"
      ;;
  esac
}

setLogLevel() {
  LOG_LEVEL="$1"
  logMessage "verbose" "setLogLevel: Log level set to: $LOG_LEVEL"
}

