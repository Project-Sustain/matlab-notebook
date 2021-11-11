#!/bin/bash

export LD_LIBRARY_PATH="/usr/local/matlab/latest/bin/glnxa64:/usr/local/matlab/latest/sys/os/glnxa64" && ./gradlew clean build && ./gradlew bootRun
