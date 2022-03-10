#!/bin/bash

export LD_LIBRARY_PATH="/usr/local/matlab/latest/bin/glnxa64:/usr/local/matlab/latest/sys/os/glnxa64" && ./gradlew clean && ./gradlew build

if [[ $? -eq 0 ]]; then
  echo "Running test:"
  java -jar build/libs/matlab-notebook-0.0.1-SNAPSHOT.jar Main
fi
