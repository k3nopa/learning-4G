#!/usr/bin/env bash

#k3d registry create registry.localhost --port 5000
k3d cluster create lab -s 1 -a 2 --registry-config ./registry.yaml --registry-use k3d-registry.localhost:5000
