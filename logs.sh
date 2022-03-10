#!/bin/bash

LOGFILE="./matlab-notebook.log"
[[ -f "$LOGFILE" ]] || (echo -e "No logfile found" ; exit 1)
tail -n 200 -f "$LOGFILE"