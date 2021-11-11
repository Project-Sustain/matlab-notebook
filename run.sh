#!/bin/bash

export LD_LIBRARY_PATH="/usr/local/matlab/latest/bin/glnxa64:/usr/local/matlab/latest/sys/os/glnxa64" && ./gradlew clean build && ./gradlew bootRun
#export LD_LIBRARY_PATH="/usr/local/matlab/latest/bin/glnxa64:/usr/local/matlab/latest/sys/os/glnxa64" && ./gradlew clean build && java -cp build/libs/matlab-notebook-0.0.1-SNAPSHOT-uber.jar Main
