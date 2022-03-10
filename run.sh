#!/bin/bash

export LD_LIBRARY_PATH="/usr/local/matlab/latest/bin/glnxa64:/usr/local/matlab/latest/sys/os/glnxa64" && ./gradlew clean && ./gradlew build

if [[ $? -eq 0 ]]; then
  echo -e "Build successful, launching Spring Boot application on $(hostname):9001 as a daemon, logging to matlab-notebook.log"
  nohup java -jar build/libs/matlab-notebook-0.0.1-SNAPSHOT.jar > matlab-notebook.log 2>&1 & disown
fi
