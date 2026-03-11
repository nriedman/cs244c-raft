#!/bin/bash

docker build -t raft-research .
docker run -it -v $(pwd):/app raft-research

