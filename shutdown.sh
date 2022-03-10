#!/bin/bash

NOTEBOOK_PID=$(ps -aux | grep "[j]ava -jar build/libs/matlab-notebook-0.0.1-snapshot.jar" | awk '{ print $2 }')
if [[ "$NOTEBOOK_PID" == "" ]]; then
  echo -e "No matlab-notebook process found running." && exit 1
else
  echo -e "Found matlab-notebook process running with PID=$NOTEBOOK_PID, killing"
  kill "$NOTEBOOK_PID"
fi