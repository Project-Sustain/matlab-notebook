#!/bin/bash

curl -X POST -H "Content-Type: application/json" -d @eva_request.json "http://localhost:8081/echo"
