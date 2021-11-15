#!/bin/bash

curl -X POST -H "Content-Type: application/json" -d @eva_request.json "localhost:8081/echo"
