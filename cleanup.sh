#!/bin/bash

echo "stop docker containers"
docker stop python-debian-full-demo
docker stop python-debian-demo
docker stop python-chainguard-demo

echo "delete old images"
docker rmi python-debian-full-demo
docker rmi python-debian-demo
docker rmi python-chainguard-demo
