#!/bin/bash

curl -X POST -H "Content-Type: application/json" -d @eva_request.json http://lattice-100:8081/eva
