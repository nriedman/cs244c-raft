# CS244c Final Project

## Setup

Included is a docker preparation that makes enviornment setup more straightforwared. First, make sure to have Docker installed on your system and running. Next, in the root directory of the project, run:

```
./run_docker.sh
```
If there is an issue with permissions, grant executable permissions to the script using your preferred method or:

```
chmod +x run_docker.sh
```

Once the container is active, you can build the example application as follows:

```
go build -o raftexample ./raftexample
```
See the [original project setup](https://github.com/etcd-io/etcd/tree/main/contrib/raftexample) instructions for an example of how to run a single node or a cluster.


## Acknowledgements

This repository is a modified version of the [example project](https://github.com/etcd-io/etcd/tree/main/contrib/raftexample) by [etcd](https://github.com/etcd-io). The following files have been modified from their original versions:

- `raft.go`
